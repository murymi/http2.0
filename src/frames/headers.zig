const std = @import("std");
const frame = @import("../frames.zig");
const hpack = @import("../hpack.zig");
const Head = frame.Head;

pub const Headers = @This();
const sort = std.sort;

fn cmp(_: void, lhs: hpack.HeaderField, rhs: hpack.HeaderField) bool {
    return lhs.size() < rhs.size();
}

builder: *hpack.Builder,
parser: *hpack.Parser,

// todo; add padding
pub fn write(self: *Headers, stream: anytype, max_header_list: u24, headers: []hpack.HeaderField, id: u31, endstream: bool) !void {
    sort.block(hpack.HeaderField, headers, {}, cmp);
    if (hpack.Field.getHeaderFieldLen(headers) <= max_header_list) {
        self.builder.clear();
        try self.builder.addSlice(headers);
        const hfin = self.builder.final();
        var header = frame.Head{ .flags = .{ .endheaders = true, .ack = endstream }, .len = @intCast(hfin.len), .streamid = id, .ty = .headers };
        try header.write(stream);
        try stream.writeAll(hfin);
        return;
    }
    var fitting = hpack.Field.sliceOnFieldlen(headers, max_header_list);
    var first_round = false;
    while (fitting.b.len > 0) {
        self.builder.clear();
        try self.builder.addSlice(fitting.a);
        const hfin = self.builder.final();
        var h = frame.Head{ .flags = if (first_round) .{ .ack = endstream } else .{}, .len = @intCast(hfin.len), .streamid = id, .ty = if (first_round) .headers else .continuation };
        try h.write(stream);
        try stream.writeAll(hfin);
        fitting = hpack.Field.sliceOnFieldlen(fitting.b, max_header_list);
        first_round = false;
    }

    self.builder.clear();
    try self.builder.addSlice(fitting.a);
    const hfin = self.builder.final();
    var finalhead = frame.Head{ .flags = if (first_round) .{ .ack = endstream, .endheaders = true } else .{ .endheaders = true }, .len = @intCast(hfin.len), .streamid = id, .ty = if (first_round) .headers else .continuation };
    try finalhead.write(stream);
    try stream.writeAll(hfin);
}

pub fn read(instream: anytype, out: []u8, head: Head) !usize {
    var hd = head;
    var r: usize = 0;

    while (!hd.flags.endheaders) {
        var toread = hd.len;
        const paddlen = if (hd.flags.padded) try instream.readInt(u8, .big) else 0;
        if (hd.flags.padded) toread -= (1 + paddlen);
        if (hd.flags.priority) {
            try instream.skipBytes(5, .{});
            toread -= 5;
        }
        r += try instream.readAll(out[r .. r + toread]);
        try instream.skipBytes(paddlen, .{});
        hd = try Head.read(instream);
    }

    const paddlen = if (hd.flags.padded) try instream.readInt(u8, .big) else 0;
    var toread = hd.len - paddlen;

    if (hd.flags.padded) toread -= 1;
    // Todo
    if (hd.flags.priority) {
        try instream.skipBytes(5, .{});
        toread -= 5;
    }

    r += try instream.readAll(out[r .. r + toread]);
    try instream.skipBytes(paddlen, .{});
    return r;
}

/// `buf` is heap
pub fn readAndParse(
    self: *Headers,
    instream: anytype,
    head: Head,
    out: []hpack.HeaderField,
) ![]hpack.HeaderField {
    var buf = [_]u8{0} ** 10000;
    const n = try read(instream, buf[0..], head);
    //std.debug.print("---------> > > n = {}\n", .{n});
    return try self.parser.parse(buf[0..n], out[0..]);
}

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var buf = [_]u8{0} ** 4096;

    var ctx = try hpack.Tables.init(gpa.allocator());

    //var p = hpack.Parser.init(&ctx, buf[0..]);
    var headerheap = [_]u8{0} ** 400;

    var h = Headers{ .builder = hpack.Builder.init(&ctx, buf[0..]), .parser = hpack.Parser.init(&ctx, headerheap[0..]) };

    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);
    try h.builder.add(.{ .name = "hello", .value = "world" }, false, false);

    var streambuf = [_]u8{0} ** 4096;
    var stream = std.io.fixedBufferStream(streambuf[0..]);

    try h.write(stream.writer(), 10, 4, true);

    //var headerbuf = [_]u8{0}**400;
    stream.pos = 0;

    const hh = try Head.read(stream.reader());

    //const n = try read(stream.reader(), headerbuf[0..],hh);

    var headers = [_]hpack.HeaderField{.{}} ** 10;

    const kuku = try h.readAndParse(stream.reader(), hh, headers[0..]);
    //parser.parse(headerbuf[0..n], headers[0..]);

    for (kuku) |k| {
        std.debug.print("{s}: {s}\n", .{ k.name, k.value });
    }

    std.debug.print("{}\n", .{kuku.len});
}

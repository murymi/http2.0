const std = @import("std");
//pub const PushPromise = @This();
const hpack = @import("../hpack.zig");
const frame = @import("../frames.zig");

//const frame = @import("../frames.zig");
//const hpack = @import("../hpack.zig");
const Head = frame.Head;

const sort = std.sort;

builder: *hpack.Builder,
parser: *hpack.Parser,

fn cmp(_: void, lhs: hpack.HeaderField, rhs: hpack.HeaderField) bool {
    return lhs.size() < rhs.size();
}

pub const idmask: u32 = (1 << 31);

// todo; add padding
pub fn write(
    self: *@This(),
    stream: anytype,
    id: u31,
    promiseId: u32,
    max_header_list: u24,
    headers: []hpack.HeaderField,
) !void {
    sort.block(hpack.HeaderField, headers, {}, cmp);
    if (hpack.Field.getHeaderFieldLen(headers) <= max_header_list) {
        self.builder.clear();
        try self.builder.addSlice(headers);
        const hfin = self.builder.final();
        var header = frame.Head{ .flags = .{ .endheaders = true }, .len = @intCast(hfin.len + 4), .streamid = id, .ty = .pushpromise };
        try header.write(stream);
        try stream.writeInt(u32, promiseId, .big);
        try stream.writeAll(hfin);
    } else {
        var fitting = hpack.Field.sliceOnFieldlen(headers, max_header_list);
        var first_round = true;
        while (fitting.b.len > 0) {
            self.builder.clear();
            try self.builder.addSlice(fitting.a);
            const hfin = self.builder.final();
            var h = frame.Head{ .flags = .{}, .len = @intCast(if (first_round) hfin.len + 4 else hfin.len), .streamid = id, .ty = if (first_round) .pushpromise else .continuation };
            try h.write(stream);
            if (first_round) try stream.writeInt(u32, promiseId, .big);
            try stream.writeAll(hfin);
            fitting = hpack.Field.sliceOnFieldlen(fitting.b, max_header_list);
            first_round = false;
        }
        self.builder.clear();
        try self.builder.addSlice(fitting.a);
        const hfin = self.builder.final();
        var finalhead = frame.Head{ .flags = .{ .endheaders = true }, .len = @intCast(if (first_round) hfin.len + 4 else hfin.len), .streamid = id, .ty = if (first_round) .pushpromise else .continuation };
        try finalhead.write(stream);
        if (first_round) try stream.writeInt(u32, promiseId, .big);
        try stream.writeAll(hfin);
    }
}

pub fn read(instream: anytype, out: []u8, head: Head, id: *u31) !usize {
    var hd = head;
    var r: usize = 0;
    while (!hd.flags.endheaders) {
        var toread = hd.len;
        const paddlen = if (hd.flags.padded) try instream.readInt(u8, .big) else 0;
        if (hd.flags.padded) toread -= (1 + paddlen);

        r += try instream.readAll(out[r .. r + toread]);
        try instream.skipBytes(paddlen, .{});
        hd = try Head.read(instream);
    }
    const paddlen = if (hd.flags.padded) try instream.readInt(u8, .big) else 0;
    var toread = hd.len - (paddlen + 4);
    if (hd.flags.padded) toread -= 1;
    id.* = @truncate(try instream.readInt(u32, .big) & ~idmask);
    r += try instream.readAll(out[r .. r + toread]);
    try instream.skipBytes(paddlen, .{});
    return r;
}

pub const Promise = struct { headers: []hpack.HeaderField, streamId: u31 };

/// `buf` is heap
pub fn readAndParse(
    self: *@This(),
    instream: anytype,
    head: Head,
    out: []hpack.HeaderField,
) !Promise {
    var buf = [_]u8{0} ** 10000;
    var id: u31 = 0;
    const n = try read(instream, buf[0..], head, &id);
    return .{ .headers = try self.parser.parse(buf[0..n], out[0..]), .streamId = id };
}

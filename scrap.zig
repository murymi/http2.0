const std = @import("std");
const hpack = @import("./hpack.zig");
//const Head = @import("frames/frames.zig").Head;

//const Pp = @import("frames/pp.zig");

const frames = @import("frames.zig");
const Headers = frames.Headers;
const Head = frames.Head;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn maintt() !void {
    //var buf = [_]u8{0} ** 24;

    // const hd = frames.Head{
    //     .ty = .rst,
    //     .len = 4,
    //     .streamid = 89,
    //     .flags = .{}
    // };

    var buf = [_]u8{0} ** 4096;
    //var stream = std.io.fixedBufferStream(buf[0..]);

    var ctx = try hpack.Tables.init(gpa.allocator());

    //var p = hpack.Parser.init(&ctx, buf[0..]);
    var headerheap = [_]u8{0} ** 4096;
    var streamr = std.io.fixedBufferStream(headerheap[0..]);

    var pp = frames.PushPromise{ .builder = hpack.Builder.init(&ctx, buf[0..]), .parser = hpack.Parser.init(&ctx, headerheap[0..]) };

    var expected = [_]hpack.HeaderField{ .{ .name = ":status", .value = "302" }, .{ .name = "cache-control", .value = "private" }, .{ .name = "date", .value = "Mon, 21 Oct 2013 20:13:21 GMT" }, .{ .name = "location", .value = "https://www.example.com" } };

    try pp.write(streamr.writer(), 90, 100, expected[0..]);

    //frames.PushPromise.write(self: *PushPromise, stream: anytype, id: u31, max_header_list: u24, headers: hpack.HeaderField)
}

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var buf = [_]u8{0} ** 4096;

    var ctx = try hpack.Tables.init(gpa.allocator());

    //var p = hpack.Parser.init(&ctx, buf[0..]);
    var headerheap = [_]u8{0} ** 4096;

    var h = Headers{ .builder = hpack.Builder.init(&ctx, buf[0..]), .parser = hpack.Parser.init(&ctx, headerheap[0..]) };

    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);
    //try h.builder.add(.{.name ="hello", .value = "world"}, false, false);

    var streambuf = [_]u8{0} ** 4096;
    var stream = std.io.fixedBufferStream(streambuf[0..]);

    var expected = [_]hpack.HeaderField{ .{ .name = "", .value = "" }, .{ .name = "", .value = "" }, .{ .name = "three", .value = "Mon, 21 Oct 2013 20:13:21 GMT" }, .{ .name = "four", .value = "https://www.example.com" } };

    try h.write(stream.writer(), 100, expected[0..], 4, true);

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

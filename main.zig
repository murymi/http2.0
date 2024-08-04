const std = @import("std");
const math = std.math;
const testing = std.testing;
const codec = @import("codec.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};



pub fn main() !void {
    var buf = [_]u8{0} ** 1000;
    var buf2 = [_]u8{0} ** 1000;

    const malloc = gpa.allocator();
    var ctx = try codec.init(malloc);

    const a = try codec.encodeHuffmanString("hello world", buf[0..]);
    const res = try codec.decodeString(&ctx, a, buf2[0..]);
    std.debug.print("{s}\n", .{res});
}



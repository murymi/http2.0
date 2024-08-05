const std = @import("std");
//const math = std.math;
//const testing = std.testing;
//const codec = @import("codec.zig");
//const stable = @import("static_table.zig");
//const dtable = @import("dyn_table.zig");
const Allocator = std.mem.Allocator;
const t  = @import("tables.zig");
const builder = @import("builder.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};


pub fn main() !void {
    const malloc = gpa.allocator();

    var ctx = try t.init(malloc);

    var b = builder.init(malloc, &ctx);
    //try b.addIndexed(3);
    //try b.buf.writer().writeInt(u128, 40, .big);
    //_ = try foo(b.buf.writer());
    //try b.addIndexedNameLiteralValue(23, "hello world", true);
    //try b.addLiterals("custom-key", "custom-header", false);
    try b.addCompress(.{.name = ":method", .value = "GET"}, false, true);
    try b.addCompress(.{.name = ":scheme", .value = "http"}, false, true);
    try b.addCompress(.{.name = ":path", .value = "/"}, false, true);
    try b.addCompress(.{.name = ":authority", .value = "www.example.com"}, true, false);


    std.debug.print("{x}\n", .{b.buf.items});

    //var dyn = dyn_table.init(malloc, 2000);

    //var stable = try static_table.init(malloc);

}

// 11 11 11 10
// 01 11 11 11
// 01 11 11 11

// 00 01 00 00

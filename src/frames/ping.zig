const std = @import("std");
const frame = @import("../frames.zig");
const hpack = @import("../hpack.zig");
const Head = frame.Head;


pub fn read(stream: anytype, head: frame.Head) ![8]u8 {
    std.debug.assert(head.len == 8);
    var buf:[8]u8 = undefined;
    _ = try stream.readAll(buf[0..]);
    //std.debug.print("READ PING: {any}\n", .{buf});
    return buf;
}

pub fn ping(stream: anytype, opaque_data: [8]u8) !void {
    var p = Head{
        .flags = .{},
        .len = 8,
        .streamid = 0,
        .ty = .ping
    };
    try p.write(stream);
    _ = try stream.writeAll(opaque_data[0..]);
}

pub fn pong(stream: anytype, payload: [8]u8) !void {
        var p = Head{
        .flags = .{.ack = true },
        .len = 8,
        .streamid = 0,
        .ty = .ping
    };
    try p.write(stream);
    _ = try stream.writeAll(payload[0..]);
}

const Self = @This();

pub const Ping  =struct {
    payload: [8]u8,
};


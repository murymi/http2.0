const std = @import("std");
const frame = @import("../frames.zig");
const hpack = @import("../hpack.zig");
const Head = frame.Head;

pub const idmask: u32 = (1 << 31);

pub fn read(stream: anytype, head: frame.Head) !u64 {
    std.debug.assert(head.len == 4);
    return try stream.readInt(u32, .big) & ~idmask;
}

pub fn write(stream: anytype, id: u31, increment: u31) !void {
    var p = Head{ .flags = .{}, .len = 4, .streamid = id, .ty = .windowupdate };
    try p.write(stream);
    _ = try stream.writeInt(u32, increment, .big);
}

const std = @import("std");
const frame = @import("../frames.zig");
const hpack = @import("../hpack.zig");
const Head = frame.Head;
const errors = @import("../errors.zig");


pub const PayLoad = struct {
    last_id: u31,
    code: errors.Code,
    debug_info: ?[]const u8 = null
};

const idmask:u32 = (1 << 31);


pub fn read(stream: anytype, head: frame.Head) !PayLoad {
    const last_id = try stream.readInt(u32, .big) & ~idmask;
    const code = try stream.readInt(u32, .big);
    try stream.skipBytes(head.len - 8, .{});
    return PayLoad{.code = @enumFromInt(code), .last_id = @truncate(last_id) };
}

pub fn write(stream: anytype,payload: PayLoad) !void {
    var p = Head{
        .flags = .{},
        .len = @truncate(8 + if(payload.debug_info) |info| info.len else 0),
        .streamid = 0,
        .ty = .goaway
    };
    try p.write(stream);
    try stream.writeInt(u32, payload.last_id, .big);
    try stream.writeInt(u32, @intFromEnum(payload.code), .big);
    if(payload.debug_info) |info| _ = try stream.writeAll(info[0..p.len-8]);
}
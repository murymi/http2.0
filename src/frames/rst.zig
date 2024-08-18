const std = @import("std");
pub const Rst = @This();
const Head = @import("../frames.zig").Head;
const errors = @import("../errors.zig");

code: errors.Code,

pub fn read(in: anytype) !Rst {
    return Rst{
        .code = @enumFromInt((try in.readInt(u32, .big)))
    };
}

pub fn write(streamid: u31, code: errors.Code,  out: anytype) !void {
    var head = Head{.flags = .{}, .ty = .rst, .streamid = streamid, .len = 4 };
    try Head.write(&head, out);
    try out.writeInt(u32, @intFromEnum(code), .big);
}


// pub fn main() !void {
//     var buf = [_]u8{0} ** 24;
//     var stream = std.io.fixedBufferStream(buf[0..]);
// 
//     const h = frames.Head{
//         .ty = .rst,
//         .len = 4,
//         .streamid = 89,
//         .flags = .{}
//     };
// 
//     try frames.Rst.write(h, 78, stream.writer());
// 
//     stream.pos = 0;
// 
//     //var bufr = [_]u8{0} ** 24;
//     //var streamr = std.io.fixedBufferStream(bufr[0..]);
// 
//     const hd = try frames.Head.read(stream.reader());
//     _ = hd;
// 
//     const rst = try frames.Rst.read(stream.reader());
// 
//     std.debug.print("{}\n", .{rst});
// }

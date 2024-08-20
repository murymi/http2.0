const std = @import("std");
const frame = @import("../frames.zig");

pub fn readAll(in: anytype, out: anytype, head: frame.Head) !void {
    // todo
    var buf = [_]u8{0} ** 512;
    const paddlen:u8 = if(head.flags.padded) try in.readInt(u8, .big) else 0;
    var rem:usize = (head.len - paddlen);

    if(head.flags.padded) rem -= 1;

    while (rem > 0) {
        const n = try in.read(buf[0..@min(buf.len, rem)]);
        try out.writeAll(buf[0..n]);
        rem -= @intCast(n);
    }

    try in.skipBytes(paddlen, .{});
}



pub fn writeStream(in: anytype, out: anytype, head: frame.Head) !void {
    var hd = head;
    hd.flags.padded = false;
    var buf = [_]u8{0} ** 512;
    var rem = head.len;
    try hd.write(out);
    while (rem > 0) {
        const n = try in.read(buf[0..@min(buf.len, rem)]);
        try out.writeAll(buf[0..n]);
        rem -= @intCast(n);
    }
}

pub fn writeEmpty(stream: anytype, id: u31) !void {
    var hd = frame.Head{
        .flags = .{.ack = true},
        .streamid = id,
        .len = 0,
        .ty = .data
    };
    try hd.write(stream);
}

pub fn write(out: anytype, id: u31, buf: []const u8, padding: []const u8, eos: bool) !void {
    _ = padding;
    var hd = frame.Head{
        .ty = .data,
        .len = @truncate(buf.len
         //+ padding.len
        ),
        .streamid = id,
        .flags = .{.ack = eos}
    };
    //if(padding.len > 0) hd.flags.padded = true;
    try hd.write(out);
    try out.writeAll(buf);
    //if(padding.len > 0) try out.writeAll(padding);
    //std.debug.print("--------------------------> {any}\n", .{hd});
}

pub fn main() !void {
    const message = "hello world!!";
    var messagestream = std.io.fixedBufferStream(message);

    const head = frame.Head{
        .flags = .{},
        .len = @intCast(message.len),
        .streamid = 90,
        .ty = .data
    };

    var buf = [_]u8{0} ** 256;
    var stream = std.io.fixedBufferStream(buf[0..]);

    try write(messagestream.reader(),stream.writer(), head);

    stream.pos = 0;

    var recvbuf = [_]u8{0} ** 256;
    var recstream = std.io.fixedBufferStream(recvbuf[0..]);

    const rechead = try frame.Head.read(stream.reader());

    try readAll(stream.reader(), recstream.writer(), rechead);

    std.debug.print("{s}\n", .{recvbuf});

}
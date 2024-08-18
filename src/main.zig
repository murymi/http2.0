const std = @import("std");
const hpack = @import("./hpack.zig");
//const Head = @import("frames/frames.zig").Head;
const Connection = @import("connection.zig");
const Stream = @import("stream.zig");

//const Pp = @import("frames/pp.zig");

pub const preface = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n";


const frames = @import("frames.zig");
const Headers = frames.Headers;
const Head = frames.Head;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const address = try std.net.Address.parseIp4("127.0.0.1", 3000);
    var server = try address.listen(.{.reuse_address = true, .reuse_port = true});

    while (true) {
        var con = try Connection.init(gpa.allocator(), (try server.accept()).stream, .server);
        defer con.close() catch {};


        //const n = try con.stream.reader().readAll(recvbuf[0..24]);
        //std.debug.assert(n == preface.len);

        //frames.Settings.Settings.write(self: *Settings, stream: anytype, ack: bool)


        try con.processFrames();
    }

}

pub fn maint() !void {
    //_ = FrameHeader{};

    var buf = [_]u8{0} ** 4096;

    var ctx = try hpack.Tables.init(gpa.allocator());
    var p = hpack.Parser.init(&ctx, buf[0..]);
    //builder.add(.{ .name = "path"}, false, false);

//_ = p;
    //var b = std.io.fixedBufferStream(buf[0..]);
    //b.writer().st

    //const h = try b.reader(readStruct(FrameHeader.LengthType);
    //var h = try FrameHeader.read(b.reader());

    //var c = [_]u8{0} ** 9;
    //h.flags.endheaders = true;
    //h.flags.eos = true;

    //b.reset();
    //try h.write(b.writer());

    //std.debug.print("{any}\n", .{buf});
//============
    const address = try std.net.Address.parseIp4("127.0.0.1", 3000);
    var server = try address.listen(.{.reuse_address = true, .reuse_port = true});
    var con = try server.accept();
    var recvbuf = [_]u8{0} ** 4096;
    const n = try con.stream.reader().readAll(recvbuf[0..24]);
    std.debug.assert(n == preface.len);
    var settings_ack = Head{
        .flags = .{.ack = true },
        .ty = .settings,
        .streamid = 0,
        .len = 0
    }; 
    var settings = try Head.read(con.stream.reader());
    //_ = settings;
    std.debug.print("{}\n", .{settings});
    try settings.write(con.stream.writer());
    try settings_ack.write(con.stream.writer());
    const settin = try Head.read(con.stream.reader());
    //std.debug.print("{b}\n", .{@as(u8, @bitCast(settings_ack.flags))});
    //settings = try FrameHeader.read(con.stream.reader());

    std.debug.print("HHH -> {any}\n", .{settin});

    const hlen = try con.stream.reader().readAll(recvbuf[0..settin.len]);
    std.debug.print("hlen => {}\n", .{hlen});
    var headers = [_]hpack.HeaderField{.{}} ** 24;
    const heads = try p.parse(recvbuf[0..hlen], headers[0..]);

    for (heads) |value| {
        std.debug.print("{s}: {s}\n", .{value.name, value.value});
    }



    const jaba = try Head.read(con.stream.reader());
    std.debug.print("====={}======\n", .{jaba});


    var builder = hpack.Builder.init(&ctx, buf[0..]);
        //try builder.add(.{ .name = ":method", .value = "GET"}, false, false);
        //try builder.add(.{ .name = ":scheme", .value = "http"}, false, false);
    try builder.add(.{ .name = ":status", .value = "404", }, false, false);
        //try builder.add(.{ .name = "content-type", .value = "text/plain"}, false, false);
    const hfin = builder.final();
    var ddd = Head{
        .flags = .{.endheaders = true, .ack = true },
        .ty = .headers,
        .streamid = 1,
        .len = @intCast(hfin.len)
    };
    try ddd.write(con.stream.writer());
    try con.stream.writer().writeAll(hfin);




    //_ = try con.stream.reader().readInt(u32, .big);
    //const status = try con.stream.reader().readInt(u32, .big);
    //std.debug.print("jaba => {} , {any}\n", .{status, jaba});


    //const jaba2 = try FrameHeader.read(con.stream.reader());
    //_ = try con.stream.reader().readInt(u32, .big);
    //const status2 = try con.stream.reader().readInt(u32, .big);
    //std.debug.print("jaba2 => {} , {any}\n", .{status2, jaba2});




    //try builder.add(.{.name = ":content-type", .value = "text/plain"}, false, false);

    // settin = try FrameHeader.read(con.stream.reader());
    // const hlen2 = try con.stream.reader().readAll(recvbuf[0..settin.len]);
    // var headers2 = [_]hpack.HeaderField{.{}} ** 24;
    // const heads2 = try p.parse(recvbuf[0..hlen2], headers2[0..]);
    // for (heads2) |value| {
    //     std.debug.print("{s}: {s}\n", .{value.name, value.value});
    // }
    //var end_stream = FrameHeader{
    //    .flags = .{},
    //    .len = 4,
    //    .ty = .rst,
    //    .streamid = 1
    //};
    //try end_stream.write(con.stream.writer());
    //try con.stream.writer().writeInt(u32, 1, .big);

    //try settings_ack.write(con.stream.writer());
    //std.debug.print("{}\n", .{settings});
    //settings = try FrameHeader.read(con.stream.reader());
    // const r = try con.stream.read(recvbuf[0..]);
    // std.debug.print("n = {}\n", .{r});
    //p.parse(in: []const u8, output: []stable.HeaderField)
    //try settings.write(con.stream.writer());
    //const ciko = try FrameHeader.read(con.stream.reader());
//_ = settin;

    //std.debug.print("{}\n", .{settings});
    std.debug.print("{}\n", .{settin});


}
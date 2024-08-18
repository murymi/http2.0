const std = @import("std");
pub const hpack = @import("../hpack.zig");

pub const preface = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n";
pub const idmask:u32 = (1 << 31);

// le 1 1 1 1 0 0 0
// be 0 0 0 1 1 1 1
pub const Head = struct {
    pub const Type = enum(u8) {
        data = 0x00,
        headers = 0x01,
        priority = 0x02,
        rst = 0x03,
        settings = 0x04,
        pushpromise = 0x05,
        ping = 0x06,
        goaway = 0x07,
        windowupdate = 0x08,
        continuation = 0x09,
    };

    pub const Flags = packed struct(u8) { 
        // ack or end of stream
        ack: bool = false,
        @"6": bool = false,
        // end headers
        endheaders: bool = false,

        // padded
        padded: bool = false,

        @"3": bool = false,

        // priority
        priority: bool = false,

        @"1": bool = false,
        @"0": bool = false,
    };

    len: u24,
    streamid: u31,
    ty: Type,
    flags: Flags,

    pub fn read(stream: anytype) !Head {
        var len = try stream.readInt(u32, .big);
        const ty:u8 = @intCast(len & 0xff);
        len >>= 8;
        const f = try stream.readInt(u8, .big);
        const id = try stream.readInt(u32, .big);
        return Head{
            .len = @truncate(len),
            .ty = @enumFromInt(ty),
            .flags = @bitCast(f),
            .streamid = @truncate(id & ~idmask)
        };
    }

    pub fn write(self: *Head, stream: anytype) !void {
        const lt = self.len << 8 | @as(u8, @intFromEnum(self.ty));
        try stream.writeInt(u32, lt, .big);
        try stream.writeInt(u8, @bitCast(self.flags), .big);
        try stream.writeInt(u32, @intCast(self.streamid), .big);
    }
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
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

//    var b = std.io.fixedBufferStream(buf[0..]);
//
//    var settings_ack = FrameHeader{
//        .flags = .{.@"0" = true },
//        .ty = .settings,
//        .streamid = 0,
//        .len = 56
//    };
//
//    try settings_ack.write(b.writer());
//    b.pos = 0;
//    const f = try FrameHeader.read(b.reader());
//    std.debug.print("{any}\n", .{f});


pub fn maitn() !void {
    var buf = [_]u8{0} ** 50;

    var b = std.io.fixedBufferStream(buf[0..]);


    var  a = Head{
        .flags = .{.ack = true },
        .streamid = 45,
        .len = 7,
        .ty = .data
    };

    try a.write(b.writer());
    b.pos = 0;

    const c = try Head.read(b.reader());

    std.debug.print("{any}\n", .{c});
}
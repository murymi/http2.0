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
const Code = @import("errors.zig").Code;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const address = try std.net.Address.parseIp4("127.0.0.1", 3000);
    const st = try std.net.tcpConnectToAddress(address);
    //_ = try stream.writer().writeAll("hello world");

    var con = try Connection.init(gpa.allocator(), st, .client);
    //_ = con;
    var reply = [_]hpack.HeaderField{
        .{ .name = ":method", .value = "GET" },
        .{ .name = ":authority", .value = "127.0.0.1:3000" },
        .{ .name = ":scheme", .value = "http" },
        .{ .name = ":path", .value = "/mogoka/baze" },
    };

    var stream = try con.request(reply[0..]);

    stream.onHeaders(struct {
        pub fn cb(headers: []hpack.HeaderField, _: *Stream) void {
            for (headers) |h| {
                h.display();
            }
        }
    }.cb);

    const DataProcesser = struct {
        pub fn cb(strm: *Stream, head: frames.Head) void {
            _ = head;
            std.debug.print("DATA...\n", .{});
            var buf = [_]u8{0} ** 512;
            var n = strm.read(buf[0..]) catch |e| @panic(@errorName(e));

            std.debug.print("Data: {s}\n", .{buf[0..n]});
            while (n > 0) {
                n = strm.read(buf[0..]) catch @panic("err reading");
            }
        }
    };

    stream.onData(DataProcesser.cb);

    stream.onRst(struct {
        pub fn cb(strm: *Stream, code: Code) void {
            _ = strm;

            std.debug.print("RST: code[{}]\n", .{code});
        }
    }.cb);

    con.onPushPromise(struct {
        pub fn f(strm: *Stream, headers: []hpack.HeaderField) void {
            //_ = strm;
            for (headers) |value| value.display();
            //strm.terminate(.no_error) catch @panic("err terminating");

            strm.onData(DataProcesser.cb);
        }
    }.f);

    con.onPing(struct {
        pub fn f(c: *Connection, payload: [8]u8) void {
            c.pong(payload) catch {};

            std.debug.print("PING: {s}", .{payload});
        }
    }.f);

    con.onSettings(struct {
        pub fn f(c: *Connection, settings: frames.Settings) void {
            std.debug.print("SET: {}\n", .{settings});
            c.acceptSettings(settings) catch {};
        }
    }.f);

    con.onGoAway(struct {
        pub fn f(_: *Connection, payload: frames.GoAway.PayLoad) void {
            std.debug.print("GOAWAY: {}", .{payload});
        }
    }.f);

    try con.processFrames();
}

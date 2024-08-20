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
    var server = try address.listen(.{ .reuse_address = true, .reuse_port = true });

    while (true) {
        var con = try Connection.init(gpa.allocator(), (try server.accept()).stream, .server);
        defer con.close() catch {};

        con.onStream(struct {
            pub fn f(stream: *Stream) void {

                //var pushrequest = [_]hpack.HeaderField{
                //    .{ .name = ":path", .value = "/bow/wow" },
                //    .{ .name = "content-type", .value = "text-plain" },
                //    .{.name = ":scheme", .value = "http"},
                //};
                //var promised_stream = stream.pushRequest(pushrequest[0..]) catch @panic("push failed");
                //std.debug.print("====== SENT PUSH ========", .{});

                //promised_stream.write("Hello from zig push\n", "", true) catch {};

                stream.onHeaders(struct {
                    pub fn cb(headers: []hpack.HeaderField, strm: *Stream) void {
                        for (headers) |h| {
                            h.display();
                        }

                        var reply = [_]hpack.HeaderField{ .{ .name = ":status", .value = "200" }, .{ .name = "content-type", .value = "text-plain" } };

                        strm.sendHeaders(reply[0..], false) catch {};
                        strm.write("i wonder but kalao", "hello world", true) catch {};
                    }
                }.cb);

                stream.onData(struct {
                    pub fn cb(strm: *Stream, head: frames.Head) void {
                        _ = head;
                        var buf = [_]u8{0} ** 512;
                        var n = strm.read(buf[0..]) catch @panic("err reading");

                        while (n > 0) {
                            n = strm.read(buf[0..]) catch @panic("err reading");
                            std.debug.print("Data: {s}, [{}]\n", .{ buf[0..n], n });
                        }
                    }
                }.cb);

                stream.onRst(struct {
                    pub fn cb(strm: *Stream, code: Code) void {
                        _ = strm;

                        std.debug.print("RST: code[{}]\n", .{code});
                    }
                }.cb);
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
}

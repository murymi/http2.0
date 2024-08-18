const std = @import("std");
const Stream = @import("stream.zig");
const hpack = @import("hpack.zig");
const frames = @import("frames.zig");
const Allocator = std.mem.Allocator;
const errcodes = @import("errors.zig");


streams: std.AutoHashMap(u31, Stream),
settings: frames.Settings = .{},
stream: std.net.Stream,
allocator: Allocator,
streamidx: usize = 0,

parse_buff: [4096]u8 = [_]u8{0} ** 4096,
build_buff: [4096]u8 = [_]u8{0} ** 4096,
recv_buff: [4096]u8 = [_]u8{0} ** 4096,

ctx: hpack.Tables,
builder: hpack.Builder,
parser: hpack.Parser,
contype: Type,

pending_pongs: std.AutoArrayHashMap([8]u8, void),
pending_settings: usize = 0,
closing: bool = false,
//std.ArrayList(frames.Ping.Ping),

pub const Type = enum { server, client };

const Self = @This();

pub fn init(allocator: Allocator, stream: std.net.Stream, contype: Type) !Self {
    var self: Self = undefined;
    self.contype = contype;
    self.settings = .{};
    self.pending_pongs = std.AutoArrayHashMap([8]u8, void).init(allocator);

    // waiting for one ack
    self.pending_settings = 1;

    if (self.contype == .server) {
        const n = try stream.reader().readAll(self.recv_buff[0..24]);
        std.debug.assert(n == 24);
        std.debug.assert(std.mem.eql(u8, self.recv_buff[0..n], "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"));
        try self.settings.write(stream.writer(), false);
    } else {
        self.settings.enable_push = 0;
        try self.stream.writer().writeAll("PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n");
        try self.settings.write(stream.writer(), false);
        const head = try frames.Head.read(stream.reader());
        std.debug.assert(head.ty == .settings and !head.flags.ack);
        self.settings = try frames.Settings.read(stream.reader(), self.settings, head.len);
        try frames.Settings.writeAck(stream.writer());
    }

    self.stream = stream;
    self.streams = std.AutoHashMap(u31, Stream).init(allocator);
    self.allocator = allocator;

    self.ctx = try hpack.Tables.init(allocator);
    self.parser = hpack.Parser.init(&self.ctx, self.parse_buff[0..]);
    self.builder = hpack.Builder.init(&self.ctx, self.build_buff[0..]);

    return self;
}

pub fn openStream(self: *Self, id: u31) !void {
    const stream = Stream{
        .id = id,
        .parent = self,
        //.settings = .{},
        .state = .open,
    };
    try self.streams.put(id, stream);
}

pub fn processFrames(self: *Self) !void {
    //std.debug.print("********************\n", .{});
    //try self.ping([_]u8{1,2,3,4,5,6,7,8});


    while (true) {
        const head = try frames.Head.read(self.stream.reader());
    std.debug.print("NEW FRAME: {}\n", .{head.ty});

        switch (head.ty) {
            .goaway => {
                const payload = try frames.GoAway.read(self.stream.reader(), head);
                std.debug.print("GOAWAY code: {} lastid: {}\n", .{payload.code, payload.last_id});
                //try frames.GoAway.write(self.stream.writer(), .{ .code = .no_error, .last_id = @truncate(head.streamid) });
                break;
            },
            .headers => {

                const affected_stream = if (self.streams.getPtr(head.streamid)) |stream| blk: {
                    if (stream.state != .open) @panic("Invalid state to receive headers");
                    break :blk stream;
                } else blk: {
                    try self.openStream(head.streamid);
                    break :blk self.streams.getPtr(head.streamid).?;
                };

                var headerbuff = [_]hpack.HeaderField{.{}} ** 100;
                var hproc = frames.Headers{ .builder = &self.builder, .parser = &self.parser };
                const headers = try hproc.readAndParse(self.stream.reader(), head, headerbuff[0..]);

                if (head.flags.ack) {
                    affected_stream.transition(.recveos);
                    std.debug.print("END OF STREAM HEADERS: {}\n", .{head});
                }

                for (headers) |value| {
                    std.debug.print("{s}: {s}\n", .{ value.name, value.value });
                }

                var reply = [_]hpack.HeaderField{
                    .{.name = ":status", .value = "200"},
                    .{.name = "content-type", .value = "text-plain" }
                };

                //try affected_stream.ok(false);
                try affected_stream.sendHeaders(reply[0..], false);
                try affected_stream.write("i wonder but kalao", "hello world", true);

                //try hproc.write(self.stream.writer(), 10000, reply[0..], head.streamid, false);
                //try self.goAway(1, .protocol_error, "Tumekanjo");

                if (affected_stream.closing()) break;
            },
            .settings => {
                std.debug.print("SETTINGS {}\n", .{head.len});
                if (head.streamid != 0) @panic("SETTING: stream id not 0");
                if (!head.flags.ack) {
                    self.settings = try frames.Settings.read(self.stream.reader(), self.settings, head.len);
                    std.debug.print("writing ack...\n", .{});
                    try frames.Settings.writeAck(self.stream.writer());
                } else {
                    std.debug.assert(head.len == 0);
                    if(self.pending_settings > 0) self.pending_settings -= 1;
                    std.debug.print("received ack...\n", .{});
                }
                //if(self.closing) break;
            },
            .ping => {
                var payload = try frames.Ping.read(self.stream.reader(), head);
                if (!head.flags.ack) try frames.Ping.pong(self.stream.writer(), payload);

                if(head.flags.ack) {
                    if(!self.pending_pongs.orderedRemove(payload)) {
                        std.debug.panic("invalid pong: {s}\n", .{&payload});
                    }
                }
                std.debug.print("payload: {any}\n", .{std.mem.asBytes(&payload).*});

                //if(self.closing) break;
            },
            .rst => {
                const affected_stream = self.streams.getPtr(head.streamid);
                const rst = try frames.Rst.read(self.stream.reader());
                
                std.debug.print("RST: code: {} ...\n", .{rst.code});
                if (affected_stream) |s| {
                    if(s.state != .idle) {
                        s.transition(.recvrst);
                        self.pending_pongs.clearAndFree();
                        self.pending_settings = 0;
                    } else unreachable;
                } else @panic("RST: Stream not found");

                break;
            },
            .data => {  
                var buf = [_]u8{0} ** 256;
                std.debug.print("Data: reciving: {}\n", .{head});
                //var stream = std.io.fixedBufferStream(buf[0..]);
                //try frames.Data.read(self.stream.reader(), stream.writer(), head);

                const affected_stream = self.streams.getPtr(head.streamid) orelse @panic("DATA: stream not found");

                try affected_stream.setReadable(head);
                var n = try affected_stream.read(buf[0..]);

                while (n > 0) {
                    n = try affected_stream.read(buf[0..]);
                std.debug.print("Data: {s}, [{}]\n", .{buf[0..n], n});
                }


                //try frames.Data.writeEmpty(self.stream.writer(), head.streamid);


                if(affected_stream.closing()) break;
            },
            .priority => {
                try self.stream.reader().skipBytes(head.len, .{});
            },
            .continuation, .pushpromise, .windowupdate => |f| std.debug.panic("UNHANDLED: {}\n", .{f}),
        }

        if(self.closing) break;
    }
}

pub fn ping(self: *Self, payload: [8]u8) !void {
    try self.pending_pongs.put(payload, {});
    try frames.Ping.ping(self.stream.writer(), payload);
}

pub fn pong(self: *Self, payload: [8]u8) !void {
    try frames.Ping.pong(self.stream.writer(), payload);
}

pub fn close(self: *Self) !void {
    self.closing = true;
    while(self.pending_pongs.count() != 0 or self.pending_settings != 0){
        std.debug.print("Finishing: --- [p:{},s:{}]\n", .{self.pending_pongs.count(), self.pending_settings});
        try self.processFrames();
    }
    self.stream.close();
}

pub fn goAway(self: *Self, last_processed_id: u31, code: errcodes.Code, debug_info: ?[]const u8) !void {
    _ = self.streams.getPtr(last_processed_id) orelse @panic("invalid stream id");
    if(self.contype == .server) {
        const payload =[_]u8{'c', 'l', 'o', 's', 'i', 'n', 'g', '!'};
        try self.ping(payload);
        while(self.pending_pongs.get(payload)) |_| try self.processFrames();
    }

    try frames.GoAway.write(self.stream.writer(), frames.GoAway.PayLoad{.code = code, .debug_info = debug_info, .last_id = last_processed_id});
    self.stream.close();
}

pub fn updateWindow(self: *Self, increment: u31) void {
    try frames.WindowUpdate.write(self.stream.writer(), 0, increment);
}

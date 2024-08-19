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
streamoffset: u31 = 0,

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

pingcb:?*const PingCallBack = null,
streamcb: ?*const StreamCallBack = null,
settingscb: ?*const SettingsCallBack = null,
goawaycb: ?*const GoAwayCallBack = null,
ppcb: ?*const PushPromiseCallBack = null,
//std.ArrayList(frames.Ping.Ping),

pub const StreamCallBack = fn (*Stream) void;
pub const PingCallBack = fn (*Self, payload: [8]u8) void;
pub const SettingsCallBack = fn (*Self, frames.Settings) void;
pub const GoAwayCallBack = fn (*Self, frames.GoAway.PayLoad) void;
pub const PushPromiseCallBack = fn (*Stream, []hpack.HeaderField) void;


pub const Type = enum { server, client };

const Self = @This();

pub fn init(allocator: Allocator, stream: std.net.Stream, contype: Type) !Self {
    var self: Self = undefined;
    self.pingcb = null;
    self.streamcb = null;
    self.settingscb = null;
    self.goawaycb = null;
    self.ppcb = null;
    self.contype = contype;
    self.settings = .{};
    self.pending_pongs = std.AutoArrayHashMap([8]u8, void).init(allocator);

    // waiting for one ack
    self.pending_settings = 1;
    self.stream = stream;
    self.streams = std.AutoHashMap(u31, Stream).init(allocator);

    if (self.contype == .server) {
        const n = try stream.reader().readAll(self.recv_buff[0..24]);
        std.debug.assert(n == 24);
        std.debug.assert(std.mem.eql(u8, self.recv_buff[0..n], "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"));
        try self.settings.write(stream.writer(), false);
    } else {
        self.settings.enable_push = 1;
        try self.stream.writer().writeAll("PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n");
        try self.settings.write(stream.writer(), false);
        const head = try frames.Head.read(stream.reader());
        std.debug.assert(head.ty == .settings and !head.flags.ack);
        self.settings = try frames.Settings.read(stream.reader(), self.settings, head.len);
        try frames.Settings.writeAck(stream.writer());
        try self.openStream(1);
    }

    self.streamoffset = 0;

    self.allocator = allocator;

    self.ctx = try hpack.Tables.init(allocator, self.settings.header_table_size);
    self.parser = hpack.Parser.init(&self.ctx, self.parse_buff[0..]);
    self.builder = hpack.Builder.init(&self.ctx, self.build_buff[0..]);

    return self;
}

pub fn onStream(self: *Self, cb: *const StreamCallBack) void {
    self.streamcb = cb;
}

pub fn onPing(self: *Self, cb: *const PingCallBack) void {
    self.pingcb = cb;
}

pub fn onSettings(self: *Self, cb: *const SettingsCallBack) void {
    self.settingscb = cb;
}

pub fn onGoAway(self: *Self, cb: *const GoAwayCallBack) void {
    self.goawaycb = cb;
}

pub fn onPushPromise(self: *Self, cb: *const PushPromiseCallBack) void {
    self.ppcb = cb;
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
    while (true) {
        const head = try frames.Head.read(self.stream.reader());
    //std.debug.print("NEW FRAME: {any}\n", .{head.ty});

        switch (head.ty) {
            .goaway => {
                const payload = try frames.GoAway.read(self.stream.reader(), head);
                if(self.goawaycb) |cb| cb(self, payload);
                break;
            },
            .headers => {
                const affected_stream = if (self.streams.getPtr(head.streamid)) |stream| blk: {
                    if(!stream.opening()) @panic("Invalid state to receive headers");
                    break :blk stream;
                } else blk: {
                    try self.openStream(head.streamid);
                    break :blk self.streams.getPtr(head.streamid).?;
                };

                var headerbuff = [_]hpack.HeaderField{.{}} ** 100;
                var hproc = frames.Headers{ .builder = &self.builder, .parser = &self.parser };
                const headers = try hproc.readAndParse(self.stream.reader(), head, headerbuff[0..]);
                if (head.flags.ack) affected_stream.transition(.recveos);
                if(self.streamcb) |cb| cb(affected_stream);
                if(affected_stream.headerscb) |cb| cb(headers, affected_stream);
                if (affected_stream.closing()) break;
            },
            .settings => {
                if (head.streamid != 0) @panic("SETTING: stream id not 0");
                if (head.flags.ack) {                    std.debug.assert(head.len == 0);
                    if(self.pending_settings > 0) self.pending_settings -= 1;
                    //std.debug.print("received ack...\n", .{});
                } else {
                    self.settings = try frames.Settings.read(self.stream.reader(), self.settings, head.len);
                    if(self.settingscb) |cb| cb(self, self.settings);
                }
            },
            .ping => {
                var payload = try frames.Ping.read(self.stream.reader(), head);
                if(head.flags.ack) {
                    if(!self.pending_pongs.orderedRemove(payload)) {
                        std.debug.panic("invalid pong: {s}\n", .{&payload});
                    }
                } else {
                    if(self.pingcb) |cb| cb(self, payload) else
                    try frames.Ping.pong(self.stream.writer(), payload);
                }
            },
            .rst => {
                const affected_stream = self.streams.getPtr(head.streamid);
                const rst = try frames.Rst.read(self.stream.reader());
                
                //std.debug.print("RST: code: {} ...\n", .{rst.code});
                if (affected_stream) |s| {

                    if(s.rstcb) |cb| cb(s, rst.code);

                    if(s.state != .idle) {
                        s.transition(.recvrst);
                        self.pending_pongs.clearAndFree();
                        self.pending_settings = 0;
                    } else unreachable;
                } else @panic("RST: Stream not found");

                break;
            },
            .data => {  
                //std.debug.print("Data: reciving: {}\n", .{head});
                const affected_stream = self.streams.getPtr(head.streamid) orelse @panic("DATA: stream not found");
                try affected_stream.setReadable(head);
                if(affected_stream.datacb) |cb| cb(affected_stream, head);
                std.debug.assert(affected_stream.datastate == .idle);
                if(affected_stream.closing()) break;
            },
            .priority => {
                try self.stream.reader().skipBytes(head.len, .{});
            },
            .pushpromise => {
                std.debug.print("PP len: {}\n", .{head.len});
                var pproc = frames.PushPromise{.builder = &self.builder, .parser = &self.parser};
                var headerbuff = [_]hpack.HeaderField{.{}} ** 100;
                const promise = try pproc.readAndParse(self.stream.reader(), head, headerbuff[0..]);
                try self.openStream(promise.streamId);
                const stream = self.streams.getPtr(promise.streamId).?;
                if(self.ppcb) |cb| cb(stream, promise.headers);
                //for(promise.headers) |h| h.display();
            },
            .windowupdate => |f| std.debug.panic("UNHANDLED: {}\n", .{f}),
            .continuation => unreachable
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
        //std.debug.print("Finishing: --- [p:{},s:{}]\n", .{self.pending_pongs.count(), self.pending_settings});
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

pub fn acceptSettings(self: *Self) !void {
    try frames.Settings.writeAck(self.stream.writer());
}

pub fn resizeDynamicTable(self: *Self) void {
    self.ctx.dynamic_table.resize(self.settings.header_table_size);
}

pub fn request(self: *Self, headers: []hpack.HeaderField) !*Stream {
    std.debug.assert(self.contype == .client);

    if(self.streamoffset == 0) {
        self.streamoffset = 1;
    } else {
        self.streamoffset += 2;
    }
    try self.openStream(self.streamoffset);
    var s = self.streams.getPtr(self.streamoffset).?;
    try s.sendHeaders(headers[0..], true);
    //std.debug.print("STATE: {}\n", .{s.state});
    //s.transition(.sendheaders);
    return s;
}



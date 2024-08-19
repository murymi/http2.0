const std = @import("std");
const frames = @import("frames.zig");
const Connection = @import("connection.zig");
const errors = @import("./errors.zig");
const hpack = @import("./hpack.zig");

pub const StreamState = enum {
    idle,
    reservedlocal,
    reservedremote,
    open,
    halfclosedlocal,
    halfclosedremote,
    closed,
};

pub const DataState = enum {
    recv_chunks,
    idle
};

pub const StreamTransition = enum { 
    recvpushpromise,
     sendpushpromise,
      recvheaders, 
      sendheaders, 
      recveos, 
      sendeos, 
      sendrst, 
      recvrst 
};

pub const HeadersCallBack = fn ([]hpack.HeaderField, *Stream) void;
pub const DataCallBack = fn (*Stream, frames.Head) void;
pub const RstCallBack = fn (*Stream, errors.Code) void;

const Stream = @This(); 

state: StreamState = .idle,
id: u31,
    //settings: frames.Settings,
parent: *Connection,
datastate: DataState = .idle,
head: frames.Head = .{.ty = .data, .len = 0, .streamid = 0, .flags = .{}},
paddlen: usize = 0,
remaining: usize = 0,


headerscb:?*const HeadersCallBack = null,
datacb:?*const DataCallBack = null,
rstcb:?*const RstCallBack = null,

// pub fn close(self: *Stream) void {
//         self.state = .closed;
//     }

pub fn onHeaders(self: *Stream, cb: *const HeadersCallBack) void {
    self.headerscb = cb;
}

pub fn onData(self: *Stream, cb: *const DataCallBack) void {
    self.datacb = cb;
}

pub fn onRst(self: *Stream, cb: *const RstCallBack) void {
    self.rstcb = cb;
}



    pub fn transition(self: *Stream, st: StreamTransition) void {
        self.state = switch (self.state) {
            .closed => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendheaders,
                .sendeos,
                .recveos,
                .recvheaders,
                .recvrst,
                .sendrst => @panic("invalid transition"),
            },
            .halfclosedlocal => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendheaders,
                .sendeos,
                .recvheaders => @panic("invalid transition"),
                .recveos,
                .recvrst,
                .sendrst => .closed,
            },
            .halfclosedremote => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendheaders,
                .recveos,
                .recvheaders => @panic("invalid transition"),
                .sendeos,
                .recvrst,
                .sendrst => .closed,
            },
            .idle => switch (st) {
                .sendpushpromise => .reservedlocal,
                .recvpushpromise => .reservedremote,
                .sendheaders,
                .recvheaders => .open,
                .sendeos,
                .recveos,
                .recvrst,
                .sendrst => @panic("invalid transition"),
            },
            .open => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendheaders,
                .recvheaders => @panic("invalid transition"),
                .recvrst,
                .sendrst => .closed,
                .sendeos => .halfclosedlocal,
                .recveos => .halfclosedremote,
            },
            .reservedlocal => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendeos,
                .recveos,
                .recvheaders => @panic("invalid transition"),
                .sendheaders => .halfclosedremote,
                .recvrst,
                .sendrst => .closed
            },
            .reservedremote => switch (st) {
                .sendpushpromise,
                .recvpushpromise,
                .sendheaders,
                .recveos,
                .sendeos => @panic("invalid transition"),
                .recvheaders => .halfclosedlocal,
                .recvrst,
                .sendrst => .closed,
            }
        };

        
}


pub fn terminate(self: *Stream, code: errors.Code) !void {
    if(self.state != .idle) {
        self.transition(.sendrst);
        try frames.Rst.write(self.id, code, self.parent.stream.writer());
    } else unreachable;
}

pub fn sendHeaders(self: *Stream, headers: []hpack.HeaderField, eos: bool) !void {
    var hproc = frames.Headers{ .builder = &self.parent.builder, .parser = &self.parent.parser };
    try hproc.write(
        self.parent.stream.writer(), 
        @truncate(self.parent.settings.max_header_list),
        headers[0..], self.id, eos);
    if(eos) self.transition(.sendeos);
}

/// send 200 OK
pub fn ok(self: *Stream, eos: bool) !void {
    var reply = [_]hpack.HeaderField{ 
        .{ .name = ":status", .value = "200" }
    };
    var hproc = frames.Headers{ .builder = &self.parent.builder, .parser = &self.parent.parser };
    try hproc.write(self.parent.stream.writer(), @truncate(self.parent.settings.max_header_list), reply[0..], self.id, eos);
    if(eos) self.transition(.sendeos);
}

pub fn setReadable(self: *Stream, head: frames.Head) !void {
    if (!(self.state == .open or self.state == .halfclosedlocal)) @panic("Invalid state to receive data");

    self.head = head;
    self.datastate = .recv_chunks;
    self.paddlen = if(head.flags.padded) try self.parent.stream.reader().readInt(u8, .big) else 0;
    self.remaining = head.len - self.paddlen;
}

pub fn read(self: *Stream, buf: []u8) !usize {
    std.debug.assert(self.datastate == .recv_chunks);
    if(self.remaining == 0) {
        try self.parent.stream.reader().skipBytes(self.paddlen, .{ .buf_size = 256 });
        if(self.head.flags.ack){
            self.transition(.recveos);
        }
        self.datastate = .idle;
        return 0;
    }
    const n = try self.parent.stream.readAll(buf[0..@min(buf.len, self.remaining)]);
    self.remaining -= n;
    return n;
}

pub fn write(self: *Stream, buf: []const u8,padding: []const u8, eos: bool) !void {
    //std.debug.print("SENDING STATE: {}\n", .{self.state});
    if(!(self.state == .halfclosedremote or self.state == .open)) @panic("Invalid state to send data");
    //std.debug.print("**********sending chunk*****************\n", .{});
    try frames.Data.write(self.parent.stream.writer(),self.id, buf, padding, eos);
}

pub fn closing(self: *Stream) bool {
    //std.debug.print("STATE: {},,,\n", .{self.state});
    return self.state == .halfclosedremote or self.state == .closed;
}

pub fn opening(self: *Stream) bool {
    return self.state == .halfclosedlocal or self.state == .open;
}

pub fn windowUpdate(self: *Stream, increment: u31) !void {
    try frames.WindowUpdate.write(self.parent.stream.writer(), self.id, increment);
}

pub fn pushRequest(self: *Stream, headers: []hpack.HeaderField) !*Stream {
    std.debug.assert(self.parent.settings.enable_push == 1);
    std.debug.assert(self.parent.contype == .server);
    std.debug.assert(self.state == .open or self.state == .halfclosedremote);
    std.debug.assert(self.parent.streamoffset < self.parent.settings.max_concurrent_streams);

    if(self.parent.streamoffset == 0) {
        self.parent.streamoffset = 2;
    } else {
        self.parent.streamoffset += 2;
    }
    try self.parent.openStream(self.parent.streamoffset);
    const s = self.parent.streams.getPtr(self.parent.streamoffset).?;
    var pproc = frames.PushPromise{.builder = &self.parent.builder, .parser = &self.parent.parser};
    try pproc.write(self.parent.stream.writer(), self.id, s.id, @truncate(self.parent.settings.header_table_size), headers);
    return s;
    //try s.sendHeaders(headers[0..], true);
}
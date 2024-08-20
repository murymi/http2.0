const std = @import("std");
const hpack = @import("../main.zig");

pub const StreamState = enum {
    idle,
    reservedlocal,
    reservedremote,
    open,
    halfclosedlocal,
    halfclosedremote,
    closed,
};

pub const StreamTransition = enum { recvpushpromise, sendpushpromise, recvheaders, sendheaders, recveos, sendeos, sendrst, recvrst };

pub const Stream = struct {
    state: StreamState = .idle,
    id: u32,

    pub fn transition(self: *Stream, st: StreamTransition) void {
        self.state = switch (self.state) {
            .closed => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendheaders, .sendeos, .recveos, .recvheaders, .recvrst, .sendrst => @panic("invalid transition"),
            },
            .halfclosedlocal => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendheaders, .sendeos, .recvheaders => @panic("invalid transition"),
                .recveos, .recvrst, .sendrst => .closed,
            },
            .halfclosedremote => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendheaders, .recveos, .recvheaders => @panic("invalid transition"),
                .sendeos, .recvrst, .sendrst => .closed,
            },
            .idle => switch (st) {
                .sendpushpromise => .reservedlocal,
                .recvpushpromise => .reservedremote,
                .sendheaders, .recvheaders => .open,
                .sendeos, .recveos, .recvrst, .sendrst => @panic("invalid transition"),
            },
            .open => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendheaders, .recvheaders => @panic("invalid transition"),
                .recvrst, .sendrst => .closed,
                .sendeos => .halfclosedlocal,
                .recveos => .halfclosedremote,
            },
            .reservedlocal => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendeos, .recveos, .recvheaders => @panic("invalid transition"),
                .sendheaders => .halfclosedremote,
                .recvrst, .sendrst => .closed,
            },
            .reservedremote => switch (st) {
                .sendpushpromise, .recvpushpromise, .sendheaders, .recveos, .sendeos => @panic("invalid transition"),
                .recvheaders => .halfclosedlocal,
                .recvrst, .sendrst => .closed,
            },
        };
    }
};

pub fn main() !void {
    var a = Stream{ .state = .reservedlocal };

    a.transition(.recvrst);

    std.debug.print("{}\n", .{a.state});
}

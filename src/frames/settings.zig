const std = @import("std");

const Head = @import("../frames.zig").Head;

//pub const Setting

pub const Settings = struct {
    // 0x01
    header_table_size: u32 = 4096,
    // 0x02
    enable_push: u32 = 0,
    // 0x03
    max_concurrent_streams: u32 = 100,
    // 0x04
    initial_window_size: u32 = 65535,
    // 0x05
    max_frame_size: u32 = 16384,
    // 0x06
    max_header_list: u32 = std.math.maxInt(u32),

    pub fn writeAck(stream: anytype) !void {
        var header = Head{
            .flags = .{ .ack = true },
            .len = 0,
            .streamid = 0,
            .ty = .settings,
        };
        try header.write(stream);
    }

    pub fn write(self: *Settings, stream: anytype, ack: bool) !void {
        var header = Head{
            .flags = .{ .ack = ack },
            .len = if(!ack) 6 * 6 else 0,
            .streamid = 0,
            .ty = .settings,
        };

        try header.write(stream);
        if (!ack) {
            const T = @typeInfo(Settings);
            inline for (T.Struct.fields, 1..) |f, i| {
                try stream.writeInt(u16, @intCast(i), .big);
                try stream.writeInt(u32, @field(self, f.name), .big);
            }
        }
    }

    pub fn read(stream: anytype, old: Settings, len: usize) !Settings {
        var s = old;
        if (len % 6 != 0) std.debug.panic("invalid setting size: {}", .{len});
        for (0..len / 6) |_| {
            switch (try stream.readInt(u16, .big)) {
                0x01 => s.header_table_size = try stream.readInt(u32, .big),
                0x02 => s.enable_push = (try stream.readInt(u32, .big)),
                0x03 => s.max_concurrent_streams = try stream.readInt(u32, .big),
                0x04 => s.initial_window_size = try stream.readInt(u32, .big),
                0x05 => s.max_frame_size = try stream.readInt(u32, .big),
                0x06 => s.max_header_list = try stream.readInt(u32, .big),
                else => @panic("invalid setting"),
            }
        }
        return s;
    }
};

pub fn update(self: *Settings, new: Settings) void {
    const T = @typeInfo(Settings);
    inline for (T.Struct.fields) |f| @field(self, f.name) = @field(new, f.name);
}

pub fn main() !void {
    var s = Settings{};
    var buf = [_]u8{0} ** 256;
    var b = std.io.fixedBufferStream(buf[0..]);
    try s.write(b.writer(), true);

    b.pos = 0;

    //s.read(b.reader(), 4);
    const h = try Head.read(b.reader());

    const set = try Settings.read(b.reader(), h.len);

    std.debug.print("{}\n", .{h});

    std.debug.print("{}\n", .{set});
}

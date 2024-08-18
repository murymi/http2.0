const std = @import("std");
const Map = std.AutoHashMap;
const whash = std.hash.Wyhash;

table: std.HashMap(HeaderField, usize, HashCtx, 75),
//Map(HeaderField, usize),

const HashCtx = struct {
    pub fn hash(_: HashCtx, header: HeaderField) u64 {
        var hashfn = whash.init(0);
        hashfn.update(header.name);
        hashfn.update(header.value);
        return hashfn.final();
    }

    pub fn eql(_: HashCtx, a: HeaderField, b: HeaderField) bool {
        var hashfn = whash.init(0);
        hashfn.update(a.name);
        hashfn.update(a.value);
        const ha = hashfn.final();
        hashfn = whash.init(0);
        hashfn.update(b.name);
        hashfn.update(b.value);
        return ha == hashfn.final();
    }
};

const Self = @This();
pub const size = headers.len;

pub fn init(allocator: std.mem.Allocator) !Self {
    var table =
        std.HashMap(HeaderField, usize, HashCtx, 75).init(allocator);
    //Map(HeaderField, usize).init(allocator);
    for (headers, 1..) |h, i| {
        try table.put(h, i);
    }
    return Self{ .table = table };
}

pub fn deinit(self: *Self) void {
    self.table.deinit();
}

pub inline fn getByValue(self: *Self, field: HeaderField) ?usize {
    // for(headers, 0..)|h, i| {
    //     //std.debug.print("{s} -> {s}\n", .{h.name, field.name});
    //     if(std.mem.eql(u8, field.name, h.name) and std.mem.eql(u8, field.value, h.value))
    //         return i + 1;
    // }
    // return null;
    return self.table.get(field);
}

pub inline fn get(idx: usize) ?HeaderField {
    return headers[idx];
}

pub const HeaderField = struct {
    name: []const u8 = "",
    value: []const u8 = "",

    pub fn size(self: *const HeaderField) usize {
        return self.name.len + self.value.len + 32;
    }

    pub fn eql(self: *const HeaderField, h: HeaderField) bool {
        return std.mem.eql(u8, self.name, h.name) and
            std.mem.eql(u8, self.value, h.value);
    }
};

pub const headers = [_]HeaderField{ .{ .name = ":authority" }, .{ .name = ":method", .value = "GET" }, .{ .name = ":method", .value = "POST" }, .{ .name = ":path", .value = "/" }, .{ .name = ":path", .value = "/index.html" }, .{ .name = ":scheme", .value = "http" }, .{ .name = ":scheme", .value = "https" }, .{ .name = ":status", .value = "200" }, .{ .name = ":status", .value = "204" }, .{ .name = ":status", .value = "206" }, .{ .name = ":status", .value = "304" }, .{ .name = ":status", .value = "400" }, .{ .name = ":status", .value = "404" }, .{ .name = ":status", .value = "500" }, .{ .name = "accept-charset" }, .{ .name = "accept-encoding", .value = "gzip, deflate" }, .{ .name = "accept-language" }, .{ .name = "accept-ranges" }, .{ .name = "accept" }, .{ .name = "access-control-allow-origin" }, .{ .name = "age" }, .{ .name = "allow" }, .{ .name = "authorization" }, .{ .name = "cache-control" }, .{ .name = "content-disposition" }, .{ .name = "content-encoding" }, .{ .name = "content-language" }, .{ .name = "content-length" }, .{ .name = "content-location" }, .{ .name = "content-range" }, .{ .name = "content-type" }, .{ .name = "cookie" }, .{ .name = "date" }, .{ .name = "etag" }, .{ .name = "expect" }, .{ .name = "expires" }, .{ .name = "from" }, .{ .name = "host" }, .{ .name = "if-match" }, .{ .name = "if-modified-since" }, .{ .name = "if-none-match" }, .{ .name = "if-range" }, .{ .name = "if-unmodified-since" }, .{ .name = "last-modified" }, .{ .name = "link" }, .{ .name = "location" }, .{ .name = "max-forwards" }, .{ .name = "proxy-authenticate" }, .{ .name = "proxy-authorization" }, .{ .name = "range" }, .{ .name = "referer" }, .{ .name = "refresh" }, .{ .name = "retry-after" }, .{ .name = "server" }, .{ .name = "set-cookie" }, .{ .name = "strict-transport-security" }, .{ .name = "transfer-encoding" }, .{ .name = "user-agent" }, .{ .name = "vary" }, .{ .name = "via" }, .{ .name = "www-authenticate" } };

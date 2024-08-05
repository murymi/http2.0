const std= @import("std");
const Map = std.AutoHashMap;



table: Map(usize, HeaderField),

const Self = @This();
pub const size = headers.len;

pub fn init(allocator: std.mem.Allocator) !Self {
    var table = Map(usize, HeaderField).init(allocator);
    for(headers, 0..) |h, i| {
        try table.put(i, h);
    }
    return Self{.table = table};
}

pub fn deinit(self: *Self) void {
    self.table.deinit();
}

pub fn getByValue(field: HeaderField) ?usize {
    for(headers, 0..)|h, i| {
        //std.debug.print("{s} -> {s}\n", .{h.name, field.name});
        if(std.mem.eql(u8, field.name, h.name) and std.mem.eql(u8, field.value, h.value))
            return i + 1;
    }
    return null;
}

pub fn get(self: *Self, idx: usize) ?HeaderField {
    return self.table.get(idx);
}

pub const HeaderField = struct {
    name: []const u8,
    value: []const u8 = "",

    pub fn size(self: *const HeaderField) usize {
        return self.name.len + self.value.len + 32;
    }
};

const headers = [_]HeaderField{
        .{.name = ":authority"},
        .{.name = ":method", .value= "GET"},
        .{.name = ":method", .value = "POST"},
        .{.name = ":path", .value= "/"},
        .{.name = ":path", .value= "/index.html"},
        .{.name = ":scheme", .value = "http"},
        .{.name = ":scheme", .value = "https"},
        .{.name = ":status", .value = "200"},
        .{.name = ":status", .value = "204"},
        .{.name = ":status", .value = "206"},
        .{.name = ":status", .value = "304"},
        .{.name = ":status", .value = "400"},
        .{.name = ":status", .value = "404"},
        .{.name = ":status", .value = "500"},
        .{.name = "accept-charset"},
        .{.name = "accept-encoding", .value = "gzip, deflate"},
        .{.name = "accept-language"},
        .{.name = "accept-ranges"},
        .{.name = "accept"},
        .{.name = "access-control-allow-origin"},
        .{.name = "age"},
        .{.name = "allow"},
        .{.name = "authorization"},
        .{.name = "cache-control"},
        .{.name = "content-disposition"},
        .{.name = "content-encoding"},
        .{.name = "content-language"},
        .{.name = "content-length"},
        .{.name = "content-location"},
        .{.name = "content-range"},
        .{.name = "content-type"},
        .{.name = "cookie"},
        .{.name = "date"},
        .{.name = "etag"},
        .{.name = "expect"},
        .{.name = "expires"},
        .{.name = "from"},
        .{.name = "host"},
        .{.name = "if-match"},
        .{.name = "if-modified-since"},
        .{.name = "if-none-match"},
        .{.name = "if-range"},
        .{.name = "if-unmodified-since"},
        .{.name = "last-modified"},
        .{.name = "link"},
        .{.name = "location"},
        .{.name = "max-forwards"},
        .{.name = "proxy-authenticate"},
        .{.name = "proxy-authorization"},
        .{.name = "range"},
        .{.name = "referer"},
        .{.name = "refresh"},
        .{.name = "retry-after"},
        .{.name = "server"},
        .{.name = "set-cookie"},
        .{.name = "strict-transport-security"},
        .{.name = "transfer-encoding"},
        .{.name = "user-agent"},
        .{.name = "vary"},
        .{.name = "via"},
        .{.name = "www-authenticate"}
};
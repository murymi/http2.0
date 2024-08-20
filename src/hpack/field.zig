const HeaderField = @import("static_table.zig").HeaderField;

pub fn getHeaderFieldLen(headers: []HeaderField) usize {
    var l: usize = 0;
    for (headers) |h| l += h.size();
    return l;
}

fn cmp(_: void, lhs: HeaderField, rhs: HeaderField) bool {
    return lhs.size() > rhs.size();
}

pub const SliceResult = struct {
    a: []HeaderField,
    b: []HeaderField,
};

pub fn sliceOnFieldlen(headers: []HeaderField, max: usize) SliceResult {
    var l: usize = 0;
    for (headers, 0..) |value, i| {
        if (value.size() + l > max) {
            const res = SliceResult{ .a = headers[0..i], .b = headers[i..] };
            if (res.a.len == 0)
                @panic("failed to find headers of max size and below");
            return res;
        }
        l += value.size();
    }

    if (l != getHeaderFieldLen(headers))
        @panic("failed to find headers of max size and below");

    return .{ .a = headers[0..], .b = headers[0..0] };
}

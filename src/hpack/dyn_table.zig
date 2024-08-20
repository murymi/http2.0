const std = @import("std");
const static = @import("static_table.zig");
const List = std.ArrayList(HeaderField);
const HeaderField = static.HeaderField;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

set_capcity: usize = 4096,
capacity: usize = 0,
max_capacity: usize,
table: List,

const Self = @This();

pub fn init(allocator: std.mem.Allocator, max_capacity: usize) Self {
    return Self{ .max_capacity = max_capacity, .table = List.init(allocator), .set_capcity = max_capacity };
}

pub fn deinit(self: *Self) void {
    self.table.deinit();
}

pub fn put(self: *Self, header: HeaderField) !void {
    const header_size = header.size();
    var gap = self.max_capacity - self.capacity;

    if (header_size > self.max_capacity) {
        self.capacity = 0;
        return self.table.clearRetainingCapacity();
    } else if (header_size > gap) {
        while (header_size > gap) {
            const s = self.table.pop().size();
            gap += s;
            self.capacity -= s;
        }
    }

    try self.table.insert(0, header);
    self.capacity += header_size;
}

pub fn get(self: *Self, idx: usize) HeaderField {
    return self.table.items[idx];
}

pub fn getByValue(self: *Self, field: HeaderField) ?usize {
    for (self.table.items, static.size + 1..) |h, i| {
        if (std.mem.eql(u8, field.name, h.name) and std.mem.eql(u8, field.value, h.value))
            return i;
    }
    return null;
}

pub fn resize(self: *Self, new_size: u64) void {
    self.max_capacity = new_size;
    while (self.capacity > self.max_capacity) self.max_capacity -= self.table.pop().size();
}

pub fn clear(self: *Self) void {
    self.capacity = 0;
    self.table.clearRetainingCapacity();
}

const std = @import("std");
const math = std.math;
const testing = std.testing;
const codec = @import("codec.zig");
const stable = @import("static_table.zig");
const dtable = @import("dyn_table.zig");
const Allocator = std.mem.Allocator;

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

dynamic_table: dtable,
static_table: stable,
allocator: Allocator,
codec: codec,

pub fn init(allocator: Allocator, dynamic_capacity: usize) !@This() {
    return @This(){ .allocator = allocator, .dynamic_table = dtable.init(allocator, dynamic_capacity), .static_table = try stable.init(allocator), .codec = codec.init() };
}

pub fn get(self: *@This(), header: stable.HeaderField) ?usize {
    if (self.dynamic_table.getByValue(header)) |h| {
        return h;
    }
    if (self.static_table.getByValue(header)) |h|
        return h;
    return null;
}

pub fn at(self: *@This(), idx: usize) ?stable.HeaderField {
    if (idx >= stable.size + self.dynamic_table.table.items.len) return null;
    if (idx < stable.size) return stable.get(idx);
    return self.dynamic_table.table.items[idx - stable.size];
}

pub fn deinit(self: *@This()) void {
    self.dynamic_table.deinit();
    self.static_table.deinit();
}

pub fn clear(self: *@This()) void {
    self.dynamic_table.clear();
}

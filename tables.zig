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

pub fn init(allocator: Allocator) !@This() {
    return @This(){ .allocator = allocator, .dynamic_table = dtable.init(allocator, 2000), .static_table = try stable.init(allocator) };
}


pub fn get(self: *@This(), header: stable.HeaderField) ?usize {
    if (self.dynamic_table.getByValue(header)) |h| {
        return h;
    }
    if (stable.getByValue(header)) |h|
        return h;
    return null;
}

pub fn deinit(self: *@This()) void {
    self.dynamic_table.deinit();
    self.static_table.deinit();
}

pub fn clear(self: *@This()) void {
    self.dynamic_table.clear();
}

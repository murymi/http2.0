//pub const hpack = @import("hpack/main.zig");

const std = @import("std");
pub const Codec = @import("hpack/codec.zig");
pub const staticTable = @import("hpack/static_table.zig");
pub const DynamicTable = @import("hpack/dyn_table.zig");
pub const HeaderField = staticTable.HeaderField;
pub const Tables = @import("hpack/tables.zig");
pub const Builder = @import("hpack/builder.zig");
pub const Parser = @import("hpack/parser.zig");
pub const Field = @import("hpack/field.zig");

test {
    _ = std.testing.refAllDecls(Builder);
    _ = std.testing.refAllDecls(Tables);
    _ = std.testing.refAllDecls(Parser);
    _ = std.testing.refAllDecls(Codec);
}
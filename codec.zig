const codes = @import("codes.zig");
const std = @import("std");
const math = std.math;
const Malloc = std.mem.Allocator;

const hcodes = codes.huffman_codes;
const lens = codes.huffman_code_lengths;

const Self = @This();

tree: *Node,

pub fn init(allocator: std.mem.Allocator) !Self {
    var tree = try Node.init(allocator);
    for (hcodes, lens, 0..) |code, len, sym|
        try tree.insert(code, @truncate(sym), @intCast(len));
    return Self{.tree = tree};
}

pub fn deinit(self: *Self) void {
    self.tree.deinit();
}

pub fn encode(source: []const u8, output: []u8) ![]u8 {
    var buf = std.io.fixedBufferStream(output);
    var byteoffset: u8 = 0;
    var acc: u32 = 0;
    var idx: usize = 0;
    for (source) |value| {
        const codeseq = codes.huffman_codes[value];
        const codelen = codes.huffman_code_lengths[value];
        const rem: u8 = @intCast(32 - byteoffset);
        //std.debug.print("{} {} {} {}\n", .{buf.pos, output.len, source.len, i});
        if (rem == 0) {
            try buf.writer().writeInt(u32, acc, .big);
        } else if (rem == codelen) {
            acc <<= @intCast(codelen);
            acc |= codeseq;
            try buf.writer().writeInt(u32, acc, .big);
            idx += 4;
            byteoffset = 0;
            acc = 0;
        } else if (rem > codelen) {
            acc <<= @intCast(codelen);
            acc |= codeseq;
            byteoffset += codelen;
        } else if (rem < codelen) {
            acc <<= @intCast(rem);
            acc |= (codeseq >> @intCast(codelen - rem));
            try buf.writer().writeInt(u32, acc, .big);
            idx += 4;
            acc = codeseq & (math.pow(u32, 2, codelen - rem) - 1);
            byteoffset = codelen - rem;
        }
    }
    if (byteoffset != 0) {
        const f: u32 = 0xffffffff;
        acc <<= @intCast(32 - byteoffset);
        try buf.writer().writeInt(u32, (f >> @intCast(byteoffset)) | acc, .big);
        idx += std.mem.alignForward(u64, byteoffset, 8) / 8;
    }
    return output[0..idx];
}

const Node = struct {
    symbol: u16 = 0,
    bits: u8 = 0,
    left: ?*Node = null,
    right: ?*Node = null,
    malloc: Malloc,

    fn init(malloc: Malloc) !*Node {
        const self = try malloc.create(Node);
        self.* = .{ .malloc = malloc };
        return self;
    }

    fn isLeaf(self: *Node) bool {
        return self.left == null and self.left == null;
    }

    fn insert(self: *Node, c: u32, symbol: u16, len: u8) !void {
        //_ = symbol;
        var code = c << @intCast(32 - len);
        const mask: u32 = 0x80000000;
        var current = self;
        for (0..len) |_| {
            var new_node: ?*Node = null;
            if (mask & code > 0) {
                new_node = if (current.right) |n| n else blk: {
                    const n = try Node.init(self.malloc);
                    current.right = n;
                    break :blk n;
                };
            } else {
                new_node = if (current.left) |n| n else blk: {
                    const n = try Node.init(self.malloc);
                    current.left = n;
                    break :blk n;
                };
            }

            new_node.?.symbol = symbol;
            new_node.?.bits = len;
            //std.debug.print("{b} {}\n", .{new_node.?.symbol, new_node.?.bits});
            current = new_node.?;
            code <<= 1;
        }
    }

    fn getBranch(self: *Node, code: u8) *Node {
        if (code == 1) {
            return self.right.?;
        } else if (code == 0) {
            return self.left.?;
        }
        @panic("unfukabol");
    }

    fn debug(self: *Node) void {
        if (self.right) |r| r.debug();
        if (self.left) |l| l.debug();

        if (self.isLeaf())
            std.debug.print("leaf: {c}\n", .{self.symbol});
    }

    fn deinit(self: *Node) void {
        if (self.right) |r| r.deinit();
        if (self.left) |l| l.deinit();
        self.malloc.destroy(self);
    }
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn decode(self: *Self, input: []const u8, output: []u8) []u8 {
    var outidx: usize = 0;
    var t = self.tree;
    var bitlen: i32 = 0;
    for (input) |v| {
        var value = v;
        for (0..8) |_| {
            t = t.getBranch(value >> 7);
            if (t.isLeaf()) {
                if(t.symbol == hcodes[256]) @panic("EOS has been detected!!! call 911");
                output[outidx] = @truncate(t.symbol);
                bitlen += t.bits;
                t = self.tree;
                outidx += 1;
            }
            value <<= 1;
        }
    }
    return output[0..outidx];
}

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn encodeInt(value: u64, n: u4, buf: []u8) ![]u8 {
    std.debug.assert(n > 0);
    var stream = std.io.fixedBufferStream(buf);
    var v = value;
    const max_int = math.pow(usize, 2, n);
    if (value < max_int - 1) {
        try stream.writer().writeInt(u8, @intCast(value), .little);
    } else {
        try stream.writer().writeInt(u8, @intCast(max_int - 1), .little);
        v = v - (max_int - 1);
        while (v >= 128) : (v /= 128)
            try stream.writer().writeInt(u8, @intCast(v % 128 + 128), .little);
        try stream.writer().writeInt(u8, @intCast(v), .little);
    }
    return stream.buffer[0..stream.pos];
}

pub fn decodeInt(value: []const u8, n: u4, end: *usize) u64 {
    end.* = 1;
    const max_int = math.pow(usize, 2, n);
    var result = value[0] & (max_int - 1);
    if (result < max_int - 1) return result;
    var m: usize = 0;
    while (true) {
        const b = value[end.*];
        result = result + (b & 127) * math.pow(usize, 2, m);
        m = m + 7;
        if (b & 128 != 128) break;
        end.* += 1;
    }
    return result;
}

pub fn encodeBareString(string: []const u8, output: []u8) ![]u8 {
    output[0] = 0;
    var stream = std.io.fixedBufferStream(output);
    const a = try encodeInt(string.len, 7, output);
    stream.pos = a.len;
    try stream.writer().writeAll(string);
    return stream.buffer[0..stream.pos];
}

pub fn decodePlainString(source: []const u8, output: []u8) ![]u8 {
    var stream = std.io.fixedBufferStream(output);
    if (source[0] & 128 > 0) {
        std.debug.panic("Huffamn encoded\n", .{});
    } else {
        var end: usize = 0;
        const len = decodeInt(source, 7, &end);
        try stream.writer().writeAll(source[end .. len + 1]);
    }
    return output[0..stream.pos];
}

pub fn encodeHuffmanString(string: []const u8, output: []u8) ![]u8 {
    var stream = std.io.fixedBufferStream(output);
    const buf = try gpa.allocator().alloc(u8, string.len);
    defer gpa.allocator().free(buf);
    const hufstr = try encode(string, buf);
    const a = try encodeInt(hufstr.len, 7, output);
    stream.pos = a.len;
    try stream.writer().writeAll(hufstr);
    output[0] |= 128;
    return stream.buffer[0..stream.pos];
}

pub fn decodeHuffmanString(ctx: *Self, source: []const u8, output: []u8) []u8 {
    if (source[0] & 128 == 0)
        std.debug.panic("Plain string detected\n", .{});
    var end: usize = 0;
    const len = decodeInt(source, 7, &end);
    return ctx.decode(source[end .. len + 1], output);
}

pub fn decodeString(ctx: *Self, source: []const u8, output: []u8) ![]u8 {
    if(source[0] & 128 == 0) 
        return try decodePlainString(source, output);
    return ctx.decodeHuffmanString(source, output);
}

test "fuckin tree" {
    const tv1 = [_]u8{ '>', 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1 };
    const tv2 = [_]u8{ '?', 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 };
    const tv3 = [_]u8{ '@', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0 };
    const tv4 = [_]u8{ 'A', 1, 0, 0, 0, 0, 1 };
    const tv5 = [_]u8{ 'D', 1, 0, 1, 1, 1, 1, 1 };
    const tv6 = [_]u8{ 'Q', 1, 1, 0, 1, 1, 0, 0 };
    const tv7 = [_]u8{ 'm', 1, 0, 1, 0, 0, 1 };
    const tv8 = [_]u8{ ']', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 };

    const tvs = [_][]const u8{ tv1[0..], tv2[0..], tv3[0..], tv4[0..], tv5[0..], tv6[0..], tv7[0..], tv8[0..] };
    const malloc = gpa.allocator();
    var tree = try Node.init(malloc);
    for (hcodes, lens, 0..) |code, len, sym|
        try tree.insert(code, @truncate(sym), @intCast(len));
    for (tvs) |value| {
        var t = tree;
        for (value[1..]) |bit| {
            t = t.getBranch(bit);
        }
        try std.testing.expectEqual(value[0], t.symbol);
        try std.testing.expect(t.isLeaf());
    }
}

test "enc dec" {
    var bufs: [255][200]u8 = undefined;
    for (&bufs) |*value| {
        std.crypto.random.bytes(value[0..]);
    }

    const malloc = std.testing.allocator;
    var ctx = try Self.init(malloc);
    defer ctx.deinit();

    var enc = [_]u8{0} ** 1000;
    var dec = [_]u8{0} ** 1000;

    for (bufs[0..]) |buf| {
        const out = try encode(buf[0..], enc[0..]);
        const out2 = decode(&ctx, out, dec[0..]);
        try std.testing.expectEqual(buf.len, out2.len);
        try std.testing.expect(buf.len == out2.len);
        try std.testing.expectEqualSlices(u8, buf[0..], out2);
    }
}

test "leaf ones" {
    const malloc = gpa.allocator();
    var tree = try Node.init(malloc);
    for (hcodes, lens, 0..) |code, len, sym|
        try tree.insert(code, @truncate(sym), @intCast(len));

    var t = tree;
    for (0..24) |_| {
        t = t.getBranch(1);
        try std.testing.expect(!t.isLeaf());
    }
}

test "inteja" {
    var buf = [_]u8{0} ** 8;

    var a = try encodeInt(500, 3, buf[0..]);
    var out = decodeInt(a, 3);
    try std.testing.expect(out == 500);

    a = try encodeInt(500, 1, buf[0..]);
    out = decodeInt(a, 1);
    try std.testing.expect(out == 500);

    a = try encodeInt(500, 8, buf[0..]);
    out = decodeInt(a, 8);
    try std.testing.expect(out == 500);

    a = try encodeInt(50000000000, 8, buf[0..]);
    out = decodeInt(a, 8);
    try std.testing.expect(out == 50000000000);
}
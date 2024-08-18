const codes = @import("codes.zig");
const std = @import("std");
const math = std.math;
const Malloc = std.mem.Allocator;

const hcodes = codes.huffman_codes;
const lens = codes.huffman_code_lengths;

const Self = @This();

tree: *Node = undefined,
treeHeap: [256 * @sizeOf(Node)]Node = [1]Node{.{}} ** (256 * @sizeOf(Node)),
heapIdx: usize = 0,

pub fn init() Self {
    var self = Self{};
    self.tree = self.makeNode();
    for (hcodes, lens, 0..) |code, len, sym|
        try self.tree.insert(&self, code, @truncate(sym), @intCast(len));
    return self;
}

inline fn makeNode(self: *Self) *Node {
    self.treeHeap[self.heapIdx] = .{};
    self.heapIdx += 1;
    return &self.treeHeap[self.heapIdx - 1];
}

/// encode and return encoded length.
/// `buf` = writer
pub fn encode(source: []const u8, buf: anytype) !usize {
    var byteoffset: u8 = 0;
    var acc: u32 = 0;
    var idx: usize = 0;
    for (source) |value| {
        const codeseq = codes.huffman_codes[value];
        const codelen = codes.huffman_code_lengths[value];
        const rem: u8 = @intCast(32 - byteoffset);
        idx += codelen;
        if (rem == 0) {
            try buf.writeInt(u32, acc, .big);
        } else if (rem == codelen) {
            acc <<= @intCast(codelen);
            acc |= codeseq;
            try buf.writeInt(u32, acc, .big);
            byteoffset = 0;
            acc = 0;
        } else if (rem > codelen) {
            acc <<= @intCast(codelen);
            acc |= codeseq;
            byteoffset += codelen;
        } else if (rem < codelen) {
            acc <<= @intCast(rem);
            acc |= (codeseq >> @intCast(codelen - rem));
            try buf.writeInt(u32, acc, .big);
            acc = codeseq & (math.pow(u32, 2, codelen - rem) - 1);
            byteoffset = codelen - rem;
        }
    }
    if (byteoffset != 0) {
        const f: u32 = 0xffffffff;
        acc <<= @intCast(32 - byteoffset);
        acc = (f >> @intCast(byteoffset)) | acc;
        const bytes = std.mem.asBytes(&acc);
        const k = std.mem.alignForward(u64, byteoffset, 8) / 8;
        var n: usize = 4;
        for (0..k) |_| {
            try buf.writeInt(u8, bytes[n - 1], .big);
            n -= 1;
        }
    }
    return std.mem.alignForward(u64, idx, 8) / 8;
}

const Node = struct {
    symbol: u16 = 0,
    bits: u8 = 0,
    left: ?*Node = null,
    right: ?*Node = null,

    fn isLeaf(self: *Node) bool {
        return self.left == null and self.left == null;
    }

    fn insert(self: *Node, codec: *Self, c: u32, symbol: u16, len: u8) !void {
        //_ = symbol;
        var code = c << @intCast(32 - len);
        const mask: u32 = 0x80000000;
        var current = self;
        for (0..len) |_| {
            var new_node: ?*Node = null;
            if (mask & code > 0) {
                new_node = if (current.right) |n| n else blk: {
                    const n = codec.makeNode();
                    current.right = n;
                    break :blk n;
                };
            } else {
                new_node = if (current.left) |n| n else blk: {
                    const n = codec.makeNode();
                    current.left = n;
                    break :blk n;
                };
            }
            new_node.?.symbol = symbol;
            new_node.?.bits = len;
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
};

//var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn decode(self: *Self, input: []const u8, output: anytype) !usize {
    var outidx: usize = 0;
    var space: usize = 0;
    var t = self.tree;
    var bitlen: i32 = 0;
    for (input) |v| {
        var value = v;
        for (0..8) |_| {
            t = t.getBranch(value >> 7);
            if (t.isLeaf()) {
                if (t.symbol == hcodes[256]) @panic("EOS has been detected!!! call 911");
                try output.writeInt(u8, @truncate(t.symbol), .little);
                bitlen += t.bits;
                t = self.tree;
                outidx += 1;
            }
            value <<= 1;
        }
        space += 1;
    }
    return space;
}

pub fn encodeInt(value: u64, n: u4, stream: anytype) !usize {
    std.debug.assert(n > 0);
    var pos: usize = 0;
    var v = value;
    const max_int = math.pow(usize, 2, n);
    if (value < max_int - 1) {
        try stream.writeInt(u8, @intCast(value), .little);
        pos += 1;
    } else {
        try stream.writeInt(u8, @intCast(max_int - 1), .little);
        pos += 1;
        v = v - (max_int - 1);
        while (v >= 128) : (v /= 128) {
            try stream.writeInt(u8, @intCast(v % 128 + 128), .little);
            pos += 1;
        }
        try stream.writeInt(u8, @intCast(v), .little);
        pos += 1;
    }
    return pos;
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

pub fn decodePlainString(source: []const u8, stream: anytype) !usize {
    if (source[0] & 128 > 0) {
        std.debug.panic("Huffamn encoded\n", .{});
    }
    var end: usize = 0;
    const len = decodeInt(source, 7, &end);
    const slice = source[end .. len + 1];
    try stream.writer().writeAll();
    return slice.len;
}

pub fn decodeHuffmanString(ctx: *Self, source: []const u8, stream: anytype) usize {
    if (source[0] & 128 == 0)
        std.debug.panic("Plain string detected\n", .{});
    var end: usize = 0;
    const len = decodeInt(source, 7, &end);
    return ctx.decode(source[end .. len + 1], stream);
}

pub fn decodeString(ctx: *Self, source: []const u8, output: anytype) !usize {
    if (source[0] & 128 == 0)
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
    //const malloc = gpa.allocator();
    //var tree = try Node.init(malloc);
    //for (hcodes, lens, 0..) |code, len, sym|
    //    try tree.insert(code, @truncate(sym), @intCast(len));
    const codec = Self.init();
    for (tvs) |value| {
        var t = codec.tree;
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

    //const malloc = std.testing.allocator;
    var ctx = Self.init();
    //defer ctx.deinit();

    var enc = [_]u8{0} ** 1000;
    var dec = [_]u8{0} ** 1000;

    var encstream = std.io.fixedBufferStream(enc[0..]);
    var decstream = std.io.fixedBufferStream(dec[0..]);

    for (bufs[0..]) |buf| {
        defer {
            encstream.reset();
            decstream.reset();
        }
        const l = calcEncodedLength(buf[0..]);
        const out = try encode(buf[0..], encstream.writer());
        try std.testing.expectEqual(out, l);
        _ = try decode(&ctx, enc[0..out], decstream.writer());
        try std.testing.expectEqualSlices(u8, buf[0..], dec[0..buf.len]);
    }
}

pub fn calcEncodedLength(source: []const u8) usize {
    var idx: usize = 0;
    for (source) |value| {
        const codelen = codes.huffman_code_lengths[value];
        idx += codelen;
    }
    return std.mem.alignForward(u64, idx, 8) / 8;
}

test "leaf ones" {
    //const malloc = gpa.allocator();
    //var tree = try Node.init(malloc);
    //for (hcodes, lens, 0..) |code, len, sym|
    //    try tree.insert(code, @truncate(sym), @intCast(len));
    const codec = Self.init();
    var t = codec.tree;
    for (0..24) |_| {
        t = t.getBranch(1);
        try std.testing.expect(!t.isLeaf());
    }
}

test "inteja" {
    var buf = [_]u8{0} ** 8;
    var stream = std.io.fixedBufferStream(buf[0..]);

    var int: usize = 0;

    var a = try encodeInt(500, 3, stream.writer());
    var out = decodeInt(buf[0..a], 3, &int);
    try std.testing.expect(out == 500);
    stream.reset();

    a = try encodeInt(500, 1, stream.writer());
    out = decodeInt(buf[0..a], 1, &int);
    try std.testing.expect(out == 500);
    stream.reset();

    a = try encodeInt(500, 8, stream.writer());
    out = decodeInt(buf[0..a], 8, &int);
    try std.testing.expect(out == 500);
    stream.reset();

    a = try encodeInt(50000000000, 8, stream.writer());
    out = decodeInt(buf[0..a], 8, &int);
    try std.testing.expect(out == 50000000000);
    stream.reset();
}

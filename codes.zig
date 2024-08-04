pub const huffman_codes = [_]u32{
    0x1ff8,
    0x7fffd8,
    0xfffffe2,
    0xfffffe3,
    0xfffffe4,
    0xfffffe5,
    0xfffffe6,
    0xfffffe7,
    0xfffffe8,
    0xffffea,
    0x3ffffffc,
    0xfffffe9,
    0xfffffea,
    0x3ffffffd,
    0xfffffeb,
    0xfffffec,
    0xfffffed,
    0xfffffee,
    0xfffffef,
    0xffffff0,
    0xffffff1,
    0xffffff2,
    0x3ffffffe,
    0xffffff3,
    0xffffff4,
    0xffffff5,
    0xffffff6,
    0xffffff7,
    0xffffff8,
    0xffffff9,
    0xffffffa,
    0xffffffb,
    0x14,
    0x3f8,
    0x3f9,
    0xffa,
    0x1ff9,
    0x15,
    0xf8,
    0x7fa,
    0x3fa,
    0x3fb,
    0xf9,
    0x7fb,
    0xfa,
    0x16,
    0x17,
    0x18,
    0x0,
    0x1,
    0x2,
    0x19,
    0x1a,
    0x1b,
    0x1c,
    0x1d,
    0x1e,
    0x1f,
    0x5c,
    0xfb,
    0x7ffc,
    0x20,
    0xffb,
    0x3fc,
    0x1ffa,
    0x21,
    0x5d,
    0x5e,
    0x5f,
    0x60,
    0x61,
    0x62,
    0x63,
    0x64,
    0x65,
    0x66,
    0x67,
    0x68,
    0x69,
    0x6a,
    0x6b,
    0x6c,
    0x6d,
    0x6e,
    0x6f,
    0x70,
    0x71,
    0x72,
    0xfc,
    0x73,
    0xfd,
    0x1ffb,
    0x7fff0,
    0x1ffc,
    0x3ffc,
    0x22,
    0x7ffd,
    0x3,
    0x23,
    0x4,
    0x24,
    0x5,
    0x25,
    0x26,
    0x27,
    0x6,
    0x74,
    0x75,
    0x28,
    0x29,
    0x2a,
    0x7,
    0x2b,
    0x76,
    0x2c,
    0x8,
    0x9,
    0x2d,
    0x77,
    0x78,
    0x79,
    0x7a,
    0x7b,
    0x7ffe,
    0x7fc,
    0x3ffd,
    0x1ffd,
    0xffffffc,
    0xfffe6,
    0x3fffd2,
    0xfffe7,
    0xfffe8,
    0x3fffd3,
    0x3fffd4,
    0x3fffd5,
    0x7fffd9,
    0x3fffd6,
    0x7fffda,
    0x7fffdb,
    0x7fffdc,
    0x7fffdd,
    0x7fffde,
    0xffffeb,
    0x7fffdf,
    0xffffec,
    0xffffed,
    0x3fffd7,
    0x7fffe0,
    0xffffee,
    0x7fffe1,
    0x7fffe2,
    0x7fffe3,
    0x7fffe4,
    0x1fffdc,
    0x3fffd8,
    0x7fffe5,
    0x3fffd9,
    0x7fffe6,
    0x7fffe7,
    0xffffef,
    0x3fffda,
    0x1fffdd,
    0xfffe9,
    0x3fffdb,
    0x3fffdc,
    0x7fffe8,
    0x7fffe9,
    0x1fffde,
    0x7fffea,
    0x3fffdd,
    0x3fffde,
    0xfffff0,
    0x1fffdf,
    0x3fffdf,
    0x7fffeb,
    0x7fffec,
    0x1fffe0,
    0x1fffe1,
    0x3fffe0,
    0x1fffe2,
    0x7fffed,
    0x3fffe1,
    0x7fffee,
    0x7fffef,
    0xfffea,
    0x3fffe2,
    0x3fffe3,
    0x3fffe4,
    0x7ffff0,
    0x3fffe5,
    0x3fffe6,
    0x7ffff1,
    0x3ffffe0,
    0x3ffffe1,
    0xfffeb,
    0x7fff1,
    0x3fffe7,
    0x7ffff2,
    0x3fffe8,
    0x1ffffec,
    0x3ffffe2,
    0x3ffffe3,
    0x3ffffe4,
    0x7ffffde,
    0x7ffffdf,
    0x3ffffe5,
    0xfffff1,
    0x1ffffed,
    0x7fff2,
    0x1fffe3,
    0x3ffffe6,
    0x7ffffe0,
    0x7ffffe1,
    0x3ffffe7,
    0x7ffffe2,
    0xfffff2,
    0x1fffe4,
    0x1fffe5,
    0x3ffffe8,
    0x3ffffe9,
    0xffffffd,
    0x7ffffe3,
    0x7ffffe4,
    0x7ffffe5,
    0xfffec,
    0xfffff3,
    0xfffed,
    0x1fffe6,
    0x3fffe9,
    0x1fffe7,
    0x1fffe8,
    0x7ffff3,
    0x3fffea,
    0x3fffeb,
    0x1ffffee,
    0x1ffffef,
    0xfffff4,
    0xfffff5,
    0x3ffffea,
    0x7ffff4,
    0x3ffffeb,
    0x7ffffe6,
    0x3ffffec,
    0x3ffffed,
    0x7ffffe7,
    0x7ffffe8,
    0x7ffffe9,
    0x7ffffea,
    0x7ffffeb,
    0xffffffe,
    0x7ffffec,
    0x7ffffed,
    0x7ffffee,
    0x7ffffef,
    0x7fffff0,
    0x3ffffee,
    0x3fffffff, // EOS
};

pub const huffman_code_lengths = [_]u8{
    13, 23, 28, 28, 28, 28, 28, 28, 28, 24, 30, 28, 28, 30, 28, 28,
    28, 28, 28, 28, 28, 28, 30, 28, 28, 28, 28, 28, 28, 28, 28, 28,
    6,  10, 10, 12, 13, 6,  8,  11, 10, 10, 8,  11, 8,  6,  6,  6,
    5,  5,  5,  6,  6,  6,  6,  6,  6,  6,  7,  8,  15, 6,  12, 10,
    13, 6,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
    7,  7,  7,  7,  7,  7,  7,  7,  8,  7,  8,  13, 19, 13, 14, 6,
    15, 5,  6,  5,  6,  5,  6,  6,  6,  5,  7,  7,  6,  6,  6,  5,
    6,  7,  6,  5,  5,  6,  7,  7,  7,  7,  7,  15, 11, 14, 13, 28,
    20, 22, 20, 20, 22, 22, 22, 23, 22, 23, 23, 23, 23, 23, 24, 23,
    24, 24, 22, 23, 24, 23, 23, 23, 23, 21, 22, 23, 22, 23, 23, 24,
    22, 21, 20, 22, 22, 23, 23, 21, 23, 22, 22, 24, 21, 22, 23, 23,
    21, 21, 22, 21, 23, 22, 23, 23, 20, 22, 22, 22, 23, 22, 22, 23,
    26, 26, 20, 19, 22, 23, 22, 25, 26, 26, 26, 27, 27, 26, 24, 25,
    19, 21, 26, 27, 27, 26, 27, 24, 21, 21, 26, 26, 28, 27, 27, 27,
    20, 24, 20, 21, 22, 21, 21, 23, 22, 22, 25, 25, 24, 24, 26, 23,
    26, 27, 26, 26, 27, 27, 27, 27, 27, 28, 27, 27, 27, 27, 27, 26,
    30, // EOS
};

pub var sorted = [_]Code{
    Code{ .code = 0, .symbol = 48, .len = 5 },
    Code{ .code = 1, .symbol = 49, .len = 5 },
    Code{ .code = 2, .symbol = 50, .len = 5 },
    Code{ .code = 3, .symbol = 97, .len = 5 },
    Code{ .code = 4, .symbol = 99, .len = 5 },
    Code{ .code = 5, .symbol = 101, .len = 5 },
    Code{ .code = 6, .symbol = 105, .len = 5 },
    Code{ .code = 7, .symbol = 111, .len = 5 },
    Code{ .code = 8, .symbol = 115, .len = 5 },
    Code{ .code = 9, .symbol = 116, .len = 5 },
    Code{ .code = 20, .symbol = 32, .len = 6 },
    Code{ .code = 21, .symbol = 37, .len = 6 },
    Code{ .code = 22, .symbol = 45, .len = 6 },
    Code{ .code = 23, .symbol = 46, .len = 6 },
    Code{ .code = 24, .symbol = 47, .len = 6 },
    Code{ .code = 25, .symbol = 51, .len = 6 },
    Code{ .code = 26, .symbol = 52, .len = 6 },
    Code{ .code = 27, .symbol = 53, .len = 6 },
    Code{ .code = 28, .symbol = 54, .len = 6 },
    Code{ .code = 29, .symbol = 55, .len = 6 },
    Code{ .code = 30, .symbol = 56, .len = 6 },
    Code{ .code = 31, .symbol = 57, .len = 6 },
    Code{ .code = 32, .symbol = 61, .len = 6 },
    Code{ .code = 33, .symbol = 65, .len = 6 },
    Code{ .code = 34, .symbol = 95, .len = 6 },
    Code{ .code = 35, .symbol = 98, .len = 6 },
    Code{ .code = 36, .symbol = 100, .len = 6 },
    Code{ .code = 37, .symbol = 102, .len = 6 },
    Code{ .code = 38, .symbol = 103, .len = 6 },
    Code{ .code = 39, .symbol = 104, .len = 6 },
    Code{ .code = 40, .symbol = 108, .len = 6 },
    Code{ .code = 41, .symbol = 109, .len = 6 },
    Code{ .code = 42, .symbol = 110, .len = 6 },
    Code{ .code = 43, .symbol = 112, .len = 6 },
    Code{ .code = 44, .symbol = 114, .len = 6 },
    Code{ .code = 45, .symbol = 117, .len = 6 },
    Code{ .code = 92, .symbol = 58, .len = 7 },
    Code{ .code = 93, .symbol = 66, .len = 7 },
    Code{ .code = 94, .symbol = 67, .len = 7 },
    Code{ .code = 95, .symbol = 68, .len = 7 },
    Code{ .code = 96, .symbol = 69, .len = 7 },
    Code{ .code = 97, .symbol = 70, .len = 7 },
    Code{ .code = 98, .symbol = 71, .len = 7 },
    Code{ .code = 99, .symbol = 72, .len = 7 },
    Code{ .code = 100, .symbol = 73, .len = 7 },
    Code{ .code = 101, .symbol = 74, .len = 7 },
    Code{ .code = 102, .symbol = 75, .len = 7 },
    Code{ .code = 103, .symbol = 76, .len = 7 },
    Code{ .code = 104, .symbol = 77, .len = 7 },
    Code{ .code = 105, .symbol = 78, .len = 7 },
    Code{ .code = 106, .symbol = 79, .len = 7 },
    Code{ .code = 107, .symbol = 80, .len = 7 },
    Code{ .code = 108, .symbol = 81, .len = 7 },
    Code{ .code = 109, .symbol = 82, .len = 7 },
    Code{ .code = 110, .symbol = 83, .len = 7 },
    Code{ .code = 111, .symbol = 84, .len = 7 },
    Code{ .code = 112, .symbol = 85, .len = 7 },
    Code{ .code = 113, .symbol = 86, .len = 7 },
    Code{ .code = 114, .symbol = 87, .len = 7 },
    Code{ .code = 115, .symbol = 89, .len = 7 },
    Code{ .code = 116, .symbol = 106, .len = 7 },
    Code{ .code = 117, .symbol = 107, .len = 7 },
    Code{ .code = 118, .symbol = 113, .len = 7 },
    Code{ .code = 119, .symbol = 118, .len = 7 },
    Code{ .code = 120, .symbol = 119, .len = 7 },
    Code{ .code = 121, .symbol = 120, .len = 7 },
    Code{ .code = 122, .symbol = 121, .len = 7 },
    Code{ .code = 123, .symbol = 122, .len = 7 },
    Code{ .code = 248, .symbol = 38, .len = 8 },
    Code{ .code = 249, .symbol = 42, .len = 8 },
    Code{ .code = 250, .symbol = 44, .len = 8 },
    Code{ .code = 251, .symbol = 59, .len = 8 },
    Code{ .code = 252, .symbol = 88, .len = 8 },
    Code{ .code = 253, .symbol = 90, .len = 8 },
    Code{ .code = 1016, .symbol = 33, .len = 10 },
    Code{ .code = 1017, .symbol = 34, .len = 10 },
    Code{ .code = 1018, .symbol = 40, .len = 10 },
    Code{ .code = 1019, .symbol = 41, .len = 10 },
    Code{ .code = 1020, .symbol = 63, .len = 10 },
    Code{ .code = 2042, .symbol = 39, .len = 11 },
    Code{ .code = 2043, .symbol = 43, .len = 11 },
    Code{ .code = 2044, .symbol = 124, .len = 11 },
    Code{ .code = 4090, .symbol = 35, .len = 12 },
    Code{ .code = 4091, .symbol = 62, .len = 12 },
    Code{ .code = 8184, .symbol = 0, .len = 13 },
    Code{ .code = 8185, .symbol = 36, .len = 13 },
    Code{ .code = 8186, .symbol = 64, .len = 13 },
    Code{ .code = 8187, .symbol = 91, .len = 13 },
    Code{ .code = 8188, .symbol = 93, .len = 13 },
    Code{ .code = 8189, .symbol = 126, .len = 13 },
    Code{ .code = 16380, .symbol = 94, .len = 14 },
    Code{ .code = 16381, .symbol = 125, .len = 14 },
    Code{ .code = 32764, .symbol = 60, .len = 15 },
    Code{ .code = 32765, .symbol = 96, .len = 15 },
    Code{ .code = 32766, .symbol = 123, .len = 15 },
    Code{ .code = 524272, .symbol = 92, .len = 19 },
    Code{ .code = 524273, .symbol = 195, .len = 19 },
    Code{ .code = 524274, .symbol = 208, .len = 19 },
    Code{ .code = 1048550, .symbol = 128, .len = 20 },
    Code{ .code = 1048551, .symbol = 130, .len = 20 },
    Code{ .code = 1048552, .symbol = 131, .len = 20 },
    Code{ .code = 1048553, .symbol = 162, .len = 20 },
    Code{ .code = 1048554, .symbol = 184, .len = 20 },
    Code{ .code = 1048555, .symbol = 194, .len = 20 },
    Code{ .code = 1048556, .symbol = 224, .len = 20 },
    Code{ .code = 1048557, .symbol = 226, .len = 20 },
    Code{ .code = 2097116, .symbol = 153, .len = 21 },
    Code{ .code = 2097117, .symbol = 161, .len = 21 },
    Code{ .code = 2097118, .symbol = 167, .len = 21 },
    Code{ .code = 2097119, .symbol = 172, .len = 21 },
    Code{ .code = 2097120, .symbol = 176, .len = 21 },
    Code{ .code = 2097121, .symbol = 177, .len = 21 },
    Code{ .code = 2097122, .symbol = 179, .len = 21 },
    Code{ .code = 2097123, .symbol = 209, .len = 21 },
    Code{ .code = 2097124, .symbol = 216, .len = 21 },
    Code{ .code = 2097125, .symbol = 217, .len = 21 },
    Code{ .code = 2097126, .symbol = 227, .len = 21 },
    Code{ .code = 2097127, .symbol = 229, .len = 21 },
    Code{ .code = 2097128, .symbol = 230, .len = 21 },
    Code{ .code = 4194258, .symbol = 129, .len = 22 },
    Code{ .code = 4194259, .symbol = 132, .len = 22 },
    Code{ .code = 4194260, .symbol = 133, .len = 22 },
    Code{ .code = 4194261, .symbol = 134, .len = 22 },
    Code{ .code = 4194262, .symbol = 136, .len = 22 },
    Code{ .code = 4194263, .symbol = 146, .len = 22 },
    Code{ .code = 4194264, .symbol = 154, .len = 22 },
    Code{ .code = 4194265, .symbol = 156, .len = 22 },
    Code{ .code = 4194266, .symbol = 160, .len = 22 },
    Code{ .code = 4194267, .symbol = 163, .len = 22 },
    Code{ .code = 4194268, .symbol = 164, .len = 22 },
    Code{ .code = 4194269, .symbol = 169, .len = 22 },
    Code{ .code = 4194270, .symbol = 170, .len = 22 },
    Code{ .code = 4194271, .symbol = 173, .len = 22 },
    Code{ .code = 4194272, .symbol = 178, .len = 22 },
    Code{ .code = 4194273, .symbol = 181, .len = 22 },
    Code{ .code = 4194274, .symbol = 185, .len = 22 },
    Code{ .code = 4194275, .symbol = 186, .len = 22 },
    Code{ .code = 4194276, .symbol = 187, .len = 22 },
    Code{ .code = 4194277, .symbol = 189, .len = 22 },
    Code{ .code = 4194278, .symbol = 190, .len = 22 },
    Code{ .code = 4194279, .symbol = 196, .len = 22 },
    Code{ .code = 4194280, .symbol = 198, .len = 22 },
    Code{ .code = 4194281, .symbol = 228, .len = 22 },
    Code{ .code = 4194282, .symbol = 232, .len = 22 },
    Code{ .code = 4194283, .symbol = 233, .len = 22 },
    Code{ .code = 8388568, .symbol = 1, .len = 23 },
    Code{ .code = 8388569, .symbol = 135, .len = 23 },
    Code{ .code = 8388570, .symbol = 137, .len = 23 },
    Code{ .code = 8388571, .symbol = 138, .len = 23 },
    Code{ .code = 8388572, .symbol = 139, .len = 23 },
    Code{ .code = 8388573, .symbol = 140, .len = 23 },
    Code{ .code = 8388574, .symbol = 141, .len = 23 },
    Code{ .code = 8388575, .symbol = 143, .len = 23 },
    Code{ .code = 8388576, .symbol = 147, .len = 23 },
    Code{ .code = 8388577, .symbol = 149, .len = 23 },
    Code{ .code = 8388578, .symbol = 150, .len = 23 },
    Code{ .code = 8388579, .symbol = 151, .len = 23 },
    Code{ .code = 8388580, .symbol = 152, .len = 23 },
    Code{ .code = 8388581, .symbol = 155, .len = 23 },
    Code{ .code = 8388582, .symbol = 157, .len = 23 },
    Code{ .code = 8388583, .symbol = 158, .len = 23 },
    Code{ .code = 8388584, .symbol = 165, .len = 23 },
    Code{ .code = 8388585, .symbol = 166, .len = 23 },
    Code{ .code = 8388586, .symbol = 168, .len = 23 },
    Code{ .code = 8388587, .symbol = 174, .len = 23 },
    Code{ .code = 8388588, .symbol = 175, .len = 23 },
    Code{ .code = 8388589, .symbol = 180, .len = 23 },
    Code{ .code = 8388590, .symbol = 182, .len = 23 },
    Code{ .code = 8388591, .symbol = 183, .len = 23 },
    Code{ .code = 8388592, .symbol = 188, .len = 23 },
    Code{ .code = 8388593, .symbol = 191, .len = 23 },
    Code{ .code = 8388594, .symbol = 197, .len = 23 },
    Code{ .code = 8388595, .symbol = 231, .len = 23 },
    Code{ .code = 8388596, .symbol = 239, .len = 23 },
    Code{ .code = 16777194, .symbol = 9, .len = 24 },
    Code{ .code = 16777195, .symbol = 142, .len = 24 },
    Code{ .code = 16777196, .symbol = 144, .len = 24 },
    Code{ .code = 16777197, .symbol = 145, .len = 24 },
    Code{ .code = 16777198, .symbol = 148, .len = 24 },
    Code{ .code = 16777199, .symbol = 159, .len = 24 },
    Code{ .code = 16777200, .symbol = 171, .len = 24 },
    Code{ .code = 16777201, .symbol = 206, .len = 24 },
    Code{ .code = 16777202, .symbol = 215, .len = 24 },
    Code{ .code = 16777203, .symbol = 225, .len = 24 },
    Code{ .code = 16777204, .symbol = 236, .len = 24 },
    Code{ .code = 16777205, .symbol = 237, .len = 24 },
    Code{ .code = 33554412, .symbol = 199, .len = 25 },
    Code{ .code = 33554413, .symbol = 207, .len = 25 },
    Code{ .code = 33554414, .symbol = 234, .len = 25 },
    Code{ .code = 33554415, .symbol = 235, .len = 25 },
    Code{ .code = 67108832, .symbol = 192, .len = 26 },
    Code{ .code = 67108833, .symbol = 193, .len = 26 },
    Code{ .code = 67108834, .symbol = 200, .len = 26 },
    Code{ .code = 67108835, .symbol = 201, .len = 26 },
    Code{ .code = 67108836, .symbol = 202, .len = 26 },
    Code{ .code = 67108837, .symbol = 205, .len = 26 },
    Code{ .code = 67108838, .symbol = 210, .len = 26 },
    Code{ .code = 67108839, .symbol = 213, .len = 26 },
    Code{ .code = 67108840, .symbol = 218, .len = 26 },
    Code{ .code = 67108841, .symbol = 219, .len = 26 },
    Code{ .code = 67108842, .symbol = 238, .len = 26 },
    Code{ .code = 67108843, .symbol = 240, .len = 26 },
    Code{ .code = 67108844, .symbol = 242, .len = 26 },
    Code{ .code = 67108845, .symbol = 243, .len = 26 },
    Code{ .code = 67108846, .symbol = 255, .len = 26 },
    Code{ .code = 134217694, .symbol = 203, .len = 27 },
    Code{ .code = 134217695, .symbol = 204, .len = 27 },
    Code{ .code = 134217696, .symbol = 211, .len = 27 },
    Code{ .code = 134217697, .symbol = 212, .len = 27 },
    Code{ .code = 134217698, .symbol = 214, .len = 27 },
    Code{ .code = 134217699, .symbol = 221, .len = 27 },
    Code{ .code = 134217700, .symbol = 222, .len = 27 },
    Code{ .code = 134217701, .symbol = 223, .len = 27 },
    Code{ .code = 134217702, .symbol = 241, .len = 27 },
    Code{ .code = 134217703, .symbol = 244, .len = 27 },
    Code{ .code = 134217704, .symbol = 245, .len = 27 },
    Code{ .code = 134217705, .symbol = 246, .len = 27 },
    Code{ .code = 134217706, .symbol = 247, .len = 27 },
    Code{ .code = 134217707, .symbol = 248, .len = 27 },
    Code{ .code = 134217708, .symbol = 250, .len = 27 },
    Code{ .code = 134217709, .symbol = 251, .len = 27 },
    Code{ .code = 134217710, .symbol = 252, .len = 27 },
    Code{ .code = 134217711, .symbol = 253, .len = 27 },
    Code{ .code = 134217712, .symbol = 254, .len = 27 },
    Code{ .code = 268435426, .symbol = 2, .len = 28 },
    Code{ .code = 268435427, .symbol = 3, .len = 28 },
    Code{ .code = 268435428, .symbol = 4, .len = 28 },
    Code{ .code = 268435429, .symbol = 5, .len = 28 },
    Code{ .code = 268435430, .symbol = 6, .len = 28 },
    Code{ .code = 268435431, .symbol = 7, .len = 28 },
    Code{ .code = 268435432, .symbol = 8, .len = 28 },
    Code{ .code = 268435433, .symbol = 11, .len = 28 },
    Code{ .code = 268435434, .symbol = 12, .len = 28 },
    Code{ .code = 268435435, .symbol = 14, .len = 28 },
    Code{ .code = 268435436, .symbol = 15, .len = 28 },
    Code{ .code = 268435437, .symbol = 16, .len = 28 },
    Code{ .code = 268435438, .symbol = 17, .len = 28 },
    Code{ .code = 268435439, .symbol = 18, .len = 28 },
    Code{ .code = 268435440, .symbol = 19, .len = 28 },
    Code{ .code = 268435441, .symbol = 20, .len = 28 },
    Code{ .code = 268435442, .symbol = 21, .len = 28 },
    Code{ .code = 268435443, .symbol = 23, .len = 28 },
    Code{ .code = 268435444, .symbol = 24, .len = 28 },
    Code{ .code = 268435445, .symbol = 25, .len = 28 },
    Code{ .code = 268435446, .symbol = 26, .len = 28 },
    Code{ .code = 268435447, .symbol = 27, .len = 28 },
    Code{ .code = 268435448, .symbol = 28, .len = 28 },
    Code{ .code = 268435449, .symbol = 29, .len = 28 },
    Code{ .code = 268435450, .symbol = 30, .len = 28 },
    Code{ .code = 268435451, .symbol = 31, .len = 28 },
    Code{ .code = 268435452, .symbol = 127, .len = 28 },
    Code{ .code = 268435453, .symbol = 220, .len = 28 },
    Code{ .code = 268435454, .symbol = 249, .len = 28 },
    Code{ .code = 1073741820, .symbol = 10, .len = 30 },
    Code{ .code = 1073741821, .symbol = 13, .len = 30 },
    Code{ .code = 1073741822, .symbol = 22, .len = 30 },
};
//Code{.symbol = 256, .code = 0x3fffffff, .len = 30},

pub const Code = struct { code: u32, symbol: u8, len: u8 };
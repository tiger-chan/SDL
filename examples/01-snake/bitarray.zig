const std = @import("std");

pub fn BitArray(comptime size: usize, comptime T: type) type {
    const info = @typeInfo(T);
    const BITS_PER = info.int.bits;
    const _min_bytes: usize = @min(8 / BITS_PER, 1);
    const BYTES_PER = _min_bytes + 1;
    const Wide = @Type(.{ .int = .{ .signedness = .unsigned, .bits = 8 * BYTES_PER } });
    const TOTAL = blk: {
        const base = (size * BITS_PER);
        const aligned = ((base + 7) / 8);
        break :blk aligned + 1;
    };
    const MAX: Wide = blk: {
        const max = std.math.maxInt(T);
        break :blk @intCast(max);
    };
    return struct {
        const Self = @This();
        _data: [TOTAL]u8 = [_]u8{0} ** TOTAL,

        pub fn init() Self {
            return .{};
        }

        pub fn get(self: *const Self, idx: usize) T {
            std.debug.assert(idx < size);
            const i = index(idx);
            const mem = self._data[i.idx..];
            const rng = wide(&mem);
            return @intCast((rng >> i.shift) & MAX);
        }

        pub fn set(self: *Self, idx: usize, v: T) void {
            std.debug.assert(idx < size);
            const i = index(idx);
            const mem = self._data[i.idx..];
            var widend = wide(&mem);

            widend &= ~(MAX << i.shift);
            widend |= (@as(Wide, v) << i.shift);

            const MASK = 0xFF;
            inline for (0..BYTES_PER) |j| {
                mem[j] = @intCast((widend >> (j * 8)) & MASK);
            }
        }

        fn index(idx: usize) struct { idx: usize, shift: u3 } {
            const off = idx * BITS_PER;
            return .{ .idx = off / 8, .shift = @intCast(off % 8) };
        }

        fn wide(mem: *const []const u8) Wide {
            var rng: Wide = 0;
            inline for (0..BYTES_PER) |j| {
                const m: Wide = mem.*[j];
                rng |= m << (j * 8);
            }
            return rng;
        }
    };
}

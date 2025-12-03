const std = @import("std");
fn solve(input: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var total: u64 = 0;

    while (lines.next()) |line| {
        var start_index: usize = 0;

        for (0..12) |battery| {
            var max: u8 = 0;
            var max_index: usize = 0;

            for (line[start_index .. line.len - (12 - battery) + 1], start_index..) |c, i| {
                const n = c - '0';
                if (n > max) {
                    max = n;
                    max_index = i;
                }
            }
            total += max * try std.math.powi(u64, 10, 12 - @as(u32, @intCast(battery)) - 1);

            start_index = max_index + 1;
        }
    }

    return total;
}

test {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;

    try std.testing.expectEqual(3121910778619, try solve(input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(@embedFile("input03.txt"))});
}

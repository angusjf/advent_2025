const std = @import("std");

fn solve(input: []const u8) !struct { u32, u32 } {
    var angle: i32 = 50;

    var zeroes1: u32 = 0;
    var zeroes2: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const n = try std.fmt.parseInt(u16, line[1..], 10);

        const dir: i32 = switch (line[0]) {
            'L' => 1,
            'R' => -1,
            else => unreachable,
        };

        zeroes2 += @abs(@divFloor(angle + n * dir, 100));

        angle = @mod(angle + n * dir, 100);

        if (angle == 0) {
            zeroes1 += 1;
        }
    }

    return .{ zeroes1, zeroes2 };
}

test solve {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    try std.testing.expectEqual(.{ 3, 6 }, try solve(input));
}

pub fn main() !void {
    const pt1, const pt2 = try solve(@embedFile("input01.txt"));

    std.debug.print("{d}\n{d}\n", .{ pt1, pt2 });
}

const std = @import("std");

fn solve(gpa: std.mem.Allocator, input: []const u8) !u32 {
    _ = gpa; // autofix
    var angle: i32 = 50;

    var zeroes: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
        const n = try std.fmt.parseInt(u16, line[1..], 10);
        switch (line[0]) {
            'L' => {
                zeroes += @abs(@divFloor((angle - n), 100));
                angle = @mod(100 + angle - n, 100);
            },

            'R' => {
                zeroes += @abs(@divFloor((angle + n), 100));
                angle = @mod(angle + n, 100);
            },

            else => unreachable,
        }

        // if (angle == 0) {
        //     zeroes += 1;
        // }
    }

    return zeroes;
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
    try std.testing.expectEqual(3, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    const result = try solve(gpa, @embedFile("input01.txt"));

    std.debug.print("{d}\n", .{result});
}

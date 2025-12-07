const std = @import("std");

fn solve(gpa: std.mem.Allocator, input: []const u8) !struct { u64, u64 } {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var splits: u64 = 0;

    const first_line = lines.next().?;
    _ = lines.next().?;

    var beams = try gpa.alloc(u64, first_line.len);
    defer gpa.free(beams);

    for (beams) |*beam| beam.* = 0;

    beams[std.mem.indexOfScalar(u8, first_line, 'S').?] = 1;

    while (lines.next()) |line| {
        for (0..beams.len) |i| {
            if (line[i] == '^' and beams[i] > 0) {
                splits += 1;
                beams[i + 1] += beams[i];
                beams[i - 1] += beams[i];
                beams[i] = 0;
            }
        }

        _ = lines.next().?;
    }

    var sum: u64 = 0;
    for (beams) |beam| sum += beam;

    return .{ splits, sum };
}

test {
    const input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;

    const pt1, const pt2 = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(21, pt1);
    try std.testing.expectEqual(40, pt2);
}

pub fn main() !void {
    std.debug.print("{any}\n", .{try solve(std.heap.page_allocator, @embedFile("input07.txt"))});
}

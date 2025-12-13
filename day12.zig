const std = @import("std");

fn solve(gpa: std.mem.Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var shapes: [6][3][3]bool = undefined;

    for (&shapes) |*shape| {
        _ = lines.next().?;

        for (0..3) |i| {
            const row = lines.next().?;
            std.debug.print("{d} {s}\n", .{ i, row });
            for (0..3) |j| {
                shape.*[i][j] = row[j] == '#';
            }
        }
    }

    var n_presents: [6]u32 = undefined;

    var total: u32 = 0;

    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeAny(u8, line, " x:");
        const w = try std.fmt.parseInt(u32, numbers.next().?, 10);
        const h = try std.fmt.parseInt(u32, numbers.next().?, 10);

        for (&n_presents) |*n|
            n.* = try std.fmt.parseInt(u32, numbers.next().?, 10);

        if (can_fit(gpa, shapes, w, h, n_presents))
            total += 1;
    }

    return total;
}

fn can_fit(gpa: std.mem.Allocator, shapes: [6][3][3]bool, w: u32, h: u32, n_presents: [6]u32) bool {
    const State = struct {};

    var q: std.ArrayList(State) = .empty;
    defer q.deinit(gpa);

    var total_cells: u32 = 0;

    for (shapes, n_presents) |shape, n| {
        var cells: u32 = 0;
        for (shape) |row| {
            for (row) |b| {
                if (b) cells += 1;
            }
        }
        total_cells += cells * n;
    }

    const max_cells = 9 * (n_presents[0] + n_presents[1] + n_presents[2] + n_presents[3] + n_presents[4] + n_presents[5]);

    if (w * h >= max_cells) return true;

    if (w * h < total_cells) return false;

    @panic("somewhere in the middle");
}

test {
    const input =
        \\0:
        \\###
        \\##.
        \\##.
        \\
        \\1:
        \\###
        \\##.
        \\.##
        \\
        \\2:
        \\.##
        \\###
        \\##.
        \\
        \\3:
        \\##.
        \\###
        \\##.
        \\
        \\4:
        \\###
        \\#..
        \\###
        \\
        \\5:
        \\###
        \\.#.
        \\###
        \\
        \\4x4: 0 0 0 0 2 0
        \\12x5: 1 0 1 0 2 2
        \\12x5: 1 0 1 0 3 2
    ;

    try std.testing.expectEqual(2, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{any}\n", .{try solve(std.heap.page_allocator, @embedFile("input12.txt"))});
}

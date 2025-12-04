const std = @import("std");

fn at(input: []const u8, size: usize, x: usize, y: usize) u8 {
    return input[y * (size + 1) + x];
}

fn solve(gpa: std.mem.Allocator, input_: []const u8) !u32 {
    var input = try gpa.dupe(u8, input_);
    defer gpa.free(input);
    var toDelete: std.ArrayListUnmanaged(usize) = .empty;
    defer toDelete.deinit(gpa);
    const size = std.mem.indexOfScalar(u8, input, '\n').?;

    var accessible: u32 = 0;
    while (true) {
        toDelete.clearRetainingCapacity();

        for (0..size) |y| {
            for (0..size) |x| {
                if (at(input, size, x, y) != '@') continue;
                var adj: u32 = 0;
                if (y != 0) {
                    if (x != 0) {
                        if (at(input, size, x - 1, y - 1) == '@') adj += 1;
                    }
                    if (at(input, size, x + 0, y - 1) == '@') adj += 1;
                    if (x != size - 1) {
                        if (at(input, size, x + 1, y - 1) == '@') adj += 1;
                    }
                }
                if (y != size - 1) {
                    if (x != 0) {
                        if (at(input, size, x - 1, y + 1) == '@') adj += 1;
                    }
                    if (at(input, size, x + 0, y + 1) == '@') adj += 1;
                    if (x != size - 1) {
                        if (at(input, size, x + 1, y + 1) == '@') adj += 1;
                    }
                }
                if (x != 0) {
                    if (at(input, size, x - 1, y) == '@') adj += 1;
                }
                if (x != size - 1) {
                    if (at(input, size, x + 1, y) == '@') adj += 1;
                }
                // std.debug.print("{d}\n", .{adj});
                if (adj < 4) {
                    try toDelete.append(gpa, (x + y * (size + 1)));
                    accessible += 1;
                }
            }
            // std.debug.print("\n", .{});
        }

        if (toDelete.items.len == 0) break;
        for (toDelete.items) |d| {
            input[d] = '.';
        }
    }

    return accessible;
}

test {
    const input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;

    try std.testing.expectEqual(43, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input04.txt"))});
}

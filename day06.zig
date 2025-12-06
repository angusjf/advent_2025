const std = @import("std");

fn solve(gpa: std.mem.Allocator, input: []const u8) !u64 {
    var rows: std.ArrayList([]const u8) = .empty;
    defer rows.deinit(gpa);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        try rows.append(gpa, line);
    }

    var total: u64 = 0;

    var i: usize = 0;
    var op: ?u8 = null;
    var acc: u64 = 0;

    while (i < rows.items[0].len) : (i += 1) {
        if (rows.items[rows.items.len - 1][i] != ' ') {
            std.debug.print("acc: {d}\n", .{acc});
            total += acc;
            op, acc = switch (rows.items[rows.items.len - 1][i]) {
                '*' => .{ '*', 1 },
                '+' => .{ '+', 0 },
                else => unreachable,
            };
        }

        var n: u64 = 0;

        for (rows.items[0 .. rows.items.len - 1]) |row| {
            if (row[i] != ' ') {
                n *= 10;
                n += row[i] - '0';
            }
        }

        if (n == 0) continue;

        std.debug.print("n: {d} {c}\n", .{ n, op.? });

        switch (op.?) {
            '*' => acc *= n,
            '+' => acc += n,
            else => unreachable,
        }
    }

    total += acc;

    return total;
}

test {
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +  
    ;

    try std.testing.expectEqual(4277556, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input06.txt"))});
}

const std = @import("std");

fn getMinPresses(gpa: std.mem.Allocator, line: []const u8) !u32 {
    var words = std.mem.tokenizeScalar(u8, line[0..std.mem.indexOfScalar(u8, line, '{').?], ' ');
    const lights_with_brackets = words.next().?;
    var init_lights: u32 = 0;
    for (lights_with_brackets[1 .. lights_with_brackets.len - 1], 0..) |c, i| {
        switch (c) {
            '.' => {},
            '#' => {
                init_lights |= @as(u32, 1) << @intCast(i);
            },
            else => unreachable,
        }
    }

    var buttons: std.ArrayList(u32) = .empty;
    defer buttons.deinit(gpa);

    while (words.next()) |word| {
        var it = std.mem.tokenizeAny(u8, word, "(,)");

        var button: u32 = 0;

        while (it.next()) |index|
            button |= @as(u32, 1) << try std.fmt.parseInt(u5, index, 10);

        try buttons.append(gpa, button);
    }

    const State = struct {
        lights: u32,
        dist: u32,
    };

    var q: std.ArrayList(State) = .empty;
    defer q.deinit(gpa);

    var explored: std.AutoHashMapUnmanaged(State, void) = .empty;
    defer explored.deinit(gpa);

    {
        const root = State{ .lights = init_lights, .dist = 0 };

        try explored.put(gpa, root, {});
        try q.append(gpa, root);
    }

    while (q.items.len > 0) {
        const v = q.orderedRemove(0);

        if (v.lights == 0) {
            return v.dist;
        }

        for (buttons.items) |b| {
            const w = State{ .lights = v.lights ^ b, .dist = v.dist + 1 };
            if (!explored.contains(w)) {
                try explored.put(gpa, w, {});
                try q.append(gpa, w);
            }
        }
    }

    return 0;
}

fn solve(gpa: std.mem.Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var total: u32 = 0;

    while (lines.next()) |line| {
        total += try getMinPresses(gpa, line);
    }

    return total;
}

test {
    const input =
        \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    ;

    try std.testing.expectEqual(7, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input10.txt"))});
}

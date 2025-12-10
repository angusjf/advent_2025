const std = @import("std");

const Point = struct { x: u32, y: u32 };
const Bound = struct { min: u32, max: u32 };

fn trackBoundsBetweenPoints(
    gpa: std.mem.Allocator,
    bounds_by_x: *std.AutoHashMapUnmanaged(u32, Bound),
    bounds_by_y: *std.AutoHashMapUnmanaged(u32, Bound),
    from: Point,
    to: Point,
) !void {
    std.debug.print("<trackBoundsBetweenPoints {any} {any}>\n", .{ from, to });
    if (from.x == to.x) {
        const start, const end = if (from.y < to.y) .{ from.y, to.y } else .{ to.y, from.y };
        for (start..end + 1) |y| {
            try trackBoundsPoint(gpa, bounds_by_x, bounds_by_y, from.x, @intCast(y));
        }
    } else if (from.y == to.y) {
        const start, const end = if (from.x < to.x) .{ from.x, to.x } else .{ to.x, from.x };
        for (start..end + 1) |x| {
            try trackBoundsPoint(gpa, bounds_by_x, bounds_by_y, @intCast(x), from.y);
        }
    } else unreachable;
    std.debug.print("</trackBoundsBetweenPoints>\n", .{});
}

fn trackBoundsPoint(
    gpa: std.mem.Allocator,
    bounds_by_x: *std.AutoHashMapUnmanaged(u32, Bound),
    bounds_by_y: *std.AutoHashMapUnmanaged(u32, Bound),
    x: u32,
    y: u32,
) !void {
    std.debug.print("  <trackBoundsPoint>\n", .{});
    {
        const gop = try bounds_by_x.getOrPut(gpa, x);

        if (!gop.found_existing) {
            gop.value_ptr.* = .{ .min = y, .max = y };
        } else {
            gop.value_ptr.* = .{
                .min = @min(y, gop.value_ptr.*.min),
                .max = @max(y, gop.value_ptr.*.max),
            };
        }
    }
    {
        const gop = try bounds_by_y.getOrPut(gpa, y);

        if (!gop.found_existing) {
            gop.value_ptr.* = .{ .min = x, .max = x };
        } else {
            gop.value_ptr.* = .{
                .min = @min(x, gop.value_ptr.*.min),
                .max = @max(x, gop.value_ptr.*.max),
            };
        }
    }
    std.debug.print("  </trackBoundsPoint>\n", .{});
}

fn solve(gpa: std.mem.Allocator, input: []const u8) !u64 {
    var points: std.ArrayList(Point) = .empty;
    defer points.deinit(gpa);

    var lines = std.mem.tokenizeAny(u8, input, "\n,");

    while (true) {
        const x = try std.fmt.parseInt(u32, lines.next() orelse break, 10);
        const y = try std.fmt.parseInt(u32, lines.next().?, 10);
        try points.append(gpa, .{ .x = x, .y = y });
    }

    var max: u64 = 0;

    var bounds_by_x: std.AutoHashMapUnmanaged(u32, Bound) = .empty;
    defer bounds_by_x.deinit(gpa);
    var bounds_by_y: std.AutoHashMapUnmanaged(u32, Bound) = .empty;
    defer bounds_by_y.deinit(gpa);

    for (points.items[0 .. points.items.len - 1], points.items[1..]) |from, to| {
        try trackBoundsBetweenPoints(gpa, &bounds_by_x, &bounds_by_y, from, to);
    }
    {
        try trackBoundsBetweenPoints(gpa, &bounds_by_x, &bounds_by_y, points.items[points.items.len - 1], points.items[0]);
    }
    {
        var x_it = bounds_by_x.iterator();

        while (x_it.next()) |kv| {
            std.debug.print("at point x = {d}, y in range {any} ({d})\n", .{ kv.key_ptr.*, kv.value_ptr.*, kv.value_ptr.*.max - kv.value_ptr.min });
        }
    }
    {
        var y_it = bounds_by_y.iterator();

        while (y_it.next()) |kv| {
            std.debug.print("at point y = {d}, x in range {any} ({d})\n", .{ kv.key_ptr.*, kv.value_ptr.*, kv.value_ptr.*.max - kv.value_ptr.min });
        }
    }
    //
    // if (bounds_by_y.get(49000)) |v| {
    //     std.debug.print(" ({any})\n", .{bounds_by_y.get(51000).?});
    //     std.debug.print(" ({any})\n", .{v});
    //     @panic("!");
    // }

    for (points.items, 0..) |a, i| {
        for (points.items, 0..) |b, j| {
            if (i >= j) continue;

            const area = (@as(u64, if (a.x > b.x) a.x - b.x else b.x - a.x) + 1) *
                ((if (a.y > b.y) a.y - b.y else b.y - a.y) + 1);

            std.debug.print("{any}, {any} = {d}\n", .{ a, b, area });

            if (area > max) {
                const min_x, const max_x = if (a.x < b.x) .{ a.x, b.x } else .{ b.x, a.x };
                const min_y, const max_y = if (a.y < b.y) .{ a.y, b.y } else .{ b.y, a.y };

                for (min_x..max_x + 1) |x| {
                    const bounds = bounds_by_x.get(@intCast(x)).?;
                    if (min_y < bounds.min or max_y > bounds.max) break;
                } else for (min_y..max_y + 1) |y| {
                    const bounds = bounds_by_y.get(@intCast(y)).?;
                    if (min_x < bounds.min or max_x > bounds.max) break;
                } else max = area;
            }
        }
    }

    return max;
}

test {
    const input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;

    std.debug.print("{d}\n", .{try solve(std.testing.allocator, input)});
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input09.txt"))});
}

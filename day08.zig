const std = @import("std");

const Vec3 = struct { x: f32, y: f32, z: f32 };

fn dist_between(a: Vec3, b: Vec3) f32 {
    return std.math.sqrt(
        std.math.pow(f32, @as(f32, a.x) - b.x, 2) +
            std.math.pow(f32, a.y - b.y, 2) +
            std.math.pow(f32, a.z - b.z, 2),
    );
}

fn solve(gpa: std.mem.Allocator, input: []const u8) !u32 {
    var numbers = std.mem.tokenizeAny(u8, input, "\n,");
    var points: std.ArrayList(Vec3) = .empty;
    defer points.deinit(gpa);

    while (numbers.next()) |a| {
        const b = numbers.next().?;
        const c = numbers.next().?;

        try points.append(gpa, Vec3{
            .x = try std.fmt.parseFloat(f32, a),
            .y = try std.fmt.parseFloat(f32, b),
            .z = try std.fmt.parseFloat(f32, c),
        });
    }

    std.debug.print("points: {d}\n", .{points.items.len});

    var pairs: std.AutoHashMapUnmanaged(struct { usize, usize }, void) = .empty;
    defer pairs.deinit(gpa);

    for (0..10000000) |z| {
        std.debug.print("#{d}\n", .{z});
        var closest_dist: f32 = std.math.inf(f32);
        var closest_i: usize = 0;
        var closest_j: usize = 0;

        for (points.items, 0..) |a, i| {
            for (points.items, 0..) |b, j| {
                if (i == j) continue;
                if (pairs.contains(.{ i, j })) continue;
                if (pairs.contains(.{ j, i })) unreachable;

                const dist = dist_between(a, b);

                if (dist < closest_dist) {
                    closest_dist = dist;
                    closest_i = i;
                    closest_j = j;
                }
            }
        }

        if (closest_dist == std.math.inf(f32)) break;

        try pairs.putNoClobber(gpa, .{ closest_i, closest_j }, {});
        try pairs.putNoClobber(gpa, .{ closest_j, closest_i }, {});
        std.debug.print("{any} {any}\n", .{ points.items[closest_i], points.items[closest_j] });

        {
            std.debug.print("pairs: {d}\n", .{pairs.size});

            var connections: std.AutoHashMapUnmanaged(usize, std.AutoHashMapUnmanaged(usize, void)) = .empty;
            defer connections.deinit(gpa);
            defer {
                var it = connections.valueIterator();

                while (it.next()) |v| {
                    v.*.deinit(gpa);
                }
            }

            var pairs_it = pairs.keyIterator();

            while (pairs_it.next()) |pair| {
                {
                    const gop = try connections.getOrPut(gpa, pair.@"0");

                    if (!gop.found_existing) gop.value_ptr.* = .empty;
                    try gop.value_ptr.*.put(gpa, pair.@"1", {});
                }
                {
                    const gop = try connections.getOrPut(gpa, pair.@"1");

                    if (!gop.found_existing) gop.value_ptr.* = .empty;
                    try gop.value_ptr.*.put(gpa, pair.@"0", {});
                }
            }

            if (connections.size != points.items.len) {
                std.debug.print("not enough connections: {d}\n", .{connections.size});
                std.debug.print("should be at least {d}\n", .{points.items.len});
                continue;
            }

            var nodes = connections.keyIterator();

            std.debug.print("connections: {d}\n", .{connections.size});

            var visited: std.AutoHashMapUnmanaged(usize, void) = .empty;
            defer visited.deinit(gpa);

            var component_sizes: std.ArrayListUnmanaged(u32) = .empty;
            defer component_sizes.deinit(gpa);

            while (nodes.next()) |node| {
                const old_size = visited.size;
                if (visited.contains(node.*)) continue;
                try dfs(gpa, &visited, &connections, node.*);
                std.debug.print("dfs: {d}\n", .{visited.size - old_size});
                try component_sizes.append(gpa, visited.size - old_size);
            }

            std.debug.print("components: {d}\n", .{component_sizes.items.len});

            std.mem.sortUnstable(u32, component_sizes.items, {}, std.sort.desc(u32));

            return 99;
        }
    }
    unreachable;
}

fn dfs(
    gpa: std.mem.Allocator,
    visited: *std.AutoHashMapUnmanaged(usize, void),
    connections: *std.AutoHashMapUnmanaged(usize, std.AutoHashMapUnmanaged(usize, void)),
    node: usize,
) !void {
    try visited.put(gpa, node, {});

    const next = connections.get(node).?;
    var it = next.keyIterator();

    while (it.next()) |x| {
        if (visited.contains(x.*)) continue;

        try dfs(gpa, visited, connections, x.*);
    }
}

test {
    const input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;

    try std.testing.expectEqual(40, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input08.txt"))});
}

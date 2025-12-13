const std = @import("std");

fn solve(gpa: std.mem.Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var map: std.StringHashMapUnmanaged([]const u8) = .empty;
    defer map.deinit(gpa);

    while (lines.next()) |line| {
        const from = line[0..3];
        const to = line[5..];
        try map.putNoClobber(gpa, from, to);
    }

    var q: std.ArrayList(struct { node: []const u8, seen_fft: bool, seen_dac: bool, path: std.StringHashMapUnmanaged(void) }) = .empty;
    defer q.deinit(gpa);

    try q.append(gpa, .{ .node = "svr", .seen_dac = false, .seen_fft = false, .path = .empty });
    defer for (q.items) |*v| {
        v.path.deinit(gpa);
    };

    var routes: u32 = 0;

    while (true) {
        var v = q.pop() orelse break;
        std.debug.print("{s} {d} {d}\n", .{ v.node, routes, q.items.len });
        if (std.mem.eql(u8, v.node, "out")) {
            if (v.seen_dac and v.seen_fft) routes += 1;
        } else {
            const connected = map.get(v.node).?;
            var words = std.mem.tokenizeScalar(u8, connected, ' ');
            while (words.next()) |w| {
                if (v.path.contains(w)) continue;
                var path = try v.path.clone(gpa);
                try path.put(gpa, v.node, {});
                try q.insert(gpa, 0, .{
                    .node = w,
                    .seen_dac = v.seen_dac or std.mem.eql(u8, v.node, "dac"),
                    .seen_fft = v.seen_fft or std.mem.eql(u8, v.node, "fft"),
                    .path = path,
                });
            }
            v.path.deinit(gpa);
        }
    }

    return routes;
}

test {
    const input =
        \\svr: aaa bbb
        \\aaa: fft
        \\fft: ccc
        \\bbb: tty
        \\tty: ccc
        \\ccc: ddd eee
        \\ddd: hub
        \\hub: fff
        \\eee: dac
        \\dac: fff
        \\fff: ggg hhh
        \\ggg: out
        \\hhh: out
    ;

    try std.testing.expectEqual(2, try solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input11.txt"))});
}

const std = @import("std");
const Range = struct { start: u64, end: u64 };

fn solve(gpa: std.mem.Allocator, input: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(gpa);

    while (lines.next()) |line| {
        const dash = std.mem.indexOfScalar(u8, line, '-');
        if (dash) |i| {
            try ranges.append(gpa, .{
                .start = try std.fmt.parseInt(u64, line[0..i], 10),
                .end = try std.fmt.parseInt(u64, line[i + 1 ..], 10),
            });
        }
        // else {
        //     const n = try std.fmt.parseInt(u64, line, 10);
        //     for (ranges.items) |range| {
        //         if (n >= range.start and n <= range.end) {
        //             fresh += 1;
        //             break;
        //         }
        //     }
        // }
    }

    // var min: u64 = std.math.maxInt(u64);
    // var max: u64 = 0;

    // for (ranges.items) |range| {
    //     min = @min(min, range.start);
    //     max = @max(max, range.end);
    // }
    //
    //
    // 3-5
    // 10-14
    // 12-18
    // 16-20
    var cutoff: u64 = 0;

    var fresh: u64 = 0;

    while (true) {
        var maybe_next: ?Range = null;

        for (ranges.items) |range| {
            if (range.start <= cutoff) continue;

            if (maybe_next) |next| {
                if (range.start < next.start) {
                    maybe_next = range;
                }
            } else {
                maybe_next = range;
            }
        }

        var next = maybe_next orelse break;

        // now we found our earliest range
        std.debug.print("next up ->: {any}\n", .{next});

        spree: while (true) {
            for (ranges.items) |range| {
                // std.debug.print("  {any} {any}\n", .{
                //     range.start <= next.end,
                //     range.end > next.start,
                // });
                if (!(range.start == next.start and range.end == next.end) and
                    // if it starts before we end
                    range.start <= next.end and
                    // and ends after us
                    range.end > next.end)
                {
                    std.debug.print("         ({any}, {any})\n", .{ range.start, next.start });
                    std.debug.print(" {any} can jump onto ->: {any} ... can add {any}\n", .{ next, range, range.start - next.start });
                    // copy our bit
                    fresh += range.start - next.start;
                    // this is us now
                    next = range;
                    continue :spree;
                }
            } else break :spree;
        }

        std.debug.print("finishing up, can add {d}\n", .{next.end - next.start + 1});
        fresh += next.end - next.start + 1;

        cutoff = next.end;
    }

    return fresh;
}

test {
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;

    try std.testing.expectEqual(14, solve(std.testing.allocator, input));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(std.heap.page_allocator, @embedFile("input05.txt"))});
}

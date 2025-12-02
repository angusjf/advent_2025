const std = @import("std");

fn pow10(n: u64) u64 {
    return std.math.powi(u64, 10, n) catch unreachable;
}

fn isValid(id: u64) bool {
    const num_digits = std.math.log10_int(id) + 1;

    var section_size: u32 = 1;

    while (section_size < num_digits) : (section_size += 1) {
        if (num_digits % section_size != 0) continue;

        const final_section = id % pow10(section_size);

        for (1..num_digits / section_size) |i| {
            const section = (id / pow10(section_size * i)) % pow10(section_size);

            if (section != final_section) break;
        } else return false;
    }

    return true;
}

fn solve(input: []const u8) !u64 {
    var total: u64 = 0;

    var numbers = std.mem.tokenizeAny(u8, input, "\n-,");

    while (numbers.next()) |start_str| {
        const start = try std.fmt.parseInt(u64, start_str, 10);
        const end = try std.fmt.parseInt(u64, numbers.next().?, 10);

        for (start..end + 1) |id_usize| {
            const id: u64 = @intCast(id_usize);
            if (!isValid(id)) {
                total += id;
            }
        }
    }

    return total;
}

test {
    try std.testing.expectEqual(4174379265, try solve(
        "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124\n",
    ));
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try solve(@embedFile("input02.txt"))});
}

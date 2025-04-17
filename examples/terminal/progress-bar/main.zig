const std: type = @import("std");

const max_len: u8 = 10;
const duration: u64 = 100 * std.time.ns_per_ms;

pub fn main() !void {
    var bar_index: u8 = 1;

    var bar: [max_len]u8 = undefined;

    for (0..3 * max_len) |_| {
        fillBar(&bar, bar_index);

        try std.io.getStdOut().writer().print("\rProgress Bar Example [{s}]", .{bar});

        bar_index = if (bar_index < max_len) bar_index + 1 else 1;

        std.time.sleep(duration);
    }

    try std.io.getStdOut().writeAll("\r\x1b[2K"); // carriage return + clear line
}

fn fillBar(bar: *[max_len]u8, bar_index: u8) void {
    const index: u8 = if (bar_index < max_len) bar_index else max_len;
    for (bar[0..index]) |*b| {
        b.* = '.';
    }
    for (bar[index..]) |*b| {
        b.* = ' ';
    }
}

const std: type = @import("std");

const MAX_LEN: u8 = 10;
const DURATION: u64 = 100 * std.time.ns_per_ms;

pub fn main() !void {
    var bar_index: u8 = 1;

    var bar: [MAX_LEN]u8 = undefined;

    for (0..3 * MAX_LEN) |_| {
        fillBar(&bar, bar_index);

        try std.io.getStdOut().writer().print("\rProgress Bar Example [{s}]", .{bar});

        bar_index = if (bar_index < MAX_LEN) bar_index + 1 else 1;

        std.time.sleep(DURATION);
    }

    try std.io.getStdOut().writeAll("\r\x1b[2K"); // carriage return + clear line
}

fn fillBar(bar: *[MAX_LEN]u8, bar_index: u8) void {
    const index: u8 = if (bar_index < MAX_LEN) bar_index else MAX_LEN;
    for (bar[0..index]) |*b| {
        b.* = '.';
    }
    for (bar[index..]) |*b| {
        b.* = ' ';
    }
}

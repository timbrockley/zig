//--------------------------------------------------------------------------------
// Copyright 2024, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");

const DURATION: u64 = 1 * std.time.ns_per_s;
const CR_CLEARLINE = "\r\x1b[2K";

pub fn main() !void {
    var it = std.process.args();
    _ = it.skip();

    const arg1 = if (it.next()) |s| s else "";
    const arg2 = if (it.next()) |s| s else "";

    if (arg1.len > 0) {
        var countdown = std.fmt.parseInt(u32, arg1, 10) catch 0;
        const message = if (arg2.len > 0) arg2 else "Countdown";

        while (countdown > 0) {
            try std.io.getStdOut().writer().print("{s}{s}...{d}", .{ CR_CLEARLINE, message, countdown });
            countdown -= 1;
            std.time.sleep(DURATION);
        }

        try std.io.getStdOut().writeAll(CR_CLEARLINE);
    }
}
//--------------------------------------------------------------------------------

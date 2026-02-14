//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
//--------------------------------------------------------------------------------
const DURATION = 1000; // milliseconds
const CR_CLEARLINE = "\r\x1b[2K";
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    var stdout_writer = std.Io.File.Writer.init(.stdout(), init.io, &.{});
    const stdout = &stdout_writer.interface;
    //------------------------------------------------------------
    var it = init.minimal.args.iterate();
    _ = it.skip();
    //------------------------------------------------------------
    const arg1 = if (it.next()) |s| s else "";
    const arg2 = if (it.next()) |s| s else "";
    //------------------------------------------------------------
    if (arg1.len > 0) {
        var countdown = std.fmt.parseInt(u32, arg1, 10) catch 0;
        const message = if (arg2.len > 0) arg2 else "Countdown";

        while (countdown > 0) {
            try stdout.print("{s}{s}...{d}", .{ CR_CLEARLINE, message, countdown });
            countdown -= 1;
            try init.io.sleep(.fromMilliseconds(DURATION), .awake);
        }

        try stdout.writeAll(CR_CLEARLINE);
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

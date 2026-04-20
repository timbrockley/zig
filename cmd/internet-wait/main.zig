//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
//--------------------------------------------------------------------------------
const ADDR: []const u8 = "1.1.1.1";
const PORT: u16 = 53;
//--------------------------------------------------------------------------------
const MAX_BAR_LEN: u8 = 10;
const DURATION: u64 = 100;
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    var stdout_writer = std.Io.File.Writer.init(.stdout(), init.io, &.{});
    const stdout = &stdout_writer.interface;
    //------------------------------------------------------------
    var bar_index: u8 = 0;
    var bar: [MAX_BAR_LEN]u8 = undefined;

    while (!connected(init.io)) {
        fillBar(&bar, bar_index);

        try stdout.print("\rWaiting for internet connection [{s}]", .{bar});

        bar_index = if (bar_index < MAX_BAR_LEN) bar_index + 1 else 1;

        try init.io.sleep(.fromMilliseconds(DURATION), .awake);
    }

    try stdout.writeAll("\r\x1b[2K"); // carriage return + clear line
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn fillBar(bar: *[MAX_BAR_LEN]u8, bar_index: u8) void {
    const index: u8 = if (bar_index < MAX_BAR_LEN) bar_index else MAX_BAR_LEN;
    for (bar[0..index]) |*b| {
        b.* = '.';
    }
    for (bar[index..]) |*b| {
        b.* = ' ';
    }
}
//--------------------------------------------------------------------------------
pub fn connected(io: std.Io) bool {
    const addr = std.Io.net.IpAddress.resolve(io, ADDR, PORT) catch return false;
    const s = std.Io.net.IpAddress.connect(&addr, io, .{ .mode = .stream }) catch return false;
    defer s.close(io);
    return true;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

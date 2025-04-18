//--------------------------------------------------------------------------------
// Copyright 2024, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");

const ADDR: []const u8 = "1.1.1.1";
const PORT: u16 = 53;

const MAX_LEN: u8 = 10;
const DURATION: u64 = 100 * std.time.ns_per_ms;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var bar_index: u8 = 0;
    var bar: [MAX_LEN]u8 = undefined;

    while (!connected(allocator)) {
        fillBar(&bar, bar_index);

        try std.io.getStdOut().writer().print("\rWaiting for internet connection [{s}]", .{bar});

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

pub fn connected(allocator: std.mem.Allocator) bool {
    const s = std.net.tcpConnectToHost(allocator, ADDR, PORT) catch return false;
    defer s.close();
    return true;
}
//--------------------------------------------------------------------------------

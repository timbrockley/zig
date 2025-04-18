//--------------------------------------------------------------------------------
// Copyright 2024, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");

const ADDR = "1.1.1.1";
const PORT = 53;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    if (connected(allocator)) {
        std.process.exit(0);
    } else {
        std.process.exit(1);
    }
}

pub fn connected(allocator: std.mem.Allocator) bool {
    const s = std.net.tcpConnectToHost(allocator, ADDR, PORT) catch return false;
    defer s.close();
    return true;
}
//--------------------------------------------------------------------------------

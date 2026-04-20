//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const ADDR: []const u8 = "1.1.1.1";
const PORT: u16 = 53;
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) void {
    //------------------------------------------------------------
    if (connected(init.io)) {
        std.process.exit(0);
    } else {
        std.process.exit(1);
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn connected(io: std.Io) bool {
    const addr = std.Io.net.IpAddress.resolve(io, ADDR, PORT) catch return false;
    const s = std.Io.net.IpAddress.connect(&addr, io, .{ .mode = .stream }) catch return false;
    defer s.close(io);
    return true;
}
//--------------------------------------------------------------------------------

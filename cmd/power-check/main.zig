//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");

pub fn main() !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    var child = std.process.Child.init(&[_][]const u8{ "upower", "--dump" }, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    //------------------------------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    try child.spawn();
    try child.collectOutput(allocator, &stdout, &stderr, 10240);
    const term = child.wait() catch |err| {
        std.debug.print("process error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    //------------------------------------------------------------
    if (stderr.items.len == 0) {
        try std.io.getStdErr().writer().writeAll(stderr.items);
    }
    //------------------------------------------------------------
    if (term.Exited > 0) {
        std.debug.print("invalid exit code: {d}\n", .{term.Exited});
        std.process.exit(term.Exited);
    }
    //------------------------------------------------------------
    var usingBattery = false;
    var lineMatched = false;

    var lines = std.mem.splitScalar(u8, stdout.items, '\n');

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "on-battery:")) |pos| {
            usingBattery = std.mem.indexOfPos(u8, line, pos, "yes") != null;
            lineMatched = true;
            break;
        }
    }

    if (!lineMatched) {
        std.debug.print("unable to check power supply status\n", .{});
        std.process.exit(1);
    }
    //------------------------------------------------------------
    var it = std.process.args();
    _ = it.skip();

    if (it.next()) |arg1| {
        if (std.mem.eql(u8, arg1, "battery")) {
            std.process.exit(if (usingBattery) 0 else 1);
        } else if (std.mem.eql(u8, arg1, "mains")) {
            std.process.exit(if (!usingBattery) 0 else 1);
        } else {
            std.debug.print("invalid arguments\n", .{});
            std.process.exit(1);
        }
    }
    //------------------------------------------------------------
    if (usingBattery) {
        try std.io.getStdOut().writer().writeAll("power supply: battery power\n");
    } else {
        try std.io.getStdOut().writer().writeAll("power supply: mains power\n");
    }
    //------------------------------------------------------------
    std.process.exit(0);
    //------------------------------------------------------------
}

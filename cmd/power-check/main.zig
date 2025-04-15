//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");

const OS = builtin.os.tag;
const MAX_OUTPUT_BYTES: usize = 2 * 1024;
const PS_SEARCH_PATH = "/sys/class/power_supply";

//--------------------------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    const usingBattery = switch (OS) {
        .linux => power_check_linux(allocator),
        .macos => power_check_macos(allocator),
        .windows => power_check_windows(),
        else => {
            std.debug.print("Unsupported OS: {s}\n", .{@tagName(OS)});
            std.process.exit(1);
        },
    };
    //------------------------------------------------------------
    var it = try std.process.ArgIterator.initWithAllocator(allocator);
    defer it.deinit();
    _ = it.skip();
    //------------------------------------------------------------
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

//------------------------------------------------------------
// linux functions
//------------------------------------------------------------

fn power_check_linux(allocator: std.mem.Allocator) bool {
    //------------------------------------------------------------
    return power_check_filepath(allocator) catch return power_check_upower(allocator);
    //------------------------------------------------------------
}

fn power_check_filepath(allocator: std.mem.Allocator) !bool {
    //------------------------------------------------------------
    const psFilePath = try find_ps_filepath(allocator);
    //------------------------------------------------------------
    var file = try std.fs.cwd().openFile(psFilePath, .{});
    defer file.close();
    //------------------------------------------------------------
    var buffer: [1]u8 = undefined;
    const bytesRead = try file.readAll(&buffer);
    //------------------------------------------------------------
    if (bytesRead == 0) {
        return error.ReadError;
    }
    //------------------------------------------------------------
    return buffer[0] == '0'; // 0 = using battery, 1 = using mains
    //------------------------------------------------------------
}

fn find_ps_filepath(allocator: std.mem.Allocator) ![]const u8 {
    //------------------------------------------------------------
    var dir = try std.fs.cwd().openDir(PS_SEARCH_PATH, .{ .iterate = true });
    defer dir.close();
    //------------------------------------------------------------
    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dirContent| {
        if (std.mem.startsWith(u8, dirContent.name, "AC")) {
            return try std.fmt.allocPrint(allocator, "{s}/{s}/online", .{ PS_SEARCH_PATH, dirContent.name });
        }
    }
    //------------------------------------------------------------
    return error.PowerSupplyNotFound;
    //------------------------------------------------------------
}

fn power_check_upower(allocator: std.mem.Allocator) bool {
    //------------------------------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    const exitCode = child_process(
        allocator,
        &[_][]const u8{ "upower", "--dump" },
        &stdout,
        &stderr,
        MAX_OUTPUT_BYTES,
    ) catch |err| {
        std.debug.print("process error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };

    if (stderr.items.len > 0) {
        std.debug.print("{s}", .{stderr.items});
        std.process.exit(1);
    }

    if (exitCode > 0) {
        std.debug.print("invalid exit code: {d}\n", .{exitCode});
        std.process.exit(exitCode);
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
    return usingBattery;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// macos functions
//------------------------------------------------------------

fn power_check_macos(allocator: std.mem.Allocator) bool {
    //----------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    const exitCode = child_process(
        allocator,
        &[_][]const u8{ "pmset", "-g", "batt" },
        &stdout,
        &stderr,
        MAX_OUTPUT_BYTES,
    ) catch |err| {
        std.debug.print("process error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };

    if (stderr.items.len > 0) {
        std.debug.print("{s}", .{stderr.items});
    }

    if (exitCode > 0) {
        std.debug.print("invalid exit code: {d}\n", .{exitCode});
        std.process.exit(exitCode);
    }
    //------------------------------------------------------------
    var usingBattery = false;
    var lineMatched = false;
    var lines = std.mem.splitScalar(u8, stdout.items, '\n');

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "Now drawing")) |pos| {
            usingBattery = std.mem.indexOfPos(u8, line, pos, "Battery Power") != null;
            lineMatched = true;
            break;
        }
    }

    if (!lineMatched) {
        std.debug.print("unable to check power supply status\n", .{});
        std.process.exit(1);
    }
    //------------------------------------------------------------
    return usingBattery;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// linux and macos supporting functions
//------------------------------------------------------------

fn child_process(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    stdout: *std.ArrayListUnmanaged(u8),
    stderr: *std.ArrayListUnmanaged(u8),
    maxOutputBytes: usize,
) !u8 {
    //------------------------------------------------------------
    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    //------------------------------------------------------------
    try child.spawn();
    try child.collectOutput(allocator, stdout, stderr, maxOutputBytes);
    //------------------------------------------------------------
    const term = try child.wait();
    return term.Exited;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// windows functions
//------------------------------------------------------------

const windows = if (OS == .windows) std.os.windows else struct {};

const SYSTEM_POWER_STATUS = extern struct {
    ACLineStatus: u8,
    BatteryFlag: u8,
    BatteryLifePercent: u8,
    Reserved1: u8,
    BatteryLifeTime: u32,
    BatteryFullLifeTime: u32,
};

//------------------------------------------------------------

extern "kernel32" fn GetSystemPowerStatus(lpSystemPowerStatus: *SYSTEM_POWER_STATUS) callconv(.C) windows.BOOL;

fn power_check_windows() bool {
    //------------------------------------------------------------
    var status: SYSTEM_POWER_STATUS = undefined;
    if (GetSystemPowerStatus(&status) == windows.FALSE) {
        std.debug.print("GetSystemPowerStatus: error checking power supply status\n", .{});
        std.process.exit(1);
    }
    return status.ACLineStatus != 1; // 0 = using battery, 1 = using mains
    //------------------------------------------------------------
}

//------------------------------------------------------------

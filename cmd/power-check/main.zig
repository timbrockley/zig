//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");

var stdout_writer = std.fs.File.stdout().writer(&.{});
const stdout_interface = &stdout_writer.interface;

//--------------------------------------------------------------------------------

pub const MAX_OUTPUT_BYTES: usize = 10 * 1024;
pub const PS_SEARCH_PATH = "/sys/class/power_supply";

pub const PowerStatus = enum {
    Unknown,
    Mains,
    Battery,
};

//--------------------------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    const power_status = switch (builtin.os.tag) {
        .linux => try powerCheckLinux(allocator),
        .macos => try powerCheckMacOS(allocator),
        .windows => try powerCheckWindows(),
        else => {
            std.debug.print("Unsupported OS: {s}\n", .{@tagName(builtin.os.tag)});
            std.process.exit(1);
        },
    };
    //------------------------------------------------------------
    var it = try std.process.ArgIterator.initWithAllocator(allocator);
    defer it.deinit();
    _ = it.skip();
    //------------------------------------------------------------
    if (it.next()) |arg1| {
        if (std.mem.eql(u8, arg1, "mains")) {
            std.process.exit(if (power_status == .Mains) 0 else 1);
        } else if (std.mem.eql(u8, arg1, "battery")) {
            std.process.exit(if (power_status == .Battery) 0 else 1);
        } else {
            std.debug.print("invalid arguments\n", .{});
            std.process.exit(1);
        }
    }
    //------------------------------------------------------------
    if (power_status == .Mains) {
        try stdout_interface.writeAll("power supply: mains power\n");
    } else if (power_status == .Battery) {
        try stdout_interface.writeAll("power supply: battery power\n");
    } else {
        try stdout_interface.writeAll("power supply: unknown source\n");
    }
    //------------------------------------------------------------
    std.process.exit(0);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// linux functions
//------------------------------------------------------------

pub fn powerCheckLinux(allocator: std.mem.Allocator) !PowerStatus {
    //------------------------------------------------------------
    return powerCheckFilePath(allocator) catch powerCheck_upower(allocator);
    //------------------------------------------------------------
}

pub fn powerCheckFilePath(allocator: std.mem.Allocator) !PowerStatus {
    //------------------------------------------------------------
    const ps_filepath = try findPSFilePath(allocator);
    defer allocator.free(ps_filepath);
    //------------------------------------------------------------
    var file = try std.fs.cwd().openFile(ps_filepath, .{});
    defer file.close();
    //------------------------------------------------------------
    var buffer: [1]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    //------------------------------------------------------------
    if (bytes_read == 0) return error.ReadError;
    //------------------------------------------------------------
    return if (buffer[0] == '1') .Mains else .Battery;
    //------------------------------------------------------------
}

pub fn findPSFilePath(allocator: std.mem.Allocator) ![]const u8 {
    //------------------------------------------------------------
    var dir = try std.fs.cwd().openDir(PS_SEARCH_PATH, .{ .iterate = true });
    defer dir.close();
    //------------------------------------------------------------
    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dir_entry| {
        if (std.mem.startsWith(u8, dir_entry.name, "AC")) {
            return try std.fmt.allocPrint(allocator, "{s}/{s}/online", .{ PS_SEARCH_PATH, dir_entry.name });
        }
    }
    //------------------------------------------------------------
    return error.FilePathNotFound;
    //------------------------------------------------------------
}

pub fn powerCheck_upower(allocator: std.mem.Allocator) !PowerStatus {
    //------------------------------------------------------------
    const stdout = try childProcess(
        allocator,
        &[_][]const u8{ "upower", "--dump" },
    );
    //------------------------------------------------------------
    defer allocator.free(stdout);
    //------------------------------------------------------------
    var using_battery = false;
    var line_matched = false;
    //------------------------------------------------------------
    var lines = std.mem.splitScalar(u8, stdout, '\n');

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "on-battery:")) |pos| {
            using_battery = std.mem.indexOfPos(u8, line, pos, "yes") != null;
            line_matched = true;
            break;
        }
    }

    if (!line_matched) return error.PowerStatusUnknown;
    //------------------------------------------------------------
    return if (!using_battery) .Mains else .Battery;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// macos functions
//------------------------------------------------------------

pub fn powerCheckMacOS(allocator: std.mem.Allocator) !PowerStatus {
    //------------------------------------------------------------
    return powerCheck_pmset(allocator);
    //------------------------------------------------------------
}

pub fn powerCheck_pmset(allocator: std.mem.Allocator) !PowerStatus {
    //------------------------------------------------------------
    const stdout = try childProcess(
        allocator,
        &[_][]const u8{ "pmset", "-g", "batt" },
    );
    //------------------------------------------------------------
    defer allocator.free(stdout);
    //------------------------------------------------------------
    var using_battery = false;
    var line_matched = false;
    var lines = std.mem.splitScalar(u8, stdout, '\n');

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "Now drawing")) |pos| {
            using_battery = std.mem.indexOfPos(u8, line, pos, "Battery Power") != null;
            line_matched = true;
            break;
        }
    }

    if (!line_matched) return error.PowerStatusUnknown;
    //------------------------------------------------------------
    return if (!using_battery) .Mains else .Battery;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// linux and macos supporting functions
//------------------------------------------------------------

pub fn childProcess(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
) ![]const u8 {
    //------------------------------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    //------------------------------------------------------------
    try child.spawn();
    try child.collectOutput(allocator, &stdout, &stderr, MAX_OUTPUT_BYTES);
    //------------------------------------------------------------
    if (stderr.items.len > 0) {
        std.debug.print("{s}", .{stderr.items});
    }

    const term = child.wait() catch |err| return switch (err) {
        error.FileNotFound => error.ProcessNotFound,
        else => err,
    };

    const exit_code = switch (term) {
        .Exited => term.Exited,
        else => 1,
    };

    if (exit_code > 0) return error.InvalidExitCode;

    return try stdout.toOwnedSlice(allocator);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// windows functions
//------------------------------------------------------------

const windows = std.os.windows;

const SYSTEM_POWER_STATUS = extern struct {
    ACLineStatus: u8,
    BatteryFlag: u8,
    BatteryLifePercent: u8,
    Reserved1: u8,
    BatteryLifeTime: u32,
    BatteryFullLifeTime: u32,
};

extern "kernel32" fn GetSystemPowerStatus(lpSystemPowerStatus: *SYSTEM_POWER_STATUS) callconv(.C) windows.BOOL;

pub fn powerCheckWindows() !PowerStatus {
    //------------------------------------------------------------
    var status: SYSTEM_POWER_STATUS = undefined;
    //------------------------------------------------------------
    if (GetSystemPowerStatus(&status) == windows.FALSE) {
        return error.GetSystemPowerStatusError;
    }
    //------------------------------------------------------------
    return if (status.ACLineStatus == 1) .Mains else .Battery;
    //------------------------------------------------------------
}

//------------------------------------------------------------

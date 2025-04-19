const std = @import("std");
const builtin = @import("builtin");

const pc = @import("main.zig");

//------------------------------------------------------------
// linux functions
//------------------------------------------------------------

test "powerCheckLinux" {
    const result = try pc.powerCheckLinux(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "powerCheckFilePath" {
    const result = try pc.powerCheckFilePath(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "findPSFilePath" {
    const result = try pc.findPSFilePath(std.testing.allocator);
    defer std.testing.allocator.free(result);
    try std.testing.expect(std.mem.startsWith(u8, result, pc.PS_SEARCH_PATH));
    try std.testing.expect(result.len > pc.PS_SEARCH_PATH.len);
}

test "powerCheck_upower" {
    if (pc.powerCheck_upower(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

//------------------------------------------------------------
// macos functions
//------------------------------------------------------------

test "powerCheckMacOS" {
    if (pc.powerCheckMacOS(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

test "powerCheck_pmset" {
    if (pc.powerCheck_pmset(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

//------------------------------------------------------------
// windows functions
//------------------------------------------------------------

test "powerCheckWindows" {
    if (pc.powerCheckWindows()) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        if (builtin.os.tag == .windows) {
            try std.testing.expect(err == error.GetSystemPowerStatusError);
        } else {
            try std.testing.expect(err == error.IncompatibleOS);
        }
    }
}

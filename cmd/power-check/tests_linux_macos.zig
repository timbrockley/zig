const std = @import("std");
const builtin = @import("builtin");

const pc = @import("main.zig");

//------------------------------------------------------------
// linux functions
//------------------------------------------------------------

test "powerCheckLinux" {
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
    const result = try pc.powerCheckLinux(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "powerCheckFilePath" {
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
    const result = try pc.powerCheckFilePath(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "findPSFilePath" {
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
    const result = try pc.findPSFilePath(std.testing.allocator);
    defer std.testing.allocator.free(result);
    try std.testing.expect(std.mem.startsWith(u8, result, pc.PS_SEARCH_PATH));
    try std.testing.expect(result.len > pc.PS_SEARCH_PATH.len);
}

test "powerCheck_upower" {
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
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
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
    if (pc.powerCheckMacOS(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

test "powerCheck_pmset" {
    if (builtin.target.os.tag == .windows) return error.SkipZigTest;
    if (pc.powerCheck_pmset(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

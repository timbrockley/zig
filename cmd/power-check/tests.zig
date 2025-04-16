const std = @import("std");
const builtin = @import("builtin");

const pc = @import("main.zig");

test "power_check_linux" {
    const result = try pc.power_check_linux(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "power_check_filepath" {
    const result = try pc.power_check_filepath(std.testing.allocator);
    try std.testing.expect(result == .Mains or result == .Battery);
}

test "find_ps_filepath" {
    const result = try pc.find_ps_filepath(std.testing.allocator);
    defer std.testing.allocator.free(result);
    try std.testing.expect(std.mem.startsWith(u8, result, pc.PS_SEARCH_PATH));
    try std.testing.expect(result.len > pc.PS_SEARCH_PATH.len);
}

test "power_check_upower" {
    if (pc.power_check_upower(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

test "power_check_macos" {
    if (pc.power_check_macos(std.testing.allocator)) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.ProcessNotFound);
    }
}

test "power_check_windows" {
    if (pc.power_check_windows()) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        if (builtin.os.tag == .windows) {
            try std.testing.expect(err == error.GetSystemPowerStatusError);
        } else {
            try std.testing.expect(err == error.IncompatibleOS);
        }
    }
}

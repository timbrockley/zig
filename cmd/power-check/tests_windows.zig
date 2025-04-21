const std = @import("std");
const builtin = @import("builtin");

const pc = @import("main.zig");

test "powerCheckWindows" {
    if (pc.powerCheckWindows()) |result| {
        try std.testing.expect(result == .Mains or result == .Battery);
    } else |err| {
        try std.testing.expect(err == error.GetSystemPowerStatusError);
    }
}

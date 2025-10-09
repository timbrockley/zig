const std = @import("std");

const DAYS = [_][]const u8{
    "Invalid Index",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
};

fn safeArrayValue1(comptime T: type, default: T, array: []const T, index: usize) T {
    return if (index < array.len) array[index] else default;
}

test "safeArrayValue1" {
    try std.testing.expectEqualStrings("Invalid Index", safeArrayValue1([]const u8, "X", &DAYS, 0));
    try std.testing.expectEqualStrings("Monday", safeArrayValue1([]const u8, "X", &DAYS, 1));
    try std.testing.expectEqualStrings("Tuesday", safeArrayValue1([]const u8, "X", &DAYS, 2));
    try std.testing.expectEqualStrings("Wednesday", safeArrayValue1([]const u8, "X", &DAYS, 3));
    try std.testing.expectEqualStrings("Thursday", safeArrayValue1([]const u8, "X", &DAYS, 4));
    try std.testing.expectEqualStrings("Friday", safeArrayValue1([]const u8, "X", &DAYS, 5));
    try std.testing.expectEqualStrings("Saturday", safeArrayValue1([]const u8, "X", &DAYS, 6));
    try std.testing.expectEqualStrings("Sunday", safeArrayValue1([]const u8, "X", &DAYS, 7));
    try std.testing.expectEqualStrings("X", safeArrayValue1([]const u8, "X", &DAYS, 8));
    try std.testing.expectEqualStrings("X", safeArrayValue1([]const u8, "X", &DAYS, 9999));
}

fn safeArrayValue2(comptime T: type, array: []const T, index: usize) ?T {
    return if (index < array.len) array[index] else null;
}

test "safeArrayValue2" {
    try std.testing.expectEqualStrings("Monday", safeArrayValue2([]const u8, &DAYS, 1).?);
    try std.testing.expectEqualStrings("Tuesday", safeArrayValue2([]const u8, &DAYS, 2).?);
    try std.testing.expectEqualStrings("Wednesday", safeArrayValue2([]const u8, &DAYS, 3).?);
    try std.testing.expectEqualStrings("Thursday", safeArrayValue2([]const u8, &DAYS, 4).?);
    try std.testing.expectEqualStrings("Friday", safeArrayValue2([]const u8, &DAYS, 5).?);
    try std.testing.expectEqualStrings("Saturday", safeArrayValue2([]const u8, &DAYS, 6).?);
    try std.testing.expectEqualStrings("Sunday", safeArrayValue2([]const u8, &DAYS, 7).?);
    try std.testing.expectEqual(@as(?[]const u8, null), safeArrayValue2([]const u8, &DAYS, 8));
    try std.testing.expectEqual(@as(?[]const u8, null), safeArrayValue2([]const u8, &DAYS, 9999));
}

fn safeArrayValue3(comptime T: type, array: []const T, index: usize) !T {
    return if (index < array.len) array[index] else error.OutOfBounds;
}

test "safeArrayValue3" {
    try std.testing.expectEqualStrings("Invalid Index", try safeArrayValue3([]const u8, &DAYS, 0));
    try std.testing.expectEqualStrings("Monday", try safeArrayValue3([]const u8, &DAYS, 1));
    try std.testing.expectEqualStrings("Tuesday", try safeArrayValue3([]const u8, &DAYS, 2));
    try std.testing.expectEqualStrings("Wednesday", try safeArrayValue3([]const u8, &DAYS, 3));
    try std.testing.expectEqualStrings("Thursday", try safeArrayValue3([]const u8, &DAYS, 4));
    try std.testing.expectEqualStrings("Friday", try safeArrayValue3([]const u8, &DAYS, 5));
    try std.testing.expectEqualStrings("Saturday", try safeArrayValue3([]const u8, &DAYS, 6));
    try std.testing.expectEqualStrings("Sunday", try safeArrayValue3([]const u8, &DAYS, 7));
    try std.testing.expectError(error.OutOfBounds, safeArrayValue3([]const u8, &DAYS, 8));
    try std.testing.expectError(error.OutOfBounds, safeArrayValue3([]const u8, &DAYS, 9999));
}

pub fn main() !void {
    //------------------------------------------------------------
    var it = std.process.args();
    const name = if (it.next()) |arg0| std.fs.path.basename(arg0) else "";
    std.debug.print("{s}: main function\n", .{name});
    //------------------------------------------------------------
}

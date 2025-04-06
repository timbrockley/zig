const std = @import("std");

pub fn main() void {
    //----------------------------------------
    const fixed_size = 10_000;
    @setEvalBranchQuota(fixed_size); // increase inline limit for testing
    const array_u8: [fixed_size]u8 = undefined;
    //----------------------------------------
    const start = std.time.nanoTimestamp();
    //----------------------------------------
    for (array_u8) |item| {
        _ = item;
    }
    //----------------------------------------
    const end = std.time.nanoTimestamp();
    //----------------------------------------
    const inline_start = std.time.nanoTimestamp();
    //----------------------------------------
    inline for (array_u8) |inline_item| {
        _ = inline_item;
    }
    //----------------------------------------
    const inline_end = std.time.nanoTimestamp();
    //----------------------------------------
    const time_diff = end - start;

    std.debug.print("time_diff = {d} nano seconds\n", .{time_diff});

    const inline_time_diff = inline_end - inline_start;

    std.debug.print("inline_time_diff = {d} nano seconds\n", .{inline_time_diff});

    const diff = time_diff - inline_time_diff;

    std.debug.print("diff = {d} nano seconds\n", .{diff});
    //----------------------------------------
}

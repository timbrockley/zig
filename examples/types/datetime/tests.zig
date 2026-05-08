//------------------------------------------------------------

const std = @import("std");
const dt = @import("main.zig");

//------------------------------------------------------------
// fromTimestamp
//------------------------------------------------------------

test "fromTimestamp" {
    try std.testing.expectError(error.InvalidTimestamp, dt.fromTimestamp(-1));
    try std.testing.expectError(error.InvalidTimestamp, dt.fromTimestamp(253_402_300_799 + 1));
    try std.testing.expectEqual(dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(0));
    try std.testing.expectEqual(dt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(489024000));
    try std.testing.expectEqual(dt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, dt.fromTimestamp(946684799));
    try std.testing.expectEqual(dt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(951782400));
    try std.testing.expectEqual(dt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(983404800));
    try std.testing.expectEqual(dt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(1709164800));
    try std.testing.expectEqual(dt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(1740787200));
    try std.testing.expectEqual(dt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(1835395200));
    try std.testing.expectEqual(dt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, dt.fromTimestamp(1867017600));
    try std.testing.expectEqual(dt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, dt.fromTimestamp(253402300799));
}

//------------------------------------------------------------
// toTimestamp
//------------------------------------------------------------

test "toTimestamp" {
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1969, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 0, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 13, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 0, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 24, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 60, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 60 }));
    try std.testing.expectEqual(0, dt.toTimestamp(dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(489024000, dt.toTimestamp(dt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(946684799, dt.toTimestamp(dt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectEqual(951782400, dt.toTimestamp(dt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(983404800, dt.toTimestamp(dt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1709164800, dt.toTimestamp(dt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1740787200, dt.toTimestamp(dt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1835395200, dt.toTimestamp(dt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1867017600, dt.toTimestamp(dt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(253402300799, dt.toTimestamp(dt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------

test "toTimestamp <=> fromTimestamp" {
    const dates = [_]dt.DateTime{
        dt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 },
        dt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 42 },
        dt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        dt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 },
    };

    for (dates) |datetime| {
        const timestamp = try dt.toTimestamp(datetime);
        const new_datetime = try dt.fromTimestamp(timestamp);
        try std.testing.expectEqual(datetime, new_datetime);
    }
}

//------------------------------------------------------------

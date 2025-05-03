//------------------------------------------------------------
const std = @import("std");
const tbt = @import("time.zig");

//------------------------------------------------------------
// DateTime
//------------------------------------------------------------

test "now" {
    const datetime = tbt.now();
    try std.testing.expect(@TypeOf(datetime) == tbt.DateTime);
    try std.testing.expect(datetime.year > 0);
    try std.testing.expect(datetime.month > 0);
    try std.testing.expect(datetime.day > 0);
}

//------------------------------------------------------------
// unix_timestamp
//------------------------------------------------------------

test "unix_timestamp" {
    const result = tbt.unix_timestamp();
    try std.testing.expect(@TypeOf(result) == i64);
    try std.testing.expect(result > 0);
}

//------------------------------------------------------------
// fromTimestamp
//------------------------------------------------------------

test "fromTimestamp" {
    try std.testing.expectError(error.InvalidTimestamp, tbt.fromTimestamp(tbt.SECONDS_MIN - 1));
    try std.testing.expectError(error.InvalidTimestamp, tbt.fromTimestamp(tbt.SECONDS_MAX + 1));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(tbt.SECONDS_MIN));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1900, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(-2208988800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1969, .month = 12, .day = 31, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(-86400));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(0));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(489024000));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, tbt.fromTimestamp(946684799));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(951782400));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(983404800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(1709164800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(1740787200));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(1835395200));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.fromTimestamp(1867017600));
    try std.testing.expectEqual(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, tbt.fromTimestamp(tbt.SECONDS_MAX));
}

//------------------------------------------------------------
// toTimestamp
//------------------------------------------------------------

test "toTimestamp" {
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 0, .month = 0, .day = 0, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 0, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 13, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 0, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 24, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 60, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 60 }));

    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 0, .month = 1, .day = 1, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.toTimestamp(tbt.DateTime{ .year = 10000, .month = 0, .day = 0, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(tbt.SECONDS_MIN, tbt.toTimestamp(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(-2208988800, tbt.toTimestamp(tbt.DateTime{ .year = 1900, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(-86400, tbt.toTimestamp(tbt.DateTime{ .year = 1969, .month = 12, .day = 31, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(0, tbt.toTimestamp(tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(489024000, tbt.toTimestamp(tbt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(946684799, tbt.toTimestamp(tbt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectEqual(951782400, tbt.toTimestamp(tbt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(983404800, tbt.toTimestamp(tbt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1709164800, tbt.toTimestamp(tbt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1740787200, tbt.toTimestamp(tbt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1835395200, tbt.toTimestamp(tbt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1867017600, tbt.toTimestamp(tbt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(tbt.SECONDS_MAX, tbt.toTimestamp(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------
// toTimestamp <=> fromTimestamp
//------------------------------------------------------------

test "toTimestamp <=> fromTimestamp" {
    const dates = [_]tbt.DateTime{
        tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 1900, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 1969, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 },
        tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 },
        tbt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 },
        tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 },
    };

    for (dates) |datetime| {
        const timestamp = try tbt.toTimestamp(datetime);
        const new_datetime = try tbt.fromTimestamp(timestamp);
        try std.testing.expectEqual(datetime, new_datetime);
    }
}

//------------------------------------------------------------
// checkDateTime
//------------------------------------------------------------

test "checkDateTime" {
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 0, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 1, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 2, .day = 30, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 3, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 4, .day = 31, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 5, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 6, .day = 31, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 7, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 8, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 9, .day = 31, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 10, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 11, .day = 31, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 12, .day = 32, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 2025, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 2024, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 2025, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 9999, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 24, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 23, .minute = 60, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 23, .minute = 59, .second = 60 }));

    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkDateTime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------
// checkDate
//------------------------------------------------------------

test "checkDate" {
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 0, .month = 1, .day = 1 }));

    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 1, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 2, .day = 30 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 3, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 4, .day = 31 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 5, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 6, .day = 31 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 7, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 8, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 9, .day = 31 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 10, .day = 32 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 11, .day = 31 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2024, .month = 12, .day = 32 }));

    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 1, .month = 2, .day = 29 }));
    try std.testing.expectEqual(false, tbt.checkDate(tbt.Date{ .year = 2025, .month = 2, .day = 29 }));

    try std.testing.expectEqual(true, tbt.checkDate(tbt.Date{ .year = 1, .month = 1, .day = 1 }));
    try std.testing.expectEqual(true, tbt.checkDate(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(true, tbt.checkDate(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual(true, tbt.checkDate(tbt.Date{ .year = 2025, .month = 1, .day = 1 }));
    try std.testing.expectEqual(true, tbt.checkDate(tbt.Date{ .year = 9999, .month = 1, .day = 1 }));
}

//------------------------------------------------------------
// Time
//------------------------------------------------------------

test "Time" {
    try std.testing.expectEqual(false, tbt.checkTime(tbt.Time{ .hour = 24, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkTime(tbt.Time{ .hour = 23, .minute = 60, .second = 0 }));
    try std.testing.expectEqual(false, tbt.checkTime(tbt.Time{ .hour = 23, .minute = 59, .second = 60 }));

    try std.testing.expectEqual(true, tbt.checkTime(tbt.Time{ .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(true, tbt.checkTime(tbt.Time{ .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------
// lastDayOfMonth
//------------------------------------------------------------

test "lastDayOfMonth" {
    try std.testing.expectEqual(0, tbt.lastDayOfMonth(tbt.Date{ .year = 0, .month = 0, .day = 0 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 1, .month = 1, .day = 1 }));

    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual(29, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 2, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 3, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 4, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 5, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 6, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 8, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 9, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 10, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 11, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2024, .month = 12, .day = 1 }));

    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 1, .day = 1 }));
    try std.testing.expectEqual(28, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 2, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 3, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 4, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 5, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 6, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 7, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 8, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 9, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 10, .day = 1 }));
    try std.testing.expectEqual(30, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 11, .day = 1 }));
    try std.testing.expectEqual(31, tbt.lastDayOfMonth(tbt.Date{ .year = 2025, .month = 12, .day = 1 }));
}

//------------------------------------------------------------
// isLeapYear
//------------------------------------------------------------

test "isLeapYear" {
    try std.testing.expectEqual(true, tbt.isLeapYear(2000));
    try std.testing.expectEqual(false, tbt.isLeapYear(2001));
    try std.testing.expectEqual(false, tbt.isLeapYear(2002));
    try std.testing.expectEqual(false, tbt.isLeapYear(2003));
    try std.testing.expectEqual(true, tbt.isLeapYear(2004));
    try std.testing.expectEqual(false, tbt.isLeapYear(2005));
    try std.testing.expectEqual(false, tbt.isLeapYear(2006));
    try std.testing.expectEqual(false, tbt.isLeapYear(2007));
    try std.testing.expectEqual(true, tbt.isLeapYear(2008));
    try std.testing.expectEqual(false, tbt.isLeapYear(2009));
    try std.testing.expectEqual(false, tbt.isLeapYear(2010));
}

//------------------------------------------------------------
// isDST
//------------------------------------------------------------

test "isDST" {
    try std.testing.expectEqual(false, tbt.isDST(tbt.Date{ .year = 2024, .month = 3, .day = 30 }));
    try std.testing.expectEqual(true, tbt.isDST(tbt.Date{ .year = 2024, .month = 3, .day = 31 }));
    try std.testing.expectEqual(true, tbt.isDST(tbt.Date{ .year = 2024, .month = 10, .day = 26 }));
    try std.testing.expectEqual(false, tbt.isDST(tbt.Date{ .year = 2024, .month = 10, .day = 27 }));
    try std.testing.expectEqual(false, tbt.isDST(tbt.Date{ .year = 2025, .month = 3, .day = 29 }));
    try std.testing.expectEqual(true, tbt.isDST(tbt.Date{ .year = 2025, .month = 3, .day = 30 }));
    try std.testing.expectEqual(true, tbt.isDST(tbt.Date{ .year = 2025, .month = 10, .day = 25 }));
    try std.testing.expectEqual(false, tbt.isDST(tbt.Date{ .year = 2025, .month = 10, .day = 26 }));
}

//------------------------------------------------------------
// cymd
//------------------------------------------------------------

test "cymd" {
    try std.testing.expectEqual(19000101, tbt.cymd(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(19700101, tbt.cymd(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(20240701, tbt.cymd(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(99991231, tbt.cymd(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// ymd
//------------------------------------------------------------

test "ymd" {
    try std.testing.expectEqual(101, tbt.ymd(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(700101, tbt.ymd(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(240701, tbt.ymd(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(991231, tbt.ymd(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// cy
//------------------------------------------------------------

test "cy" {
    try std.testing.expectEqual(1900, tbt.cy(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1970, tbt.cy(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2024, tbt.cy(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(9999, tbt.cy(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// y
//------------------------------------------------------------

test "y" {
    try std.testing.expectEqual(0, tbt.y(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(70, tbt.y(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(24, tbt.y(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(99, tbt.y(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// m
//------------------------------------------------------------

test "m" {
    try std.testing.expectEqual(1, tbt.m(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.m(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(7, tbt.m(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(12, tbt.m(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// d
//------------------------------------------------------------

test "d" {
    try std.testing.expectEqual(1, tbt.d(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.d(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.d(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(31, tbt.d(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// md
//------------------------------------------------------------

test "md" {
    try std.testing.expectEqual(101, tbt.md(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(101, tbt.md(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(701, tbt.md(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(1231, tbt.md(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// dm
//------------------------------------------------------------

test "dm" {
    try std.testing.expectEqual(101, tbt.dm(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
    try std.testing.expectEqual(101, tbt.dm(tbt.Date{ .year = 1970, .month = 1, .day = 1 }));
    try std.testing.expectEqual(107, tbt.dm(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(3112, tbt.dm(tbt.Date{ .year = 9999, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// cyddd
//------------------------------------------------------------

test "cyddd" {
    try std.testing.expectEqual(2024001, tbt.cyddd(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2024032, tbt.cyddd(tbt.Date{ .year = 2024, .month = 2, .day = 1 }));
    try std.testing.expectEqual(2024061, tbt.cyddd(tbt.Date{ .year = 2024, .month = 3, .day = 1 }));
    try std.testing.expectEqual(2024092, tbt.cyddd(tbt.Date{ .year = 2024, .month = 4, .day = 1 }));
    try std.testing.expectEqual(2024122, tbt.cyddd(tbt.Date{ .year = 2024, .month = 5, .day = 1 }));
    try std.testing.expectEqual(2024153, tbt.cyddd(tbt.Date{ .year = 2024, .month = 6, .day = 1 }));
    try std.testing.expectEqual(2024183, tbt.cyddd(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(2024214, tbt.cyddd(tbt.Date{ .year = 2024, .month = 8, .day = 1 }));
    try std.testing.expectEqual(2024245, tbt.cyddd(tbt.Date{ .year = 2024, .month = 9, .day = 1 }));
    try std.testing.expectEqual(2024275, tbt.cyddd(tbt.Date{ .year = 2024, .month = 10, .day = 1 }));
    try std.testing.expectEqual(2024306, tbt.cyddd(tbt.Date{ .year = 2024, .month = 11, .day = 1 }));
    try std.testing.expectEqual(2024336, tbt.cyddd(tbt.Date{ .year = 2024, .month = 12, .day = 1 }));

    try std.testing.expectEqual(2025001, tbt.cyddd(tbt.Date{ .year = 2025, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2025032, tbt.cyddd(tbt.Date{ .year = 2025, .month = 2, .day = 1 }));
    try std.testing.expectEqual(2025060, tbt.cyddd(tbt.Date{ .year = 2025, .month = 3, .day = 1 }));
    try std.testing.expectEqual(2025091, tbt.cyddd(tbt.Date{ .year = 2025, .month = 4, .day = 1 }));
    try std.testing.expectEqual(2025121, tbt.cyddd(tbt.Date{ .year = 2025, .month = 5, .day = 1 }));
    try std.testing.expectEqual(2025152, tbt.cyddd(tbt.Date{ .year = 2025, .month = 6, .day = 1 }));
    try std.testing.expectEqual(2025182, tbt.cyddd(tbt.Date{ .year = 2025, .month = 7, .day = 1 }));
    try std.testing.expectEqual(2025213, tbt.cyddd(tbt.Date{ .year = 2025, .month = 8, .day = 1 }));
    try std.testing.expectEqual(2025244, tbt.cyddd(tbt.Date{ .year = 2025, .month = 9, .day = 1 }));
    try std.testing.expectEqual(2025274, tbt.cyddd(tbt.Date{ .year = 2025, .month = 10, .day = 1 }));
    try std.testing.expectEqual(2025305, tbt.cyddd(tbt.Date{ .year = 2025, .month = 11, .day = 1 }));
    try std.testing.expectEqual(2025335, tbt.cyddd(tbt.Date{ .year = 2025, .month = 12, .day = 1 }));
}

//------------------------------------------------------------
// ddd
//------------------------------------------------------------

test "ddd" {
    try std.testing.expectEqual(1, tbt.ddd(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual(32, tbt.ddd(tbt.Date{ .year = 2024, .month = 2, .day = 1 }));
    try std.testing.expectEqual(61, tbt.ddd(tbt.Date{ .year = 2024, .month = 3, .day = 1 }));
}

//------------------------------------------------------------
// dow
//------------------------------------------------------------

test "dow" {
    try std.testing.expectEqual(1, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual(2, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 2 }));
    try std.testing.expectEqual(3, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 3 }));
    try std.testing.expectEqual(4, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 4 }));
    try std.testing.expectEqual(5, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 5 }));
    try std.testing.expectEqual(6, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 6 }));
    try std.testing.expectEqual(7, tbt.dow(tbt.Date{ .year = 2024, .month = 7, .day = 7 }));

    try std.testing.expectEqual(1, tbt.dow(tbt.Date{ .year = 2025, .month = 6, .day = 30 }));
    try std.testing.expectEqual(2, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 1 }));
    try std.testing.expectEqual(3, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 2 }));
    try std.testing.expectEqual(4, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 3 }));
    try std.testing.expectEqual(5, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 4 }));
    try std.testing.expectEqual(6, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 5 }));
    try std.testing.expectEqual(7, tbt.dow(tbt.Date{ .year = 2025, .month = 7, .day = 6 }));
}

//------------------------------------------------------------
// dowD
//------------------------------------------------------------

test "dowD" {
    try std.testing.expectEqual("Mon", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual("Tue", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 2 }));
    try std.testing.expectEqual("Wed", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 3 }));
    try std.testing.expectEqual("Thu", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 4 }));
    try std.testing.expectEqual("Fri", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 5 }));
    try std.testing.expectEqual("Sat", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 6 }));
    try std.testing.expectEqual("Sun", tbt.dowD(tbt.Date{ .year = 2024, .month = 7, .day = 7 }));
}

//------------------------------------------------------------
// dowDD
//------------------------------------------------------------

test "dowDD" {
    try std.testing.expectEqual("Monday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual("Tuesday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 2 }));
    try std.testing.expectEqual("Wednesday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 3 }));
    try std.testing.expectEqual("Thursday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 4 }));
    try std.testing.expectEqual("Friday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 5 }));
    try std.testing.expectEqual("Saturday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 6 }));
    try std.testing.expectEqual("Sunday", tbt.dowDD(tbt.Date{ .year = 2024, .month = 7, .day = 7 }));
}

//------------------------------------------------------------
// monthM
//------------------------------------------------------------

test "monthM" {
    try std.testing.expectEqual("Jan", tbt.monthM(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual("Feb", tbt.monthM(tbt.Date{ .year = 2024, .month = 2, .day = 1 }));
    try std.testing.expectEqual("Mar", tbt.monthM(tbt.Date{ .year = 2024, .month = 3, .day = 1 }));
    try std.testing.expectEqual("Apr", tbt.monthM(tbt.Date{ .year = 2024, .month = 4, .day = 1 }));
    try std.testing.expectEqual("May", tbt.monthM(tbt.Date{ .year = 2024, .month = 5, .day = 1 }));
    try std.testing.expectEqual("Jun", tbt.monthM(tbt.Date{ .year = 2024, .month = 6, .day = 1 }));
    try std.testing.expectEqual("Jul", tbt.monthM(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual("Aug", tbt.monthM(tbt.Date{ .year = 2024, .month = 8, .day = 1 }));
    try std.testing.expectEqual("Sep", tbt.monthM(tbt.Date{ .year = 2024, .month = 9, .day = 1 }));
    try std.testing.expectEqual("Oct", tbt.monthM(tbt.Date{ .year = 2024, .month = 10, .day = 1 }));
    try std.testing.expectEqual("Nov", tbt.monthM(tbt.Date{ .year = 2024, .month = 11, .day = 1 }));
    try std.testing.expectEqual("Dec", tbt.monthM(tbt.Date{ .year = 2024, .month = 12, .day = 1 }));
}

//------------------------------------------------------------
// monthMM
//------------------------------------------------------------

test "monthMM" {
    try std.testing.expectEqual("January", tbt.monthMM(tbt.Date{ .year = 2024, .month = 1, .day = 1 }));
    try std.testing.expectEqual("February", tbt.monthMM(tbt.Date{ .year = 2024, .month = 2, .day = 1 }));
    try std.testing.expectEqual("March", tbt.monthMM(tbt.Date{ .year = 2024, .month = 3, .day = 1 }));
    try std.testing.expectEqual("April", tbt.monthMM(tbt.Date{ .year = 2024, .month = 4, .day = 1 }));
    try std.testing.expectEqual("May", tbt.monthMM(tbt.Date{ .year = 2024, .month = 5, .day = 1 }));
    try std.testing.expectEqual("June", tbt.monthMM(tbt.Date{ .year = 2024, .month = 6, .day = 1 }));
    try std.testing.expectEqual("July", tbt.monthMM(tbt.Date{ .year = 2024, .month = 7, .day = 1 }));
    try std.testing.expectEqual("August", tbt.monthMM(tbt.Date{ .year = 2024, .month = 8, .day = 1 }));
    try std.testing.expectEqual("September", tbt.monthMM(tbt.Date{ .year = 2024, .month = 9, .day = 1 }));
    try std.testing.expectEqual("October", tbt.monthMM(tbt.Date{ .year = 2024, .month = 10, .day = 1 }));
    try std.testing.expectEqual("November", tbt.monthMM(tbt.Date{ .year = 2024, .month = 11, .day = 1 }));
    try std.testing.expectEqual("December", tbt.monthMM(tbt.Date{ .year = 2024, .month = 12, .day = 1 }));
}

//------------------------------------------------------------
// isoYear
//------------------------------------------------------------

test "isoYear" {
    try std.testing.expectEqual(2001, tbt.isoYear(tbt.Date{ .year = 2001, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2002, tbt.isoYear(tbt.Date{ .year = 2001, .month = 12, .day = 31 }));
    try std.testing.expectEqual(2002, tbt.isoYear(tbt.Date{ .year = 2002, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2003, tbt.isoYear(tbt.Date{ .year = 2002, .month = 12, .day = 31 }));
    try std.testing.expectEqual(2003, tbt.isoYear(tbt.Date{ .year = 2003, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2004, tbt.isoYear(tbt.Date{ .year = 2003, .month = 12, .day = 31 }));
    try std.testing.expectEqual(2004, tbt.isoYear(tbt.Date{ .year = 2004, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2004, tbt.isoYear(tbt.Date{ .year = 2004, .month = 12, .day = 31 }));
    try std.testing.expectEqual(2004, tbt.isoYear(tbt.Date{ .year = 2005, .month = 1, .day = 1 }));
    try std.testing.expectEqual(2005, tbt.isoYear(tbt.Date{ .year = 2005, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// cywk
//------------------------------------------------------------

test "cywk" {
    try std.testing.expectEqual(200101, tbt.cywk(tbt.Date{ .year = 2001, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200201, tbt.cywk(tbt.Date{ .year = 2001, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200201, tbt.cywk(tbt.Date{ .year = 2002, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200301, tbt.cywk(tbt.Date{ .year = 2002, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200301, tbt.cywk(tbt.Date{ .year = 2003, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200401, tbt.cywk(tbt.Date{ .year = 2003, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200401, tbt.cywk(tbt.Date{ .year = 2004, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200453, tbt.cywk(tbt.Date{ .year = 2004, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200453, tbt.cywk(tbt.Date{ .year = 2005, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200453, tbt.cywk(tbt.Date{ .year = 2005, .month = 1, .day = 2 }));
    try std.testing.expectEqual(200552, tbt.cywk(tbt.Date{ .year = 2005, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200552, tbt.cywk(tbt.Date{ .year = 2006, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200601, tbt.cywk(tbt.Date{ .year = 2006, .month = 1, .day = 2 }));
    try std.testing.expectEqual(200652, tbt.cywk(tbt.Date{ .year = 2006, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200701, tbt.cywk(tbt.Date{ .year = 2007, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200752, tbt.cywk(tbt.Date{ .year = 2007, .month = 12, .day = 30 }));
    try std.testing.expectEqual(200801, tbt.cywk(tbt.Date{ .year = 2007, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200801, tbt.cywk(tbt.Date{ .year = 2008, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200852, tbt.cywk(tbt.Date{ .year = 2008, .month = 12, .day = 28 }));
    try std.testing.expectEqual(200901, tbt.cywk(tbt.Date{ .year = 2008, .month = 12, .day = 29 }));
    try std.testing.expectEqual(200901, tbt.cywk(tbt.Date{ .year = 2008, .month = 12, .day = 30 }));
    try std.testing.expectEqual(200901, tbt.cywk(tbt.Date{ .year = 2008, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200901, tbt.cywk(tbt.Date{ .year = 2009, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200953, tbt.cywk(tbt.Date{ .year = 2009, .month = 12, .day = 31 }));
    try std.testing.expectEqual(200953, tbt.cywk(tbt.Date{ .year = 2010, .month = 1, .day = 1 }));
    try std.testing.expectEqual(200953, tbt.cywk(tbt.Date{ .year = 2010, .month = 1, .day = 2 }));
    try std.testing.expectEqual(200953, tbt.cywk(tbt.Date{ .year = 2010, .month = 1, .day = 3 }));
    try std.testing.expectEqual(201052, tbt.cywk(tbt.Date{ .year = 2010, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201052, tbt.cywk(tbt.Date{ .year = 2011, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201152, tbt.cywk(tbt.Date{ .year = 2011, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201152, tbt.cywk(tbt.Date{ .year = 2012, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201301, tbt.cywk(tbt.Date{ .year = 2012, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201301, tbt.cywk(tbt.Date{ .year = 2013, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201401, tbt.cywk(tbt.Date{ .year = 2013, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201401, tbt.cywk(tbt.Date{ .year = 2014, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201501, tbt.cywk(tbt.Date{ .year = 2014, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201501, tbt.cywk(tbt.Date{ .year = 2015, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201553, tbt.cywk(tbt.Date{ .year = 2015, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201553, tbt.cywk(tbt.Date{ .year = 2016, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201652, tbt.cywk(tbt.Date{ .year = 2016, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201652, tbt.cywk(tbt.Date{ .year = 2017, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201752, tbt.cywk(tbt.Date{ .year = 2017, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201801, tbt.cywk(tbt.Date{ .year = 2018, .month = 1, .day = 1 }));
    try std.testing.expectEqual(201901, tbt.cywk(tbt.Date{ .year = 2018, .month = 12, .day = 31 }));
    try std.testing.expectEqual(201901, tbt.cywk(tbt.Date{ .year = 2019, .month = 1, .day = 1 }));
    try std.testing.expectEqual(202001, tbt.cywk(tbt.Date{ .year = 2019, .month = 12, .day = 31 }));
    try std.testing.expectEqual(202001, tbt.cywk(tbt.Date{ .year = 2020, .month = 1, .day = 1 }));
    try std.testing.expectEqual(202053, tbt.cywk(tbt.Date{ .year = 2020, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// wk
//------------------------------------------------------------

test "wk" {
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2001, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2001, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2002, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2002, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2003, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2003, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2004, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2004, .month = 12, .day = 31 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2005, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2005, .month = 1, .day = 2 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2005, .month = 12, .day = 31 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2006, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2006, .month = 1, .day = 2 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2006, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2007, .month = 1, .day = 1 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2007, .month = 12, .day = 30 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2007, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2008, .month = 1, .day = 1 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2008, .month = 12, .day = 28 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2008, .month = 12, .day = 29 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2008, .month = 12, .day = 30 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2008, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2009, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2009, .month = 12, .day = 31 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2010, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2010, .month = 1, .day = 2 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2010, .month = 1, .day = 3 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2010, .month = 12, .day = 31 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2011, .month = 1, .day = 1 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2011, .month = 12, .day = 31 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2012, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2012, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2013, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2013, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2014, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2014, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2015, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2015, .month = 12, .day = 31 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2016, .month = 1, .day = 1 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2016, .month = 12, .day = 31 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2017, .month = 1, .day = 1 }));
    try std.testing.expectEqual(52, tbt.wk(tbt.Date{ .year = 2017, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2018, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2018, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2019, .month = 1, .day = 1 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2019, .month = 12, .day = 31 }));
    try std.testing.expectEqual(1, tbt.wk(tbt.Date{ .year = 2020, .month = 1, .day = 1 }));
    try std.testing.expectEqual(53, tbt.wk(tbt.Date{ .year = 2020, .month = 12, .day = 31 }));
}

//------------------------------------------------------------
// q
//------------------------------------------------------------

test "q" {
    try std.testing.expectEqual(1, tbt.q(1));
    try std.testing.expectEqual(1, tbt.q(2));
    try std.testing.expectEqual(1, tbt.q(3));
    try std.testing.expectEqual(2, tbt.q(4));
    try std.testing.expectEqual(2, tbt.q(5));
    try std.testing.expectEqual(2, tbt.q(6));
    try std.testing.expectEqual(3, tbt.q(7));
    try std.testing.expectEqual(3, tbt.q(8));
    try std.testing.expectEqual(3, tbt.q(9));
    try std.testing.expectEqual(4, tbt.q(10));
    try std.testing.expectEqual(4, tbt.q(11));
    try std.testing.expectEqual(4, tbt.q(12));
}

//------------------------------------------------------------
// hhmmss
//------------------------------------------------------------

test "hhmmss" {
    try std.testing.expectEqual(112233, tbt.hhmmss(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// hhmm
//------------------------------------------------------------

test "hhmm" {
    try std.testing.expectEqual(1122, tbt.hhmm(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// hh
//------------------------------------------------------------

test "hh" {
    try std.testing.expectEqual(11, tbt.hh(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// hhmm
//------------------------------------------------------------

test "mm" {
    try std.testing.expectEqual(22, tbt.mm(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// hhmm
//------------------------------------------------------------

test "ss" {
    try std.testing.expectEqual(33, tbt.ss(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// hhmmss_to_seconds
//------------------------------------------------------------

test "hhmmss_to_seconds" {
    try std.testing.expectEqual(40953, tbt.hhmmss_to_seconds(112233));
}

//------------------------------------------------------------
// seconds_to_hhmmss
//------------------------------------------------------------

test "seconds_to_hhmmss" {
    try std.testing.expectEqual(112233, tbt.seconds_to_hhmmss(40953));
}

//------------------------------------------------------------
// hhmm_to_mins
//------------------------------------------------------------

test "hhmm_to_mins" {
    try std.testing.expectEqual(682, tbt.hhmm_to_mins(1122));
}

//------------------------------------------------------------
// seconds_to_hhmmss
//------------------------------------------------------------

test "mins_to_hhmm" {
    try std.testing.expectEqual(1122, tbt.mins_to_hhmm(682));
}

//------------------------------------------------------------

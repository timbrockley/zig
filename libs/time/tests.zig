//------------------------------------------------------------

const std = @import("std");
const tbt = @import("time.zig");

//------------------------------------------------------------
// toDateTime
//------------------------------------------------------------

test "toDateTime" {
    //------------------------------------------------------------
    const datetime1 = tbt.toDateTime(tbt.Date{ .year = 1111, .month = 22, .day = 33 });
    //------------------------------------------------------------
    try std.testing.expect(@TypeOf(datetime1) == tbt.DateTime);
    try std.testing.expectEqual(1111, datetime1.year);
    try std.testing.expectEqual(22, datetime1.month);
    try std.testing.expectEqual(33, datetime1.day);
    //------------------------------------------------------------
    const datetime2 = tbt.toDateTime(tbt.Time{ .hour = 11, .minute = 22, .second = 33, .millisecond = 444 });
    //------------------------------------------------------------
    try std.testing.expect(@TypeOf(datetime2) == tbt.DateTime);
    try std.testing.expectEqual(11, datetime2.hour);
    try std.testing.expectEqual(22, datetime2.minute);
    try std.testing.expectEqual(33, datetime2.second);
    try std.testing.expectEqual(444, datetime2.millisecond);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// toDate
//------------------------------------------------------------

test "toDate" {
    //------------------------------------------------------------
    const date = tbt.toDate(tbt.DateTime{ .year = 1111, .month = 22, .day = 33 });
    //------------------------------------------------------------
    try std.testing.expect(@TypeOf(date) == tbt.Date);
    try std.testing.expectEqual(1111, date.year);
    try std.testing.expectEqual(22, date.month);
    try std.testing.expectEqual(33, date.day);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// toTime
//------------------------------------------------------------

test "toTime" {
    //------------------------------------------------------------
    const time = tbt.toTime(tbt.DateTime{ .hour = 11, .minute = 22, .second = 33, .millisecond = 444 });
    //------------------------------------------------------------
    try std.testing.expect(@TypeOf(time) == tbt.Time);
    try std.testing.expectEqual(11, time.hour);
    try std.testing.expectEqual(22, time.minute);
    try std.testing.expectEqual(33, time.second);
    try std.testing.expectEqual(444, time.millisecond);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// now
//------------------------------------------------------------

test "now" {
    const datetime = try tbt.now(std.testing.io);
    try std.testing.expect(@TypeOf(datetime) == tbt.DateTime);
    try std.testing.expect(datetime.year > 0);
    try std.testing.expect(datetime.month > 0);
    try std.testing.expect(datetime.day > 0);
}

//------------------------------------------------------------
// unixTimestamp
//------------------------------------------------------------

test "unixTimestamp" {
    const result = tbt.unixTimestamp(std.testing.io);
    const expected = std.Io.Timestamp.now(std.testing.io, .real).toSeconds();

    try std.testing.expect(@TypeOf(result) == i64);
    try std.testing.expect(result > 0);

    const delta = @abs(result - expected);
    try std.testing.expect(delta <= 1);
}

//------------------------------------------------------------
// unixMilliseconds
//------------------------------------------------------------

test "unixMilliseconds" {
    const result = tbt.unixMilliseconds(std.testing.io);
    const expected = std.Io.Timestamp.now(std.testing.io, .real).toMilliseconds();

    try std.testing.expect(@TypeOf(result) == i64);
    try std.testing.expect(result > 0);

    const delta = @abs(result - expected);
    try std.testing.expect(delta <= 100);
}

//------------------------------------------------------------
// unixNanoseconds
//------------------------------------------------------------

test "unixNanoseconds" {
    const result = tbt.unixNanoseconds(std.testing.io);
    const expected = std.Io.Timestamp.now(std.testing.io, .real).toNanoseconds();

    try std.testing.expect(@TypeOf(result) == i96);
    try std.testing.expect(result > 0);

    const delta = @abs(result - expected);
    try std.testing.expect(delta <= 100_000_000);
}

//------------------------------------------------------------
// utms
//------------------------------------------------------------

test "utms" {
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 0, .month = 0, .day = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 1 }));

    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MIN * 1000, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 }));
    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MAX * 1000 + 999, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59, .millisecond = 999 }));
}

//------------------------------------------------------------
// ut
//------------------------------------------------------------

test "ut" {
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 0, .month = 1, .day = 1, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 10000, .month = 0, .day = 0, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MIN, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MAX, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------
// datetime_to_unix_milliseconds
//------------------------------------------------------------

test "datetime_to_unix_milliseconds" {
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 0, .month = 0, .day = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 1 }));

    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MIN * 1000, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 }));
    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MAX * 1000 + 999, tbt.datetime_to_unix_milliseconds(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59, .millisecond = 999 }));
}

//------------------------------------------------------------
// unix_milliseconds_to_datetime
//------------------------------------------------------------

test "unix_milliseconds_to_datetime" {
    try std.testing.expectError(error.InvalidUnixMilliseconds, tbt.unix_milliseconds_to_datetime(tbt.UNIX_TIMESTAMP_MIN * 1000 - 1));
    try std.testing.expectError(error.InvalidUnixMilliseconds, tbt.unix_milliseconds_to_datetime(tbt.UNIX_TIMESTAMP_MAX * 1000 + 1000));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 }, tbt.unix_milliseconds_to_datetime(tbt.UNIX_TIMESTAMP_MIN * 1000));
    try std.testing.expectEqual(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59, .millisecond = 999 }, tbt.unix_milliseconds_to_datetime(tbt.UNIX_TIMESTAMP_MAX * 1000 + 999));
}

//------------------------------------------------------------
// datetime_to_unixtime
//------------------------------------------------------------

test "datetime_to_unixtime" {
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 0, .month = 0, .day = 0, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 13, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 0, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 32, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 24, .minute = 0, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 60, .second = 0 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 60 }));

    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 0, .month = 1, .day = 1, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectError(error.InvalidDateTime, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 10000, .month = 0, .day = 0, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MIN, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(-2208988800, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1900, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(-86400, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1969, .month = 12, .day = 31, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(0, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }));

    try std.testing.expectEqual(489024000, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(946684799, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectEqual(951782400, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(981173106, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2001, .month = 2, .day = 3, .hour = 4, .minute = 5, .second = 6 }));
    try std.testing.expectEqual(983404800, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1164977125, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2006, .month = 12, .day = 1, .hour = 12, .minute = 45, .second = 25 }));
    try std.testing.expectEqual(1709164800, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1740787200, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1835395200, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(1867017600, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }));
    try std.testing.expectEqual(tbt.UNIX_TIMESTAMP_MAX, tbt.datetime_to_unixtime(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
}

//------------------------------------------------------------
// unixtime_to_datetime
//------------------------------------------------------------

test "unixtime_to_datetime" {
    try std.testing.expectError(error.InvalidUnixTimestamp, tbt.unixtime_to_datetime(tbt.UNIX_TIMESTAMP_MIN - 1));
    try std.testing.expectError(error.InvalidUnixTimestamp, tbt.unixtime_to_datetime(tbt.UNIX_TIMESTAMP_MAX + 1));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(tbt.UNIX_TIMESTAMP_MIN));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1900, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(-2208988800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1969, .month = 12, .day = 31, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(-86400));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(0));

    try std.testing.expectEqual(tbt.DateTime{ .year = 1985, .month = 7, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(489024000));
    try std.testing.expectEqual(tbt.DateTime{ .year = 1999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, tbt.unixtime_to_datetime(946684799));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2000, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(951782400));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2001, .month = 2, .day = 3, .hour = 4, .minute = 5, .second = 6 }, tbt.unixtime_to_datetime(981173106));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2001, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(983404800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2006, .month = 12, .day = 1, .hour = 12, .minute = 45, .second = 25 }, tbt.unixtime_to_datetime(1164977125));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2024, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(1709164800));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2025, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(1740787200));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2028, .month = 2, .day = 29, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(1835395200));
    try std.testing.expectEqual(tbt.DateTime{ .year = 2029, .month = 3, .day = 1, .hour = 0, .minute = 0, .second = 0 }, tbt.unixtime_to_datetime(1867017600));
    try std.testing.expectEqual(tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, tbt.unixtime_to_datetime(tbt.UNIX_TIMESTAMP_MAX));
}

//------------------------------------------------------------
// datetime_to_unixtime <=> unixtime_to_datetime
//------------------------------------------------------------

test "datetime_to_unixtime <=> unixtime_to_datetime" {
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
        const timestamp = try tbt.datetime_to_unixtime(datetime);
        const new_datetime = try tbt.unixtime_to_datetime(timestamp);
        try std.testing.expectEqual(datetime, new_datetime);
    }
}

//------------------------------------------------------------
// date_to_unixday
//------------------------------------------------------------

test "date_to_unixday" {
    try std.testing.expectError(error.InvalidDate, tbt.date_to_unixday(tbt.Date{ .year = 0, .month = 12, .day = 31 }));
    try std.testing.expectError(error.InvalidDate, tbt.date_to_unixday(tbt.Date{ .year = 10000, .month = 1, .day = 1 }));

    try std.testing.expectEqual(-719162, tbt.date_to_unixday(tbt.Date{ .year = 1, .month = 1, .day = 1 }) catch 0);

    try std.testing.expectEqual(0, tbt.date_to_unixday(tbt.Date{ .year = 1970, .month = 1, .day = 1 }) catch 0);

    try std.testing.expectEqual(2932896, tbt.date_to_unixday(tbt.Date{ .year = 9999, .month = 12, .day = 31 }) catch 0);
}

//------------------------------------------------------------
// unixday_to_date
//------------------------------------------------------------

test "unixday_to_date" {
    try std.testing.expectError(error.InvalidUnixDay, tbt.unixday_to_date(-719_1623));
    try std.testing.expectError(error.InvalidUnixDay, tbt.unixday_to_date(2932897));

    try std.testing.expectEqual(tbt.Date{ .year = 1, .month = 1, .day = 1 }, tbt.unixday_to_date(-719162) catch tbt.Date{});

    try std.testing.expectEqual(tbt.Date{ .year = 1970, .month = 1, .day = 1 }, tbt.unixday_to_date(0) catch tbt.Date{});

    try std.testing.expectEqual(tbt.Date{ .year = 9999, .month = 12, .day = 31 }, tbt.unixday_to_date(2932896) catch tbt.Date{});
}

//------------------------------------------------------------
// date_to_daynumber
//------------------------------------------------------------

test "date_to_daynumber" {
    try std.testing.expectError(error.InvalidDate, tbt.date_to_daynumber(tbt.Date{ .year = 0, .month = 12, .day = 31 }));
    try std.testing.expectError(error.InvalidDate, tbt.date_to_daynumber(tbt.Date{ .year = 10000, .month = 1, .day = 1 }));

    try std.testing.expectEqual(1, tbt.date_to_daynumber(tbt.Date{ .year = 1, .month = 1, .day = 1 }) catch 0);

    try std.testing.expectEqual(719163, tbt.date_to_daynumber(tbt.Date{ .year = 1970, .month = 1, .day = 1 }) catch 0);

    try std.testing.expectEqual(3652059, tbt.date_to_daynumber(tbt.Date{ .year = 9999, .month = 12, .day = 31 }) catch 0);
}

//------------------------------------------------------------
// daynumber_to_date
//------------------------------------------------------------

test "daynumber_to_date" {
    try std.testing.expectError(error.InvalidDayNumber, tbt.daynumber_to_date(0));
    try std.testing.expectError(error.InvalidDayNumber, tbt.daynumber_to_date(3_652_060));

    try std.testing.expectEqual(tbt.Date{ .year = 1, .month = 1, .day = 1 }, tbt.daynumber_to_date(1) catch tbt.Date{});

    try std.testing.expectEqual(tbt.Date{ .year = 1970, .month = 1, .day = 1 }, tbt.daynumber_to_date(719163) catch tbt.Date{});

    try std.testing.expectEqual(tbt.Date{ .year = 9999, .month = 12, .day = 31 }, tbt.daynumber_to_date(3652059) catch tbt.Date{});
}

//------------------------------------------------------------
// excelDateTime_to_unixtime
//------------------------------------------------------------

test "excelDateTime_to_unixtime" {
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.excelDateTime_to_unixtime(0));
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.excelDateTime_to_unixtime(2958465.999988427));

    const TestCase = struct { exceldatetime: f64, expected: i64 };

    const test_cases = [_]TestCase{
        TestCase{ .exceldatetime = 1, .expected = -2208988800 },
        TestCase{ .exceldatetime = 59, .expected = -2203977600 },
        TestCase{ .exceldatetime = 61, .expected = -2203891200 },
        TestCase{ .exceldatetime = 25569, .expected = 0 },
        TestCase{ .exceldatetime = 2958465.999988426, .expected = 253402300799 },
    };

    for (test_cases) |case| {
        const unixtime = try tbt.excelDateTime_to_unixtime(case.exceldatetime);
        try std.testing.expectEqual(case.expected, unixtime);
    }
}

//------------------------------------------------------------
// unixtime_to_excelDateTime
//------------------------------------------------------------

test "unixtime_to_excelDateTime" {
    try std.testing.expectError(error.InvalidExcelUnixTimestamp, tbt.unixtime_to_excelDateTime(-2_208_988_801));
    try std.testing.expectError(error.InvalidExcelUnixTimestamp, tbt.unixtime_to_excelDateTime(253_402_300_800));

    const TestCase = struct { unixtime: i64, expected: f64 };

    const test_cases = [_]TestCase{
        TestCase{ .unixtime = -2208988800, .expected = 1 },
        TestCase{ .unixtime = -2203977600, .expected = 59 },
        TestCase{ .unixtime = -2203891200, .expected = 61 },
        TestCase{ .unixtime = 0, .expected = 25569 },
        TestCase{ .unixtime = 981173106, .expected = 36925.17020833334 },
        TestCase{ .unixtime = 1164977125, .expected = 39052.531539351854 },
        TestCase{ .unixtime = 253402300799, .expected = 2958465.999988426 },
    };

    for (test_cases) |case| {
        const exceldatetime = try tbt.unixtime_to_excelDateTime(case.unixtime);
        try std.testing.expectEqual(case.expected, exceldatetime);
        // try std.testing.expectApproxEqAbs(case.expected, exceldatetime, 1e-10);
    }
}

//------------------------------------------------------------
// datetime_to_excelDateTime
//------------------------------------------------------------

test "datetime_to_excelDateTime" {
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.datetime_to_excelDateTime(tbt.DateTime{ .year = 1899, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }));
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.datetime_to_excelDateTime(tbt.DateTime{ .year = 10000 }));

    const TestCase = struct { datetime: tbt.DateTime, expected: f64 };

    const test_cases = [_]TestCase{
        TestCase{ .datetime = tbt.DateTime{ .year = 1900, .month = 1, .day = 1 }, .expected = 1 },
        TestCase{ .datetime = tbt.DateTime{ .year = 1900, .month = 2, .day = 28 }, .expected = 59 },
        TestCase{ .datetime = tbt.DateTime{ .year = 1900, .month = 3, .day = 1 }, .expected = 61 },
        TestCase{ .datetime = tbt.DateTime{ .year = 1970, .month = 1, .day = 1 }, .expected = 25569 },
        TestCase{ .datetime = tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 }, .expected = 2958465.999988426 },
    };

    for (test_cases) |case| {
        const exceldatetime = try tbt.datetime_to_excelDateTime(case.datetime);
        try std.testing.expectEqual(case.expected, exceldatetime);
    }
}

//------------------------------------------------------------
// excelDateTime_to_datetime
//------------------------------------------------------------

test "excelDateTime_to_datetime" {
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.excelDateTime_to_datetime(0));
    try std.testing.expectError(error.InvalidExcelDateTime, tbt.excelDateTime_to_datetime(2958465.999988427));

    const TestCase = struct { exceldatetime: f64, expected: tbt.DateTime };

    const test_cases = [_]TestCase{
        TestCase{ .exceldatetime = 1, .expected = tbt.DateTime{ .year = 1900, .month = 1, .day = 1 } },
        TestCase{ .exceldatetime = 59, .expected = tbt.DateTime{ .year = 1900, .month = 2, .day = 28 } },
        TestCase{ .exceldatetime = 61, .expected = tbt.DateTime{ .year = 1900, .month = 3, .day = 1 } },
        TestCase{ .exceldatetime = 25569, .expected = tbt.DateTime{ .year = 1970, .month = 1, .day = 1 } },
        TestCase{ .exceldatetime = 2958465.999988426, .expected = tbt.DateTime{ .year = 9999, .month = 12, .day = 31, .hour = 23, .minute = 59, .second = 59 } },
    };

    for (test_cases) |case| {
        const datetime = try tbt.excelDateTime_to_datetime(case.exceldatetime);
        try std.testing.expectEqual(case.expected, datetime);
    }
}

//------------------------------------------------------------
// excelDate_to_date
//------------------------------------------------------------

test "excelDate_to_date" {
    try std.testing.expectError(error.InvalidExcelDate, tbt.excelDate_to_date(0));
    try std.testing.expectError(error.InvalidExcelDate, tbt.excelDate_to_date(2958466));
    try std.testing.expectError(error.InvalidExcelDate, tbt.excelDate_to_date(1.5));

    const TestCase = struct { exceldate: f64, expected: tbt.Date };

    const test_cases = [_]TestCase{
        TestCase{ .exceldate = 1, .expected = tbt.Date{ .year = 1900, .month = 1, .day = 1 } },
        TestCase{ .exceldate = 59, .expected = tbt.Date{ .year = 1900, .month = 2, .day = 28 } },
        TestCase{ .exceldate = 61, .expected = tbt.Date{ .year = 1900, .month = 3, .day = 1 } },
        TestCase{ .exceldate = 25569, .expected = tbt.Date{ .year = 1970, .month = 1, .day = 1 } },
        TestCase{ .exceldate = 2958465, .expected = tbt.Date{ .year = 9999, .month = 12, .day = 31 } },
    };

    for (test_cases) |case| {
        const date = try tbt.excelDate_to_date(case.exceldate);
        try std.testing.expectEqual(case.expected, date);
    }
}

//------------------------------------------------------------
// date_to_excelDate
//------------------------------------------------------------

test "date_to_excelDate" {
    try std.testing.expectError(error.InvalidExcelDate, tbt.date_to_excelDate(tbt.Date{ .year = 1899, .month = 12, .day = 31 }));
    try std.testing.expectError(error.InvalidExcelDate, tbt.date_to_excelDate(tbt.Date{ .year = 10000 }));

    const TestCase = struct { date: tbt.Date, expected: f64 };

    const test_cases = [_]TestCase{
        TestCase{ .date = tbt.Date{ .year = 1900, .month = 1, .day = 1 }, .expected = 1 },
        TestCase{ .date = tbt.Date{ .year = 1900, .month = 2, .day = 28 }, .expected = 59 },
        TestCase{ .date = tbt.Date{ .year = 1900, .month = 3, .day = 1 }, .expected = 61 },
        TestCase{ .date = tbt.Date{ .year = 1970, .month = 1, .day = 1 }, .expected = 25569 },
        TestCase{ .date = tbt.Date{ .year = 9999, .month = 12, .day = 31 }, .expected = 2958465 },
    };

    for (test_cases) |case| {
        const exceldate = try tbt.date_to_excelDate(case.date);
        try std.testing.expectEqual(case.expected, exceldate);
    }
}

//------------------------------------------------------------
// excelDate_to_cymd
//------------------------------------------------------------

test "excelDate_to_cymd" {
    try std.testing.expectError(error.InvalidExcelDate, tbt.excelDate_to_cymd(0));
    try std.testing.expectError(error.InvalidExcelDate, tbt.excelDate_to_cymd(2958465.999988427));

    const TestCase = struct { exceldate: f64, expected: u32 };

    const test_cases = [_]TestCase{
        TestCase{ .exceldate = 1, .expected = 19000101 },
        TestCase{ .exceldate = 59, .expected = 19000228 },
        TestCase{ .exceldate = 61, .expected = 19000301 },
        TestCase{ .exceldate = 25569, .expected = 19700101 },
        TestCase{ .exceldate = 2958465, .expected = 99991231 },
    };

    for (test_cases) |case| {
        const cymd = try tbt.excelDate_to_cymd(case.exceldate);
        try std.testing.expectEqual(case.expected, cymd);
    }
}

//------------------------------------------------------------
// cymd_to_excelDate
//------------------------------------------------------------

test "cymd_to_excelDate" {
    try std.testing.expectError(error.InvalidExcelDate, tbt.cymd_to_excelDate(18991231));
    try std.testing.expectError(error.InvalidExcelDate, tbt.cymd_to_excelDate(100000101));

    const TestCase = struct { cymd: u32, expected: f64 };

    const test_cases = [_]TestCase{
        TestCase{ .cymd = 19000101, .expected = 1 },
        TestCase{ .cymd = 19000228, .expected = 59 },
        TestCase{ .cymd = 19000301, .expected = 61 },
        TestCase{ .cymd = 19700101, .expected = 25569 },
        TestCase{ .cymd = 99991231, .expected = 2958465 },
    };

    for (test_cases) |case| {
        const exceldate = try tbt.cymd_to_excelDate(case.cymd);
        try std.testing.expectEqual(case.expected, exceldate);
    }
}

//------------------------------------------------------------
// excelTime_to_time
//------------------------------------------------------------

test "excelTime_to_time" {
    const result = tbt.excelTime_to_time(0.1702083333);
    try std.testing.expectEqual(tbt.Time{ .hour = 4, .minute = 5, .second = 6 }, result);
}

//------------------------------------------------------------
// time_to_excelTime
//------------------------------------------------------------

test "time_to_excelTime" {
    const result: u64 = @intFromFloat(tbt.time_to_excelTime(tbt.Time{ .hour = 4, .minute = 5, .second = 6 }) * 1e10);
    try std.testing.expectEqual(1702083333, result);
}

//------------------------------------------------------------
// excelTime_to_hhmmss
//------------------------------------------------------------

test "excelTime_to_hhmmss" {
    const result = tbt.excelTime_to_hhmmss(0.1702083333);
    try std.testing.expectEqual(40506, result);
}

//------------------------------------------------------------
// excelTime_to_hhmmss
//------------------------------------------------------------

test "hhmmss_to_excelTime" {
    const result: u64 = @intFromFloat(tbt.hhmmss_to_excelTime(40506) * 1e10);
    try std.testing.expectEqual(1702083333, result);
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
// c
//------------------------------------------------------------

test "c" {
    try std.testing.expectEqual(19, tbt.c(tbt.Date{ .year = 1900, .month = 1, .day = 1 }));
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
// hhmmsszzz
//------------------------------------------------------------

test "hhmmsszzz" {
    try std.testing.expectEqual(112233444, tbt.hhmmsszzz(tbt.Time{ .hour = 11, .minute = 22, .second = 33, .millisecond = 444 }));
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
// mm
//------------------------------------------------------------

test "mm" {
    try std.testing.expectEqual(22, tbt.mm(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// ss
//------------------------------------------------------------

test "ss" {
    try std.testing.expectEqual(33, tbt.ss(tbt.Time{ .hour = 11, .minute = 22, .second = 33 }));
}

//------------------------------------------------------------
// zzz
//------------------------------------------------------------

test "zzz" {
    try std.testing.expectEqual(444, tbt.zzz(tbt.Time{ .hour = 11, .minute = 22, .second = 33, .millisecond = 444 }));
}

//------------------------------------------------------------
// ms
//------------------------------------------------------------

test "ms" {
    try std.testing.expectEqual(444, tbt.ms(tbt.Time{ .hour = 11, .minute = 22, .second = 33, .millisecond = 444 }));
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
// format
//------------------------------------------------------------

test "format" {
    //------------------------------------------------------------
    var output0: [0]u8 = undefined;
    var output1: [2]u8 = undefined;
    var output13: [13]u8 = undefined;
    //------------------------------------------------------------
    const datetime1 = tbt.DateTime{ .year = 2024, .month = 1, .day = 1, .hour = 2, .minute = 3, .second = 4, .millisecond = 5 };
    const datetime2 = tbt.DateTime{ .year = 2024, .month = 7, .day = 1 };
    //------------------------------------------------------------
    try std.testing.expectError(error.OutputBufferTooSmall, tbt.format(datetime1, "utms", &output0));
    try std.testing.expectError(error.NoSpaceLeft, tbt.format(datetime1, "utms", &output1));
    //------------------------------------------------------------

    try std.testing.expectEqual(0, tbt.format(datetime1, "", &output1));

    @memset(&output13, 0);
    try std.testing.expectEqual(13, tbt.format(datetime1, "utms", &output13));
    try std.testing.expectEqualStrings("1704074584005", output13[0..]);

    @memset(&output13, 0);
    try std.testing.expectEqual(10, tbt.format(datetime1, "ut", &output13));
    try std.testing.expectEqualStrings("1704074584", output13[0..10]);

    @memset(&output13, 0);
    try std.testing.expectEqual(3, tbt.format(datetime1, "ddd", &output13));
    try std.testing.expectEqualStrings("001", output13[0..3]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime1, "hh", &output13));
    try std.testing.expectEqualStrings("02", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime1, "mm", &output13));
    try std.testing.expectEqualStrings("03", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime1, "ss", &output13));
    try std.testing.expectEqualStrings("04", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(3, tbt.format(datetime1, "zzz", &output13));
    try std.testing.expectEqualStrings("005", output13[0..3]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(0, tbt.format(datetime1, "DST", &output13));
    try std.testing.expectEqualStrings("   ", output13[0..3]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(3, tbt.format(datetime2, "DST", &output13));
    try std.testing.expectEqualStrings("DST", output13[0..3]);

    @memset(&output13, 0);
    try std.testing.expectEqual(6, tbt.format(datetime2, "cywk", &output13));
    try std.testing.expectEqualStrings("202427", output13[0..6]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime2, "wk", &output13));
    try std.testing.expectEqualStrings("27", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(4, tbt.format(datetime2, "CY", &output13));
    try std.testing.expectEqualStrings("2024", output13[0..4]);

    @memset(&output13, 0);
    try std.testing.expectEqual(4, tbt.format(datetime2, "cy", &output13));
    try std.testing.expectEqualStrings("2024", output13[0..4]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime2, "y", &output13));
    try std.testing.expectEqualStrings("24", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime2, "m", &output13));
    try std.testing.expectEqualStrings("07", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(2, tbt.format(datetime2, "d", &output13));
    try std.testing.expectEqualStrings("01", output13[0..2]);

    @memset(&output13, 0);
    try std.testing.expectEqual(1, tbt.format(datetime2, "q", &output13));
    try std.testing.expectEqualStrings("3", output13[0..1]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(4, tbt.format(datetime2, "MM", &output13));
    try std.testing.expectEqualStrings("July", output13[0..4]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(3, tbt.format(datetime2, "M", &output13));
    try std.testing.expectEqualStrings("Jul", output13[0..3]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(6, tbt.format(datetime2, "DD", &output13));
    try std.testing.expectEqualStrings("Monday", output13[0..6]);

    @memset(&output13, 0x20);
    try std.testing.expectEqual(3, tbt.format(datetime2, "D", &output13));
    try std.testing.expectEqualStrings("Mon", output13[0..3]);

    //------------------------------------------------------------
}

//------------------------------------------------------------

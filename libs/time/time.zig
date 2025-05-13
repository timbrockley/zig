//------------------------------------------------------------
// Time and calendar library
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------

pub const SECONDS_PER_MINUTE = 60;
pub const SECONDS_PER_HOUR = 3600;
pub const SECONDS_PER_DAY = 86400;

pub const DAYS_PER_YEAR = 365;
pub const DAYS_IN_4YEARS = 1461;
pub const DAYS_IN_100YEARS = 36524;
pub const DAYS_IN_400YEARS = 146097;

pub const YEAR_MIN = 1;
pub const YEAR_MAX = 9999;

pub const DAYNUMBER_MIN = 1;
pub const DAYNUMBER_MAX = 3_652_059;

pub const UNIX_DAY_MIN = -719_162; // 0001-01-01 00:00:00
pub const UNIX_DAY_MAX = 2_932_896; // 9999-12-31 23:59:59
pub const DAYS_BEFORE_UNIX = 719_468;
pub const UNIX_TIMESTAMP_MIN = -62_135_596_800; // 0001-01-01 00:00:00
pub const UNIX_TIMESTAMP_MAX = 253_402_300_799; // 9999-12-31 23:59:59

pub const EXCEL_YEAR_MIN = 1900;
pub const EXCEL_YEAR_MAX = 9999;
pub const EXCEL_UNIXTIME_MIN = -2_208_988_800; // 1900-01-01 00:00:00
pub const EXCEL_UNIXTIME_MARCH_03 = -2_203_891_200;
pub const EXCEL_UNIXTIME_MAX = 253_402_300_799; // 9999-12-31 23:59:59
pub const EXCEL_DATETIME_MIN = 1; // 1900-01-01 00:00:00
pub const EXCEL_DATETIME_MAX = 2958465.999988426; // 9999-12-31 23:59:59
pub const EXCEL_DATE_MIN = 1; // 1900-01-01
pub const EXCEL_DATE_MAX = 2958465; // 9999-12-31

//------------------------------------------------------------

pub const DateTime = struct {
    year: u16 = 0,
    month: u8 = 0,
    day: u8 = 0,
    hour: u8 = 0,
    minute: u8 = 0,
    second: u8 = 0,
    millisecond: u16 = 0,
};

pub const Date = struct {
    year: u16 = 0,
    month: u8 = 0,
    day: u8 = 0,
};

pub const Time = struct {
    hour: u8 = 0,
    minute: u8 = 0,
    second: u8 = 0,
    millisecond: u16 = 0,
};

//------------------------------------------------------------
// toDateTime
//------------------------------------------------------------

/// Converts Date or Time to DateTime.
pub fn toDateTime(date_time: anytype) DateTime {
    //------------------------------------------------------------
    return switch (@TypeOf(date_time)) {
        Date => DateTime{ .year = date_time.year, .month = date_time.month, .day = date_time.day },
        Time => DateTime{ .hour = date_time.hour, .minute = date_time.minute, .second = date_time.second, .millisecond = date_time.millisecond },
        else => @compileError("toDateTime: Date or Time required"),
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// toDate
//------------------------------------------------------------

/// Converts DateTime to Date.
pub fn toDate(datetime: DateTime) Date {
    //------------------------------------------------------------
    return Date{ .year = datetime.year, .month = datetime.month, .day = datetime.day };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// toTime
//------------------------------------------------------------

/// Converts DateTime to Time.
pub fn toTime(datetime: DateTime) Time {
    //------------------------------------------------------------
    return Time{ .hour = datetime.hour, .minute = datetime.minute, .second = datetime.second, .millisecond = datetime.millisecond };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// now
//------------------------------------------------------------

/// Converts current unix timestamp to DateTime.
pub fn now() DateTime {
    //------------------------------------------------------------
    return unixtime_to_datetime(std.time.timestamp()) catch DateTime{};
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unixTimestamp
//------------------------------------------------------------

/// Returns current unix timestamp (seconds).
pub fn unixTimestamp() i64 {
    //------------------------------------------------------------
    return std.time.timestamp();
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unixMilliseconds
//------------------------------------------------------------

/// Returns current unix timestamp (milliseconds).
pub fn unixMilliseconds() i64 {
    //------------------------------------------------------------
    return std.time.milliTimestamp();
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unixNanoseconds
//------------------------------------------------------------

/// Returns current unix timestamp (nanoseconds).
pub fn unixNanoseconds() i128 {
    //------------------------------------------------------------
    return std.time.nanoTimestamp();
    //------------------------------------------------------------
}

//------------------------------------------------------------
// utms
//------------------------------------------------------------

/// Returns current unix timestamp (milliseconds).
pub fn utms(datetime: DateTime) i64 {
    //------------------------------------------------------------
    return datetime_to_unix_milliseconds(datetime) catch 0;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// ut
//------------------------------------------------------------

/// Returns current unix timestamp (seconds).
pub fn ut(datetime: DateTime) i64 {
    //------------------------------------------------------------
    return datetime_to_unixtime(datetime) catch 0;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// datetime_to_unix_milliseconds
//------------------------------------------------------------

/// Converts DateTime to unix milliseconds.
/// Valid range: 0001-01-01 00:00:00:000 to 9999-12-31 23:59:59:999.
/// (-62_135_596_800_000 to 253_402_300_799_999).
pub fn datetime_to_unix_milliseconds(datetime: DateTime) !i64 {
    //------------------------------------------------------------
    var unix_milliseconds = try datetime_to_unixtime(DateTime{ .year = datetime.year, .month = datetime.month, .day = datetime.day, .hour = datetime.hour, .minute = datetime.minute, .second = datetime.second }) * 1000;
    //------------------------------------------------------------
    if (unix_milliseconds < 0) unix_milliseconds -= datetime.millisecond else unix_milliseconds += datetime.millisecond;
    //------------------------------------------------------------
    return unix_milliseconds;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unix_milliseconds_to_datetime
//------------------------------------------------------------

/// Converts unix milliseconds to DateTime.
/// Valid range: -62_135_596_800_000 to 253_402_300_799_999.
/// (0001-01-01 00:00:00:000 to 9999-12-31 23:59:59:999).
pub fn unix_milliseconds_to_datetime(unix_milliseconds: i64) !DateTime {
    //------------------------------------------------------------
    if (unix_milliseconds < UNIX_TIMESTAMP_MIN * 1000 or unix_milliseconds > UNIX_TIMESTAMP_MAX * 1000 + 999) return error.InvalidUnixMilliseconds;
    //------------------------------------------------------------
    var datetime = try unixtime_to_datetime(@divFloor(unix_milliseconds, 1000));
    //------------------------------------------------------------
    datetime.millisecond = @intCast(@mod(@abs(unix_milliseconds), 1000));
    //------------------------------------------------------------
    return datetime;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// datetime_to_unixtime
//------------------------------------------------------------

/// Converts DateTime to unix timestamp.
/// Valid range: 0001-01-01 00:00:00 to 9999-12-31 23:59:59.
/// (-62_135_596_800 to 253_402_300_799).
pub fn datetime_to_unixtime(datetime: DateTime) !i64 {
    //------------------------------------------------------------
    if (!checkDateTime(datetime)) return error.InvalidDateTime;
    //------------------------------------------------------------
    var year: i64 = datetime.year;
    var month: i64 = datetime.month;
    const day: i64 = datetime.day;
    //------------------------------------------------------------
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    //------------------------------------------------------------
    const gregorian_cycle = @divTrunc(year, 400);

    const year_of_gregorian_cycle = year - gregorian_cycle * 400;

    const day_of_year = @divTrunc(153 * (month - 3) + 2, 5) + day - 1;

    const day_of_gregorian_cycle =
        year_of_gregorian_cycle * 365 +
        @divTrunc(year_of_gregorian_cycle, 4) -
        @divTrunc(year_of_gregorian_cycle, 100) +
        day_of_year;

    const adjusted_daynumber: i64 =
        gregorian_cycle * DAYS_IN_400YEARS +
        day_of_gregorian_cycle -
        DAYS_BEFORE_UNIX;

    const unixtime: i64 =
        adjusted_daynumber * SECONDS_PER_DAY +
        @as(i64, datetime.hour) * SECONDS_PER_HOUR +
        @as(i64, datetime.minute) * SECONDS_PER_MINUTE +
        @as(i64, datetime.second);
    //------------------------------------------------------------
    if (unixtime < UNIX_TIMESTAMP_MIN or unixtime > UNIX_TIMESTAMP_MAX)
        return error.OverflowError;
    //------------------------------------------------------------
    return unixtime;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unixtime_to_datetime
//------------------------------------------------------------

/// Converts unix timestamp to DateTime.
/// Valid range: -62_135_596_800 to 253_402_300_799.
/// (0001-01-01 00:00:00 to 9999-12-31 23:59:59).
pub fn unixtime_to_datetime(unixtime: i64) !DateTime {
    //------------------------------------------------------------
    if (unixtime < UNIX_TIMESTAMP_MIN or unixtime > UNIX_TIMESTAMP_MAX) return error.InvalidUnixTimestamp;
    //------------------------------------------------------------
    const days = @divFloor(unixtime, SECONDS_PER_DAY);
    const seconds_in_day = @mod((@mod(unixtime, SECONDS_PER_DAY) + SECONDS_PER_DAY), SECONDS_PER_DAY);
    var adjusted_daynumber = DAYS_BEFORE_UNIX + days;
    //------------------------------------------------------------
    var temp: i64 = 0;
    //------------------------------------------------------------
    temp = @divFloor((4 * (adjusted_daynumber + DAYS_IN_100YEARS + 1)), DAYS_IN_400YEARS) - 1;
    var year = 100 * temp;
    adjusted_daynumber -= DAYS_IN_100YEARS * temp + @divFloor(temp, 4);
    //------------------------------------------------------------
    temp = @divFloor((4 * (adjusted_daynumber + DAYS_PER_YEAR + 1)), DAYS_IN_4YEARS) - 1;
    year += temp;
    adjusted_daynumber -= DAYS_PER_YEAR * temp + @divFloor(temp, 4);
    //------------------------------------------------------------
    var month = @divFloor((5 * adjusted_daynumber + 2), 153);
    const day = adjusted_daynumber - @divFloor((month * 153 + 2), 5) + 1;
    //------------------------------------------------------------
    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    //------------------------------------------------------------
    return DateTime{
        .year = @intCast(year),
        .month = @intCast(month),
        .day = @intCast(day),
        .hour = @intCast(@divFloor(seconds_in_day, SECONDS_PER_HOUR)),
        .minute = @intCast(@divFloor(@mod(seconds_in_day, SECONDS_PER_HOUR), SECONDS_PER_MINUTE)),
        .second = @intCast(@mod(seconds_in_day, SECONDS_PER_MINUTE)),
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// date_to_unixday
//------------------------------------------------------------

/// Converts Date to unix day.
/// Valid range: 0001-01-01 to 9999-12-31.
/// (-719_162 to 2_932_896). Unix Day 0 = 1970-01-01.
pub fn date_to_unixday(date: Date) !i64 {
    //------------------------------------------------------------
    if (!checkDate(date)) return error.InvalidDate;
    //------------------------------------------------------------
    var year: i64 = date.year;
    var month: i64 = date.month;
    const day: i64 = date.day;
    //------------------------------------------------------------
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    //------------------------------------------------------------
    const gregorian_cycle = @divTrunc(year, 400);

    const year_of_gregorian_cycle = year - gregorian_cycle * 400;

    const day_of_year = @divTrunc(153 * (month - 3) + 2, 5) + day - 1;

    const day_of_gregorian_cycle =
        year_of_gregorian_cycle * 365 +
        @divTrunc(year_of_gregorian_cycle, 4) -
        @divTrunc(year_of_gregorian_cycle, 100) +
        day_of_year;

    const adjusted_daynumber: i64 =
        gregorian_cycle * DAYS_IN_400YEARS +
        day_of_gregorian_cycle -
        DAYS_BEFORE_UNIX;
    //------------------------------------------------------------
    if (adjusted_daynumber < UNIX_DAY_MIN or adjusted_daynumber > UNIX_DAY_MAX) return error.OverflowError;
    //------------------------------------------------------------
    return adjusted_daynumber;
    //------------------------------------------------------------
}

/// Converts unix day to Date.
/// Valid range: -719_162 to 2_932_896
/// (0001-01-01 to 9999-12-31). 1970-01-01 = Unix Day 0.
pub fn unixday_to_date(unixday: i64) !Date {
    //------------------------------------------------------------
    if (unixday < UNIX_DAY_MIN or unixday > UNIX_DAY_MAX) return error.InvalidUnixDay;
    //------------------------------------------------------------
    var adjusted_daynumber = DAYS_BEFORE_UNIX + unixday;

    var temp: i64 = 0;

    temp = @divFloor((4 * (adjusted_daynumber + DAYS_IN_100YEARS + 1)), DAYS_IN_400YEARS) - 1;
    var year = 100 * temp;
    adjusted_daynumber -= DAYS_IN_100YEARS * temp + @divFloor(temp, 4);

    temp = @divFloor((4 * (adjusted_daynumber + DAYS_PER_YEAR + 1)), DAYS_IN_4YEARS) - 1;
    year += temp;
    adjusted_daynumber -= DAYS_PER_YEAR * temp + @divFloor(temp, 4);

    var month = @divFloor((5 * adjusted_daynumber + 2), 153);
    const day = adjusted_daynumber - @divFloor((month * 153 + 2), 5) + 1;

    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    //------------------------------------------------------------
    return Date{
        .year = @intCast(year),
        .month = @intCast(month),
        .day = @intCast(day),
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// date_to_daynumber
//------------------------------------------------------------

/// Converts Date Day Number.
/// Valid range: 0001-01-01 to 9999-12-31. (1 to 3_652_059).
pub fn date_to_daynumber(date: Date) !u32 {
    //------------------------------------------------------------
    if (!checkDate(date)) return error.InvalidDate;
    //------------------------------------------------------------
    var year: u32 = date.year;
    var month: u32 = date.month;
    const day: u32 = date.day;

    if (month <= 2) {
        year -= 1;
        month += 12;
    }

    const gregorian_cycle = @divTrunc(year, 400);
    const year_of_gregorian_cycle = year - gregorian_cycle * 400;

    const day_of_year = @divTrunc(153 * (month - 3) + 2, 5) + day - 1;

    const day_of_gregorian_cycle =
        year_of_gregorian_cycle * 365 +
        @divTrunc(year_of_gregorian_cycle, 4) -
        @divTrunc(year_of_gregorian_cycle, 100) +
        day_of_year;
    //------------------------------------------------------------
    return (gregorian_cycle * DAYS_IN_400YEARS +
        day_of_gregorian_cycle) - 305; // Adjust so daynumber 1 = 0001-01-01
    //------------------------------------------------------------
}

//------------------------------------------------------------
// daynumber_to_date
//------------------------------------------------------------

/// Converts Day Number to Date.
/// Valid range: 1 to 3_652_059. (0001-01-01 to 9999-12-31).
pub fn daynumber_to_date(daynumber: u32) !Date {
    //------------------------------------------------------------
    if (daynumber < DAYNUMBER_MIN or daynumber > DAYNUMBER_MAX) return error.InvalidDayNumber;
    //------------------------------------------------------------
    var temp: u32 = 0;
    var adjusted_daynumber = daynumber + 305; // Adjust so daynumber 1 = 0001-01-01

    temp = @divFloor((4 * (adjusted_daynumber + DAYS_IN_100YEARS + 1)), DAYS_IN_400YEARS) - 1;
    var year = 100 * temp;
    adjusted_daynumber -= DAYS_IN_100YEARS * temp + @divFloor(temp, 4);

    temp = @divFloor((4 * (adjusted_daynumber + DAYS_PER_YEAR + 1)), DAYS_IN_4YEARS) - 1;
    year += temp;
    adjusted_daynumber -= DAYS_PER_YEAR * temp + @divFloor(temp, 4);

    var month = @divFloor((5 * adjusted_daynumber + 2), 153);
    const day = adjusted_daynumber - @divFloor((month * 153 + 2), 5) + 1;

    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    //------------------------------------------------------------
    return Date{
        .year = @intCast(year),
        .month = @intCast(month),
        .day = @intCast(day),
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelDateTime_to_unixtime
//------------------------------------------------------------

/// Converts ExcelDateTime to unix timestamp.
/// Valid range: 1 to 2958465.999988426.
/// (-2_208_988_800 to 253_402_300_799).
/// (1900-01-01 00:00:00 to 9999-12-31 23:59:59).
pub fn excelDateTime_to_unixtime(exceldatetime: f64) !i64 {
    //------------------------------------------------------------
    if (exceldatetime < EXCEL_DATETIME_MIN or exceldatetime > EXCEL_DATETIME_MAX) return error.InvalidExcelDateTime;
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (exceldatetime < 61) 25568 else 25569;
    //------------------------------------------------------------
    return @intFromFloat(@round((exceldatetime - offset) * 86400));
    //------------------------------------------------------------
}

//------------------------------------------------------------
// unixtime_to_excelDateTime
//------------------------------------------------------------

/// Converts unix timestamp to ExcelDateTime.
/// Valid range: -2_208_988_800 to 253_402_300_799.
/// (1 to 2958465.999988426).
/// (1900-01-01 00:00:00 to 9999-12-31 23:59:59).
pub fn unixtime_to_excelDateTime(unixtime: i64) !f64 {
    //------------------------------------------------------------
    if (unixtime < EXCEL_UNIXTIME_MIN or unixtime > EXCEL_UNIXTIME_MAX) return error.InvalidExcelUnixTimestamp;
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (unixtime < EXCEL_UNIXTIME_MARCH_03) 25568 else 25569;
    //------------------------------------------------------------
    return @as(f64, @floatFromInt(unixtime)) / 86400 + offset;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelDateTime_to_datetime
//------------------------------------------------------------

/// Converts ExcelDateTime to DateTime.
/// Valid range: 1 to 2958465.999988426.
/// (1900-01-01 00:00:00 to 9999-12-31 23:59:59).
pub fn excelDateTime_to_datetime(exceldatetime: f64) !DateTime {
    //------------------------------------------------------------
    if (exceldatetime < EXCEL_DATETIME_MIN or exceldatetime > EXCEL_DATETIME_MAX) return error.InvalidExcelDateTime;
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (exceldatetime < 61) 25568 else 25569;
    //------------------------------------------------------------
    const unixtime: i64 = @intFromFloat(@round((exceldatetime - offset) * 86400));
    //------------------------------------------------------------
    return unixtime_to_datetime(unixtime);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// datetime_to_excelDateTime
//------------------------------------------------------------

/// Converts DateTime to ExcelDateTime.
/// Valid range: 1900-01-01 00:00:00 to 9999-12-31 23:59:59.
/// (1 to 2958465.999988426).
pub fn datetime_to_excelDateTime(datetime: DateTime) !f64 {
    //------------------------------------------------------------
    if (datetime.year < EXCEL_YEAR_MIN or datetime.year > EXCEL_YEAR_MAX) return error.InvalidExcelDateTime;
    //------------------------------------------------------------
    const unixtime = try datetime_to_unixtime(datetime);
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (unixtime < EXCEL_UNIXTIME_MARCH_03) 25568 else 25569;
    //------------------------------------------------------------
    return @as(f64, @floatFromInt(unixtime)) / 86400 + offset;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelDate_to_date
//------------------------------------------------------------

/// Converts ExcelDate to Date.
/// Valid range: 1 to 2958465. (1900-01-01 to 9999-12-31).
pub fn excelDate_to_date(exceldate: f64) !Date {
    //------------------------------------------------------------
    if (exceldate < EXCEL_DATE_MIN or exceldate > EXCEL_DATE_MAX) return error.InvalidExcelDate;
    if (@ceil(exceldate) != exceldate) return error.InvalidExcelDate;
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (exceldate < 61) 25568 else 25569;
    //------------------------------------------------------------
    const unixtime: i64 = @intFromFloat(@round((exceldate - offset) * 86400));
    //------------------------------------------------------------
    const datetime = try unixtime_to_datetime(unixtime);
    //------------------------------------------------------------
    return toDate(datetime);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// date_to_excelDate
//------------------------------------------------------------

/// Converts Date to ExcelDate.
/// Valid range: (1900-01-01 to 9999-12-31). (1 to 2958465).
pub fn date_to_excelDate(date: Date) !f64 {
    //------------------------------------------------------------
    if (date.year < EXCEL_YEAR_MIN or date.year > EXCEL_YEAR_MAX) return error.InvalidExcelDate;
    //------------------------------------------------------------
    const unixtime = try datetime_to_unixtime(toDateTime(date));
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (unixtime < EXCEL_UNIXTIME_MARCH_03) 25568 else 25569;
    //------------------------------------------------------------
    return @floor(@as(f64, @floatFromInt(unixtime)) / 86400 + offset);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelDate_to_cymd
//------------------------------------------------------------

/// Converts ExcelDate to cymd.
/// Valid range: 1 to 2958465. (19000101 to 99991231).
pub fn excelDate_to_cymd(exceldate: f64) !u32 {
    //------------------------------------------------------------
    if (exceldate < EXCEL_DATE_MIN or exceldate > EXCEL_DATE_MAX) return error.InvalidExcelDate;
    if (@ceil(exceldate) != exceldate) return error.InvalidExcelDate;
    //------------------------------------------------------------
    // adjust for Excel / Lotus 123 (1900 leap year bug)
    const offset: f64 = if (exceldate < 61) 25568 else 25569;
    //------------------------------------------------------------
    const unixtime: i64 = @intFromFloat(@round((exceldate - offset) * 86400));
    //------------------------------------------------------------
    const datetime = try unixtime_to_datetime(unixtime);
    //------------------------------------------------------------
    return cymd(toDate(datetime));
    //------------------------------------------------------------
}

//------------------------------------------------------------
// cymd_to_excelDate
//------------------------------------------------------------

/// Converts cymd to excelDate.
/// Valid range: 19000101 to 99991231. (1 to 2958465).
pub fn cymd_to_excelDate(CYMD: u32) !f64 {
    //------------------------------------------------------------
    return date_to_excelDate(Date{
        .year = @intCast(CYMD / 10_000),
        .month = @intCast(CYMD % 10_000 / 100),
        .day = @intCast(CYMD % 10_000 % 100),
    });
    //------------------------------------------------------------
}

//------------------------------------------------------------
// time_to_excelTime
//------------------------------------------------------------

/// Converts Time to excelTime.
pub fn time_to_excelTime(time: Time) f64 {
    //------------------------------------------------------------
    return @as(f64, @floatFromInt(@as(u32, time.hour) * 3600 + @as(u32, time.minute) * 60 + @as(u32, time.second))) / 86400;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelTime_to_time
//------------------------------------------------------------

/// Converts excelTime to Time.
pub fn excelTime_to_time(exceltime: f64) Time {
    //------------------------------------------------------------
    const seconds: u32 = @intFromFloat(@round((exceltime - @floor(exceltime)) * 86400));
    //------------------------------------------------------------
    return Time{
        .hour = @intCast(seconds / 3600),
        .minute = @intCast((seconds % 3600) / 60),
        .second = @intCast(seconds % 60),
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// excelTime_to_hhmmss
//------------------------------------------------------------

/// Converts excelTime to hours, minutes and seconds.
pub fn excelTime_to_hhmmss(exceltime: f64) u32 {
    //------------------------------------------------------------
    const seconds: u32 = @intFromFloat(@round((exceltime - @floor(exceltime)) * 86400));
    //------------------------------------------------------------
    return seconds / 3600 * 10_000 + (seconds % 3600) / 60 * 1_00 + (seconds % 3600) % 60;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmmss_to_excelTime
//------------------------------------------------------------

/// Converts hours, minutes and seconds to excelTime.
pub fn hhmmss_to_excelTime(HHMMSS: u32) f64 {
    //------------------------------------------------------------
    const hour: u32 = HHMMSS / 10000;
    const minute: u32 = (HHMMSS % 10000) / 100;
    const second: u32 = HHMMSS % 100;
    //------------------------------------------------------------
    return @as(f64, @floatFromInt(hour * 3600 + minute * 60 + second)) / 86400;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// checkDateTime
//------------------------------------------------------------

/// Checks DateTime.
pub fn checkDateTime(datetime: DateTime) bool {
    //------------------------------------------------------------
    if (datetime.year < YEAR_MIN or datetime.year > YEAR_MAX) return false;
    if (datetime.month < 1 or datetime.month > 12) return false;
    if (datetime.day < 1 or datetime.day > lastDayOfMonth(toDate(datetime))) return false;
    //------------------------------------------------------------
    if (datetime.hour < 0 or datetime.hour > 23) return false;
    if (datetime.minute < 0 or datetime.minute > 59) return false;
    if (datetime.second < 0 or datetime.second > 59) return false;
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// checkDate
//------------------------------------------------------------

/// Checks Date.
pub fn checkDate(date: Date) bool {
    //------------------------------------------------------------
    if (date.year < YEAR_MIN or date.year > YEAR_MAX) return false;
    if (date.month < 1 or date.month > 12) return false;
    if (date.day < 1 or date.day > lastDayOfMonth(date)) return false;
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// checkTime
//------------------------------------------------------------

/// Checks Time.
pub fn checkTime(time: Time) bool {
    //------------------------------------------------------------
    if (time.hour < 0 or time.hour > 23) return false;
    if (time.minute < 0 or time.minute > 59) return false;
    if (time.second < 0 or time.second > 59) return false;
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// lastDayOfMonth
//------------------------------------------------------------

/// Returns last day of month.
pub fn lastDayOfMonth(date: Date) u8 {
    //------------------------------------------------------------
    return switch (date.month) {
        1, 3, 5, 7, 8, 10, 12 => 31,
        4, 6, 9, 11 => 30,
        2 => if (isLeapYear(date.year)) 29 else 28,
        else => 0,
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// isLeapYear
//------------------------------------------------------------

/// Checks if year is a leap year.
pub fn isLeapYear(year: u16) bool {
    //------------------------------------------------------------
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// isDST
//------------------------------------------------------------

/// Returns true if given date falls on british summer time, otherwise false.
/// Ignores time of day. Based on gregorian calendar which started 1582-10-15.
/// (same logic still used for previous dates).
pub fn isDST(date: Date) bool {
    //------------------------------------------------------------
    if (date.month < 3 or date.month > 10) {
        return false;
    }
    //------------------------------------------------------------
    if (date.month > 3 and date.month < 10) {
        return true;
    }
    //------------------------------------------------------------
    const day_of_week = dow(Date{ .year = date.year, .month = date.month, .day = 31 });
    const last_sunday = if (day_of_week == 7) 31 else 31 - day_of_week;
    //------------------------------------------------------------
    if (date.month == 3) {
        return date.day >= last_sunday;
    } else {
        return date.day < last_sunday;
    }
    //------------------------------------------------------------
}

//------------------------------------------------------------
// cymd
//------------------------------------------------------------

/// Returns century, year, month and day.
pub fn cymd(date: Date) u32 {
    //------------------------------------------------------------
    return @as(u32, date.year) * 1_00_00 + @as(u32, date.month) * 1_00 + @as(u32, date.day);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// ymd
//------------------------------------------------------------

/// Returns year, month and day.
pub fn ymd(date: Date) u32 {
    //------------------------------------------------------------
    return @as(u32, date.year % 100) * 1_00_00 + @as(u32, date.month) * 1_00 + @as(u32, date.day);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// c
//------------------------------------------------------------

/// Returns century.
pub fn c(date: Date) u8 {
    //------------------------------------------------------------
    return @as(u8, @intCast(date.year / 1_00));
    //------------------------------------------------------------
}

//------------------------------------------------------------
// cy
//------------------------------------------------------------

/// Returns century and year.
pub fn cy(date: Date) u16 {
    //------------------------------------------------------------
    return date.year;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// y
//------------------------------------------------------------

/// Returns year.
pub fn y(date: Date) u8 {
    //------------------------------------------------------------
    return @intCast(date.year % 100);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// m
//------------------------------------------------------------

/// Returns month.
pub fn m(date: Date) u8 {
    //------------------------------------------------------------
    return date.month;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// d
//------------------------------------------------------------

/// Returns day of month.
pub fn d(date: Date) u8 {
    //------------------------------------------------------------
    return date.day;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// md
//------------------------------------------------------------

/// Returns month and day.
pub fn md(date: Date) u16 {
    //------------------------------------------------------------
    return @as(u16, date.month) * 1_00 + @as(u16, date.day);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// dm
//------------------------------------------------------------

/// Returns day and month.
pub fn dm(date: Date) u16 {
    //------------------------------------------------------------
    return @as(u16, date.day) * 1_00 + @as(u16, date.month);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// cyddd
//------------------------------------------------------------

/// Returns year an day number.
pub fn cyddd(date: Date) u32 {
    //------------------------------------------------------------
    return @as(u32, date.year) * 1_000 + ddd(date);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// ddd
//------------------------------------------------------------

/// Returns day number.
pub fn ddd(date: Date) u16 {
    //------------------------------------------------------------
    const day_number: u16 = switch (date.month) {
        1 => 1,
        2 => 32,
        3 => 60,
        4 => 91,
        5 => 121,
        6 => 152,
        7 => 182,
        8 => 213,
        9 => 244,
        10 => 274,
        11 => 305,
        12 => 335,
        else => 0,
    };
    //------------------------------------------------------------
    return if (isLeapYear(date.year) and date.month >= 3) day_number + date.day else date.day + day_number - 1;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// dow
//------------------------------------------------------------

/// Returns day of week using Zeller's congruence algorithm (adjusted to mon = 1, sun = 7).
/// Based on gregorian calendar which started 1582-10-15.
/// (same logic still used for previous dates).
pub fn dow(date: Date) u8 {
    //------------------------------------------------------------
    var Y = @as(i32, date.year);
    var M = @as(i32, date.month);
    //------------------------------------------------------------
    if (M < 3) {
        M += 12;
        Y -= 1;
    }
    //------------------------------------------------------------
    const K = @mod(Y, 100);
    const J = @divFloor(Y, 100);
    const H = @mod((@as(i32, date.day) + @divFloor((13 * (M + 1)), 5) + K + @divFloor(K, 4) + @divFloor(J, 4) + 5 * J), 7);
    //------------------------------------------------------------
    // adjust: Zeller's output 0 = Saturday => 6, so Sunday = 0
    const dow_zero_sunday: u8 = @intCast(@mod((H + 6), 7));
    //------------------------------------------------------------
    // convert to sun = 7
    return if (dow_zero_sunday == 0) 7 else dow_zero_sunday;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// dowD
//------------------------------------------------------------

/// Returns shortened day of week as a string.
pub fn dowD(date: Date) []const u8 {
    //------------------------------------------------------------
    return switch (dow(date)) {
        1 => "Mon",
        2 => "Tue",
        3 => "Wed",
        4 => "Thu",
        5 => "Fri",
        6 => "Sat",
        7 => "Sun",
        else => "",
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// dowDD
//------------------------------------------------------------

/// Returns day of week as a string.
pub fn dowDD(date: Date) []const u8 {
    //------------------------------------------------------------
    return switch (dow(date)) {
        1 => "Monday",
        2 => "Tuesday",
        3 => "Wednesday",
        4 => "Thursday",
        5 => "Friday",
        6 => "Saturday",
        7 => "Sunday",
        else => "",
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// MonthM
//------------------------------------------------------------

/// Returns shortened month as a string.
pub fn monthM(date: Date) []const u8 {
    //------------------------------------------------------------
    return switch (date.month) {
        1 => "Jan",
        2 => "Feb",
        3 => "Mar",
        4 => "Apr",
        5 => "May",
        6 => "Jun",
        7 => "Jul",
        8 => "Aug",
        9 => "Sep",
        10 => "Oct",
        11 => "Nov",
        12 => "Dec",
        else => "",
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// MonthMM
//------------------------------------------------------------

/// Returns month as a string.
pub fn monthMM(date: Date) []const u8 {
    //------------------------------------------------------------
    return switch (date.month) {
        1 => "January",
        2 => "February",
        3 => "March",
        4 => "April",
        5 => "May",
        6 => "June",
        7 => "July",
        8 => "August",
        9 => "September",
        10 => "October",
        11 => "November",
        12 => "December",
        else => "",
    };
    //------------------------------------------------------------
}

//------------------------------------------------------------
// isoYear
//------------------------------------------------------------

/// Returns ISO 8601 year.
pub fn isoYear(date: Date) u16 {
    //------------------------------------------------------------
    return @intCast(cywk(date) / 1_00);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// cywk
//------------------------------------------------------------

/// Returns ISO 8601 century, year and week number.
pub fn cywk(date: Date) u32 {
    //------------------------------------------------------------
    var year = @as(u32, date.year);
    const week_number = wk(date);
    const day_number = ddd(date);
    //------------------------------------------------------------
    if (day_number < 10 and week_number > 51) {
        year -= 1;
    } else if (day_number > 350 and week_number < 2) {
        year += 1;
    }
    //------------------------------------------------------------
    return year * 100 + week_number;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// wk
//------------------------------------------------------------

/// Returns ISO 8601 week number.
pub fn wk(date: Date) u8 {
    //------------------------------------------------------------
    const day_number = ddd(date);
    const jan1_weekday = dow(Date{ .year = date.year, .month = 1, .day = 1 });
    const week_day = dow(date);
    //------------------------------------------------------------
    var year_number: u16 = date.year;
    var week_number: u8 = 0;
    //------------------------------------------------------------
    if (day_number <= (8 - jan1_weekday) and jan1_weekday > 4) {
        year_number = date.year - 1;
        if (jan1_weekday == 5 or (jan1_weekday == 6 and isLeapYear(year_number))) {
            week_number = 53;
        } else {
            week_number = 52;
        }
        //------------------------------------------------------------
    } else {
        //------------------------------------------------------------
        const days_in_year: u16 = if (isLeapYear(date.year)) 366 else 365;
        if (days_in_year -| day_number < 4 -| week_day) {
            year_number = date.year + 1;
            week_number = 1;
        } else {
            const iso_adjusted_days = day_number + (7 - week_day) + (jan1_weekday - 1);
            week_number = @intCast(iso_adjusted_days / 7);
            if (jan1_weekday > 4) {
                week_number -= 1;
            }
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return week_number;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// q
//------------------------------------------------------------

/// Returns quarter.
pub fn q(month: u8) u8 {
    //------------------------------------------------------------
    switch (month) {
        1, 2, 3 => return 1,
        4, 5, 6 => return 2,
        7, 8, 9 => return 3,
        else => return 4,
    }
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmmsszzz
//------------------------------------------------------------

/// Returns hours, minutes, seconds and milliseconds.
pub fn hhmmsszzz(time: Time) u32 {
    //------------------------------------------------------------
    return @as(u32, time.hour) * 1_00_00_000 + @as(u32, time.minute) * 1_00_000 + @as(u32, time.second) * 1_000 + @as(u32, time.millisecond);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmmss
//------------------------------------------------------------

/// Returns hours, minutes and seconds.
pub fn hhmmss(time: Time) u32 {
    //------------------------------------------------------------
    return @as(u32, time.hour) * 1_00_00 + @as(u32, time.minute) * 1_00 + @as(u32, time.second);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmm
//------------------------------------------------------------

/// Returns hours and minutes.
pub fn hhmm(time: Time) u16 {
    //------------------------------------------------------------
    return @as(u16, time.hour) * 1_00 + @as(u16, time.minute);
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hh
//------------------------------------------------------------

/// Returns hours.
pub fn hh(time: Time) u8 {
    //------------------------------------------------------------
    return time.hour;
    //------------------------------------------------------------
}

//------------------------------------------------------------
//  mm
//------------------------------------------------------------

/// Returns minutes.
pub fn mm(time: Time) u8 {
    //------------------------------------------------------------
    return time.minute;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// ss
//------------------------------------------------------------

/// Returns seconds.
pub fn ss(time: Time) u8 {
    //------------------------------------------------------------
    return time.second;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// zzz
//------------------------------------------------------------

/// Returns milliseconds.
pub fn zzz(time: Time) u16 {
    //------------------------------------------------------------
    return time.millisecond;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// ms
//------------------------------------------------------------

/// Returns milliseconds.
pub fn ms(time: Time) u16 {
    //------------------------------------------------------------
    return time.millisecond;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmmss_to_seconds
//------------------------------------------------------------

/// Converts hours, minutes and seconds into seconds.
pub fn hhmmss_to_seconds(HHMMSS: u32) u32 {
    //------------------------------------------------------------
    return HHMMSS / 10000 * 3600 + (HHMMSS / 100) % 100 * 60 + HHMMSS % 100;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// seconds_to_hhmmss
//------------------------------------------------------------

/// Converts seconds into hours, minutes and seconds.
pub fn seconds_to_hhmmss(seconds: u32) u32 {
    //------------------------------------------------------------
    return seconds / 3600 * 10000 + (seconds % 3600) / 60 * 100 + seconds % 60;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// hhmm_to_mins
//------------------------------------------------------------

/// Converts hours and minutes into minutes.
pub fn hhmm_to_mins(HHMM: u16) u16 {
    //------------------------------------------------------------
    return HHMM / 100 * 60 + HHMM % 100;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// mins_to_hhmm
//------------------------------------------------------------

/// Converts minutes into hours and minutes.
pub fn mins_to_hhmm(mins: u16) u16 {
    //------------------------------------------------------------
    return mins / 60 * 1_00 + mins % 60;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// processToken
//------------------------------------------------------------

pub fn processToken(
    token: []const u8,
    value: anytype,
    comptime fmt: []const u8,
    template: []const u8,
    template_index: *usize,
    output: []u8,
    output_index: *usize,
) !bool {
    //------------------------------------------------------------
    if (token.len == 0) return error.InvalidToken;
    if (template_index.* >= template.len) return error.InvalidTemplateIndex;
    //------------------------------------------------------------
    // return false here rather than error incase multiple tokens being checked
    if (template_index.* + token.len > template.len) return false;
    //------------------------------------------------------------
    if (output_index.* >= output.len) return error.OutputBufferTooSmall;
    //------------------------------------------------------------
    if (std.mem.eql(u8, template[template_index.* .. template_index.* + token.len], token)) {
        //----------------------------------------
        // should return error if buffer too small for value
        const written = try std.fmt.bufPrint(output[output_index.*..][0..output.len -| output_index.*], fmt, .{value});
        //----------------------------------------
        output_index.* += written.len;
        template_index.* += token.len;
        //----------------------------------------
        return true;
        //----------------------------------------
    }
    //------------------------------------------------------------
    return false;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// format
//------------------------------------------------------------

pub fn format(datetime: DateTime, template: []const u8, output: []u8) !usize {
    //------------------------------------------------------------
    var template_index: usize = 0;
    var output_index: usize = 0;
    //----------------------------------------
    while (template_index < template.len) {
        //----------------------------------------
        if (output_index >= output.len) return error.OutputBufferTooSmall;
        //----------------------------------------
        // replacements in a set order to avoid template clashes
        if (try processToken("utms", utms(datetime), "{d}", template, &template_index, output, &output_index)) continue;
        if (try processToken("ut", ut(datetime), "{d}", template, &template_index, output, &output_index)) continue;
        if (try processToken("ddd", ddd(toDate(datetime)), "{d:0>3}", template, &template_index, output, &output_index)) continue;
        if (try processToken("hh", hh(toTime(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("mm", mm(toTime(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("ss", ss(toTime(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("zzz", zzz(toTime(datetime)), "{d:0>3}", template, &template_index, output, &output_index)) continue;
        if (try processToken("DST", if (isDST(toDate(datetime))) "DST" else "", "{s}", template, &template_index, output, &output_index)) continue;
        if (try processToken("cywk", cywk(toDate(datetime)), "{d:0>4}", template, &template_index, output, &output_index)) continue;
        if (try processToken("wk", wk(toDate(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("CY", isoYear(toDate(datetime)), "{d:0>4}", template, &template_index, output, &output_index)) continue;
        if (try processToken("cy", cy(toDate(datetime)), "{d:0>4}", template, &template_index, output, &output_index)) continue;
        if (try processToken("c", c(toDate(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("y", y(toDate(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("m", m(toDate(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("d", d(toDate(datetime)), "{d:0>2}", template, &template_index, output, &output_index)) continue;
        if (try processToken("MM", monthMM(toDate(datetime)), "{s}", template, &template_index, output, &output_index)) continue;
        if (try processToken("M", monthM(toDate(datetime)), "{s}", template, &template_index, output, &output_index)) continue;
        if (try processToken("DD", dowDD(toDate(datetime)), "{s}", template, &template_index, output, &output_index)) continue;
        if (try processToken("D", dowD(toDate(datetime)), "{s}", template, &template_index, output, &output_index)) continue;
        if (try processToken("q", q(datetime.month), "{d}", template, &template_index, output, &output_index)) continue;
        //----------------------------------------
        // check again just incase missed by above code
        if (output_index >= output.len) return error.OutputBufferTooSmall;
        //----------------------------------------
        // if no token match just use char from template
        output[output_index] = template[template_index];
        //----------------------------------------
        template_index += 1;
        output_index += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    return output_index;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// main
//------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    var it = std.process.args();
    const name = if (it.next()) |arg0| std.fs.path.basename(arg0) else "";
    std.debug.print("{s}: main function\n", .{name});
    //------------------------------------------------------------
}

//------------------------------------------------------------

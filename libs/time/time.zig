//------------------------------------------------------------
// Time Library
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------

pub const SECONDS_PER_DAY = 86400;
pub const DAYS_PER_YEAR = 365;
pub const DAYS_IN_4YEARS = 1461;
pub const DAYS_IN_100YEARS = 36524;
pub const DAYS_IN_400YEARS = 146097;
pub const DAYS_BEFORE_EPOCH = 719468;

pub const SECONDS_PER_MINUTE = 60;
pub const SECONDS_PER_HOUR = 3600;

pub const SECONDS_MIN = -62_135_596_800; // 0001-01-01 00:00:00
pub const SECONDS_MAX = 253402300799; // 9999-12-31 23:59:59

//------------------------------------------------------------

pub const DateTime = struct {
    year: u16 = 0,
    month: u8 = 0,
    day: u8 = 0,
    hour: u8 = 0,
    minute: u8 = 0,
    second: u8 = 0,
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
};

//------------------------------------------------------------
// now
//------------------------------------------------------------

/// Returns initialised DateTime struct.
pub fn now() DateTime {
    return fromTimestamp(std.time.timestamp()) catch DateTime{};
}

//------------------------------------------------------------
// unix_timestamp
//------------------------------------------------------------

/// Returns unix timestamp (seconds).
pub fn unix_timestamp() i64 {
    return std.time.timestamp();
}

//------------------------------------------------------------
// fromTimestamp
//------------------------------------------------------------

/// Converts a timestamp into a DateTime.
/// Valid range: -62_135_596_800 to 253402300799.
/// (0001-01-01T00:00:00Z to 9999-12-31T23:59:59Z).
pub fn fromTimestamp(timestamp: i64) !DateTime {
    //------------------------------------------------------------
    // adapted from code by Karl Seguin - https://github.com/karlseguin
    //------------------------------------------------------------
    if (timestamp < SECONDS_MIN or timestamp > SECONDS_MAX) return error.InvalidTimestamp;
    //------------------------------------------------------------
    const days = @divFloor(timestamp, SECONDS_PER_DAY);
    const seconds_in_day = @mod((@mod(timestamp, SECONDS_PER_DAY) + SECONDS_PER_DAY), SECONDS_PER_DAY);
    var days_since_epoch = DAYS_BEFORE_EPOCH + days;
    //------------------------------------------------------------
    var temp: i64 = 0;
    //------------------------------------------------------------
    temp = @divFloor((4 * (days_since_epoch + DAYS_IN_100YEARS + 1)), DAYS_IN_400YEARS) - 1;
    var year = 100 * temp;
    days_since_epoch -= DAYS_IN_100YEARS * temp + @divFloor(temp, 4);
    //------------------------------------------------------------
    temp = @divFloor((4 * (days_since_epoch + DAYS_PER_YEAR + 1)), DAYS_IN_4YEARS) - 1;
    year += temp;
    days_since_epoch -= DAYS_PER_YEAR * temp + @divFloor(temp, 4);
    //------------------------------------------------------------
    var month = @divFloor((5 * days_since_epoch + 2), 153);
    const day = days_since_epoch - @divFloor((month * 153 + 2), 5) + 1;
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
// toTimestamp
//------------------------------------------------------------

/// Converts a DateTime into a timestamp.
/// Valid range: 0001-01-01T00:00:00Z to 9999-12-31T23:59:59Z.
pub fn toTimestamp(datetime: DateTime) !i64 {
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

    const days_since_epoch: i64 =
        gregorian_cycle * DAYS_IN_400YEARS +
        day_of_gregorian_cycle -
        DAYS_BEFORE_EPOCH;

    const seconds_since_epoch: i64 =
        days_since_epoch * SECONDS_PER_DAY +
        @as(i64, datetime.hour) * SECONDS_PER_HOUR +
        @as(i64, datetime.minute) * SECONDS_PER_MINUTE +
        @as(i64, datetime.second);
    //------------------------------------------------------------
    if (seconds_since_epoch < SECONDS_MIN or seconds_since_epoch > SECONDS_MAX)
        return error.OverflowError;
    //------------------------------------------------------------
    return seconds_since_epoch;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// checkDateTime
//------------------------------------------------------------

/// Checks DateTime.
pub fn checkDateTime(datetime: DateTime) bool {
    //------------------------------------------------------------
    if (datetime.year < 1 or datetime.year > 9999) return false;
    if (datetime.month < 1 or datetime.month > 12) return false;
    if (datetime.day < 1 or datetime.day > lastDayOfMonth(Date{
        .year = datetime.year,
        .month = datetime.month,
        .day = datetime.day,
    })) return false;
    //------------------------------------------------------------
    if (datetime.hour > 23 or datetime.minute > 59 or datetime.second > 59) return false;
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
    if (date.year < 1 or date.year > 9999) return false;
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
    if (time.hour > 23 or time.minute > 59 or time.second > 59) return false;
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}

//------------------------------------------------------------
// lastDayOfMonth
//------------------------------------------------------------

/// Returns last day of month.
pub fn lastDayOfMonth(date: Date) u8 {
    return switch (date.month) {
        1, 3, 5, 7, 8, 10, 12 => 31,
        4, 6, 9, 11 => 30,
        2 => if (isLeapYear(date.year)) 29 else 28,
        else => 0,
    };
}

//------------------------------------------------------------
// isLeapYear
//------------------------------------------------------------

/// Checks if year passed is a leap year.
pub fn isLeapYear(year: u16) bool {
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0);
}

//------------------------------------------------------------
// isDST
//------------------------------------------------------------

/// Returns true if given date falls on british summer time, otherwise false.
/// Ignores time of day. Based on gregorian calendar which started 1582-10-15.
pub fn isDST(date: Date) bool {
    if (date.month < 3 or date.month > 10) {
        return false;
    }

    if (date.month > 3 and date.month < 10) {
        return true;
    }

    const day_of_week = dow(Date{ .year = date.year, .month = date.month, .day = 31 });
    const last_sunday = if (day_of_week == 7) 31 else 31 - day_of_week;

    if (date.month == 3) {
        return date.day >= last_sunday;
    } else {
        return date.day < last_sunday;
    }
}

//------------------------------------------------------------
// cymd
//------------------------------------------------------------

/// Returns century, year, month and day
pub fn cymd(date: Date) u32 {
    return @as(u32, date.year) * 1_00_00 + @as(u32, date.month) * 1_00 + @as(u32, date.day);
}

//------------------------------------------------------------
// ymd
//------------------------------------------------------------

/// Returns year, month and day
pub fn ymd(date: Date) u32 {
    return @as(u32, date.year % 100) * 1_00_00 + @as(u32, date.month) * 1_00 + @as(u32, date.day);
}

//------------------------------------------------------------
// cy
//------------------------------------------------------------

/// Returns century and year
pub fn cy(date: Date) u32 {
    return @as(u32, date.year);
}

//------------------------------------------------------------
// y
//------------------------------------------------------------

/// Returns year
pub fn y(date: Date) u32 {
    return @as(u32, date.year % 100);
}

//------------------------------------------------------------
// m
//------------------------------------------------------------

/// Returns month
pub fn m(date: Date) u32 {
    return @as(u32, date.month);
}

//------------------------------------------------------------
// d
//------------------------------------------------------------

/// Returns day of month
pub fn d(date: Date) u32 {
    return @as(u32, date.day);
}

//------------------------------------------------------------
// md
//------------------------------------------------------------

/// Returns month and day
pub fn md(date: Date) u32 {
    return @as(u32, date.month) * 1_00 + @as(u32, date.day);
}

//------------------------------------------------------------
// dm
//------------------------------------------------------------

/// Returns day and month
pub fn dm(date: Date) u32 {
    return @as(u32, date.day) * 1_00 + @as(u32, date.month);
}

//------------------------------------------------------------
// cyddd
//------------------------------------------------------------

/// Returns year an day number
pub fn cyddd(date: Date) u32 {
    return @as(u32, date.year) * 1_000 + ddd(date);
}

//------------------------------------------------------------
// ddd
//------------------------------------------------------------

/// Returns day number
pub fn ddd(date: Date) u32 {
    const day_number: u32 = switch (date.month) {
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
    return if (isLeapYear(date.year) and date.month >= 3) day_number + date.day else date.day + day_number - 1;
}

//------------------------------------------------------------
// dow
//------------------------------------------------------------

/// Returns day of week using Zeller's congruence algorithm (adjusted to mon = 1, sun = 7).
/// Based on gregorian calendar which started 1582-10-15.
/// (same logic still used for previous dates).
pub fn dow(date: Date) u8 {
    var Y = @as(i32, date.year);
    var M = @as(i32, date.month);

    if (M < 3) {
        M += 12;
        Y -= 1;
    }

    const K = @mod(Y, 100);
    const J = @divFloor(Y, 100);

    const H = @mod((@as(i32, date.day) + @divFloor((13 * (M + 1)), 5) + K + @divFloor(K, 4) + @divFloor(J, 4) + 5 * J), 7);

    // adjust: Zeller's output 0 = Saturday => 6, so Sunday = 0
    const dow_zero_sunday: u8 = @intCast(@mod((H + 6), 7));
    // convert to sun = 7
    return if (dow_zero_sunday == 0) 7 else dow_zero_sunday;
}

//------------------------------------------------------------
// dowD
//------------------------------------------------------------

/// Returns shortened day of week as a string
pub fn dowD(date: Date) []const u8 {
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
}

//------------------------------------------------------------
// dowDD
//------------------------------------------------------------

/// Returns day of week as a string
pub fn dowDD(date: Date) []const u8 {
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
}

//------------------------------------------------------------
// MonthM
//------------------------------------------------------------

/// Returns shortened month as a string
pub fn monthM(date: Date) []const u8 {
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
}

//------------------------------------------------------------
// MonthMM
//------------------------------------------------------------

/// Returns month as a string
pub fn monthMM(date: Date) []const u8 {
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
}

//------------------------------------------------------------
// isoYear
//------------------------------------------------------------

/// Returns ISO 8601 year.
pub fn isoYear(date: Date) u32 {
    return cywk(date) / 1_00;
}

//------------------------------------------------------------
// cywk
//------------------------------------------------------------

/// Returns ISO 8601 year and week number.
pub fn cywk(date: Date) u32 {
    var year = @as(u32, date.year);
    const week_number = wk(date);
    const day_number = ddd(date);

    if (day_number < 10 and week_number > 51) {
        year -= 1;
    } else if (day_number > 350 and week_number < 2) {
        year += 1;
    }

    return year * 100 + week_number;
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
    switch (month) {
        1, 2, 3 => return 1,
        4, 5, 6 => return 2,
        7, 8, 9 => return 3,
        else => return 4,
    }
}

//------------------------------------------------------------
// hhmmss
//------------------------------------------------------------

/// Returns hours, minutes and seconds
pub fn hhmmss(time: Time) u32 {
    return @as(u32, time.hour) * 1_00_00 + @as(u32, time.minute) * 1_00 + @as(u32, time.second);
}

//------------------------------------------------------------
// hhmm
//------------------------------------------------------------

/// Returns hours and minutes
pub fn hhmm(time: Time) u32 {
    return @as(u32, time.hour) * 1_00 + @as(u32, time.minute);
}

//------------------------------------------------------------
// hh
//------------------------------------------------------------

/// Returns hours
pub fn hh(time: Time) u32 {
    return @as(u32, time.hour);
}

//------------------------------------------------------------
//  mm
//------------------------------------------------------------

/// Returns minutes
pub fn mm(time: Time) u32 {
    return @as(u32, time.minute);
}

//------------------------------------------------------------
// ss
//------------------------------------------------------------

/// Returns seconds
pub fn ss(time: Time) u32 {
    return @as(u32, time.second);
}

//------------------------------------------------------------
// hhmmss_to_seconds
//------------------------------------------------------------

/// Converts hours, minutes and seconds into seconds
pub fn hhmmss_to_seconds(_hhmmss: u32) u32 {
    const _hh = _hhmmss / 10000;
    const _mm = (_hhmmss / 100) % 100;
    const _ss = _hhmmss % 100;
    return _hh * 3600 + _mm * 60 + _ss;
}

//------------------------------------------------------------
// seconds_to_hhmmss
//------------------------------------------------------------

/// Converts seconds into hours, minutes and seconds
pub fn seconds_to_hhmmss(_seconds: u32) u32 {
    const _hh = _seconds / 3600;
    const _mm = (_seconds % 3600) / 60;
    const _ss = _seconds % 60;
    return _hh * 10000 + _mm * 100 + _ss;
}

//------------------------------------------------------------
// hhmm_to_mins
//------------------------------------------------------------

/// Converts hours, minutes into minutes
pub fn hhmm_to_mins(_hhmm: u32) u32 {
    const _hh = _hhmm / 1_00;
    const _mm = _hhmm - _hh * 1_00;
    return _hh * 60 + _mm;
}

//------------------------------------------------------------
// mins_to_hhmm
//------------------------------------------------------------

/// Converts minutes into hours and minutes
pub fn mins_to_hhmm(_mins: u32) u32 {
    const _hh = _mins / 60;
    return _hh * 1_00 + _mins % 60;
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

//------------------------------------------------------------

const std = @import("std");

//------------------------------------------------------------

const SECONDS_PER_DAY = 86400;
const DAYS_PER_YEAR = 365;
const DAYS_IN_4YEARS = 1461;
const DAYS_IN_100YEARS = 36524;
const DAYS_IN_400YEARS = 146097;
const DAYS_BEFORE_EPOCH = 719468;

const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 3600;

//------------------------------------------------------------

pub const DateTime = struct {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8,
};

//------------------------------------------------------------

/// Converts a timestamp into a DateTime. Valid range: 0 to 253_402_300_799.
pub fn fromTimestamp(ts: i64) !DateTime {
    //------------------------------------------------------------
    // adapted from code by Karl Seguin - https://github.com/karlseguin
    //------------------------------------------------------------
    if (ts < 0 or ts > 253_402_300_799) {
        return error.InvalidTimestamp;
    }
    //------------------------------------------------------------
    const timestamp: u64 = @intCast(ts);
    //------------------------------------------------------------
    const seconds_since_midnight: u64 = @rem(timestamp, SECONDS_PER_DAY);
    var days_since_epoch: u64 = DAYS_BEFORE_EPOCH + timestamp / SECONDS_PER_DAY;
    var temp: u64 = 0;

    temp = 4 * (days_since_epoch + DAYS_IN_100YEARS + 1) / DAYS_IN_400YEARS - 1;
    var year: u16 = @intCast(100 * temp);
    days_since_epoch -= DAYS_IN_100YEARS * temp + temp / 4;

    temp = 4 * (days_since_epoch + DAYS_PER_YEAR + 1) / DAYS_IN_4YEARS - 1;
    year += @intCast(temp);
    days_since_epoch -= DAYS_PER_YEAR * temp + temp / 4;

    var month: u8 = @intCast((5 * days_since_epoch + 2) / 153);
    const day: u8 = @intCast(days_since_epoch - (@as(u64, @intCast(month)) * 153 + 2) / 5 + 1);

    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    //------------------------------------------------------------
    return DateTime{ .year = year, .month = month, .day = day, .hour = @intCast(seconds_since_midnight / SECONDS_PER_HOUR), .minute = @intCast(seconds_since_midnight % SECONDS_PER_HOUR / SECONDS_PER_MINUTE), .second = @intCast(seconds_since_midnight % SECONDS_PER_MINUTE) };
    //------------------------------------------------------------
}

/// Converts a DateTime into a timestamp. Valid range: 1970-01-01T00:00:00Z to 9999-12-31T23:59:59Z.
pub fn toTimestamp(datetime: DateTime) !i64 {
    //------------------------------------------------------------
    if (datetime.year < 1970 or datetime.year > 9999) return error.InvalidDateTime;
    if (datetime.month < 1 or datetime.month > 12) return error.InvalidDateTime;
    if (datetime.day < 1 or datetime.day > 31) return error.InvalidDateTime;
    if (datetime.hour > 23 or datetime.minute > 59 or datetime.second > 59) return error.InvalidDateTime;
    //------------------------------------------------------------
    var year = @as(u64, datetime.year);
    var month = @as(u64, datetime.month);
    const day = @as(u64, datetime.day);

    if (month <= 2) {
        year -= 1;
        month += 12;
    }

    const gregorian_cycle = @divTrunc(year, 400);
    const year_of_gregorian_cycle = year - gregorian_cycle * 400;
    const day_of_year = @divTrunc(153 * (month - 3) + 2, 5) + day - 1;
    const day_of_gregorian_cycle = year_of_gregorian_cycle * 365 + @divTrunc(year_of_gregorian_cycle, 4) - @divTrunc(year_of_gregorian_cycle, 100) + day_of_year;

    const days_since_epoch: u64 = gregorian_cycle * DAYS_IN_400YEARS + day_of_gregorian_cycle - DAYS_BEFORE_EPOCH;

    const seconds_since_epoch: u64 = days_since_epoch * SECONDS_PER_DAY +
        @as(u64, datetime.hour) * SECONDS_PER_HOUR +
        @as(u64, datetime.minute) * SECONDS_PER_MINUTE +
        @as(u64, datetime.second);
    //------------------------------------------------------------
    if (seconds_since_epoch > 253_402_300_799) return error.TimestampOverflow;
    //------------------------------------------------------------
    return @intCast(seconds_since_epoch);
    //------------------------------------------------------------
}

//------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    const ts = std.time.timestamp();
    std.debug.print("ts: {any}\n", .{ts});
    //------------------------------------------------------------
    const datetime = try fromTimestamp(ts);
    std.debug.print("{any}\n", .{datetime});
    //------------------------------------------------------------
    const timestamp = toTimestamp(datetime);
    std.debug.print("timestamp: {any}\n", .{timestamp});
    //------------------------------------------------------------

    //------------------------------------------------------------
}

//------------------------------------------------------------

const std = @import("std");
const c = @cImport(@cInclude("time.h"));

pub fn main() !void {
    //------------------------------------------------------------
    // get timestamp

    // optionally pass a ref to your own copy of c.time_t variable to update
    var timestamp = c.time(null);

    std.debug.print("\ntimestamp: {d}\n", .{timestamp});
    //------------------------------------------------------------
    var dt_str_buf: [40]u8 = undefined;
    var dt_str_len: usize = undefined;
    //------------------------------------------------------------
    // format to string

    const format = "%a %d %b %Y %H:%M:%S %Z";

    // not thread safe
    const tm = c.gmtime(&timestamp);
    dt_str_len = c.strftime(&dt_str_buf, dt_str_buf.len, format, tm);
    std.debug.print("\nstrftime: {s}\n", .{dt_str_buf[0..dt_str_len]});

    // thread safe
    var struct_tm: c.struct_tm = undefined;
    const struct_tm_ptr = c.gmtime_r(&timestamp, &struct_tm);

    dt_str_len = c.strftime(&dt_str_buf, dt_str_buf.len, format, struct_tm_ptr);
    std.debug.print("strftime: {s}\n", .{dt_str_buf[0..dt_str_len]});

    dt_str_len = c.strftime(&dt_str_buf, dt_str_buf.len, format, &struct_tm);
    std.debug.print("strftime: {s}\n", .{dt_str_buf[0..dt_str_len]});
    //------------------------------------------------------------
    const year = tm.*.tm_year + 1900; // tm_year is years since 1900
    const month = tm.*.tm_mon + 1; // tm_mon is 0-based, so add 1
    const day = tm.*.tm_mday;
    const hour = tm.*.tm_hour;
    const minute = tm.*.tm_min;
    const second = tm.*.tm_sec;

    std.debug.print("\nYear: {d}\n", .{year});
    std.debug.print("Month: {d}\n", .{month});
    std.debug.print("Day: {d}\n", .{day});
    std.debug.print("Hour: {d}\n", .{hour});
    std.debug.print("Minute: {d}\n", .{minute});
    std.debug.print("Second: {d}\n", .{second});
    //------------------------------------------------------------
    // get timestamp from struct_tm

    tm.*.tm_year += 1;

    const new_timestamp = c.mktime(tm);
    std.debug.print("\nnew timestamp: {d}\n", .{new_timestamp});
    //------------------------------------------------------------
    // get new date string
    const final_tm = c.gmtime(&new_timestamp);
    const final_dt_str_len = c.strftime(&dt_str_buf, dt_str_buf.len, format, final_tm);
    std.debug.print("\nnew time string: {s}\n\n", .{dt_str_buf[0..final_dt_str_len]});
    //------------------------------------------------------------
}

//------------------------------------------------------------

// strftime format specifiers:

// %a - Abbreviated weekday name (e.g., Sun)
// %A - Full weekday name (e.g., Sunday)
// %b - Abbreviated month name (e.g., Jan)
// %B - Full month name (e.g., January)
// %c - Date and time representation (locale-specific)
// %C - Century (year / 100 as integer)
// %d - Day of the month (01–31)
// %D - Equivalent to %m/%d/%y
// %e - Day of the month, space-padded ( 1–31)
// %F - Equivalent to %Y-%m-%d (ISO 8601 date)
// %g - Last two digits of ISO week-numbering year
// %G - ISO week-numbering year
// %h - Same as %b
// %H - Hour (00–23)
// %I - Hour (01–12)
// %j - Day of year (001–366)
// %k - Hour (0–23), space-padded
// %l - Hour (1–12), space-padded
// %m - Month (01–12)
// %M - Minute (00–59)
// %n - Newline
// %p - AM or PM
// %P - am or pm
// %r - 12-hour clock time (e.g., 01:23:45 PM)
// %R - 24-hour time without seconds (e.g., 13:23)
// %s - Seconds since the Epoch (UNIX timestamp)
// %S - Second (00–60)
// %t - Tab character
// %T - Time in HH:MM:SS
// %u - Day of the week (1–7, Monday is 1)
// %U - Week number (Sunday as first day of week)
// %V - ISO 8601 week number (01–53)
// %w - Day of the week (0–6, Sunday is 0)
// %W - Week number (Monday as first day of week)
// %x - Date representation (locale-specific)
// %X - Time representation (locale-specific)
// %y - Year without century (00–99)
// %Y - Year with century
// %z - +hhmm numeric timezone (e.g., +0200)
// %Z - Timezone abbreviation (e.g., CET)
// %% - Literal percent sign

//------------------------------------------------------------

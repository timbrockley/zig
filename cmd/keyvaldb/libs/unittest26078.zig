//--------------------------------------------------------------------------------
// Unit Test Library
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const RESET = "\x1B[0m";
const BLUE = "\x1B[34m";
const MAGENTA = "\x1B[35m";
const RED = "\x1B[31m";
const GREEN = "\x1B[32m";
//--------------------------------------------------------------------------------
const Self = @This();
//------------------------------------------------------------
io: ?std.Io = null,
//------------------------------------------------------------
stdout_writer: ?std.Io.File.Writer = null,
stderr_writer: ?std.Io.File.Writer = null,
//------------------------------------------------------------
start_time_ns: i96 = 0,
//------------------------------------------------------------
count_passed: usize = 0,
count_failed: usize = 0,
//--------------------------------------------------------------------------------
pub fn init(options: anytype) !Self {
    //------------------------------------------------------------
    var self = Self{};
    //------------------------------------------------------------
    inline for (std.meta.fields(@TypeOf(self))) |field| {
        if (@hasField(@TypeOf(options), field.name)) {
            @field(self, field.name) = @field(options, field.name);
        }
    }
    //------------------------------------------------------------
    const io = self.io orelse return error.InvalidStdIo;
    //------------------------------------------------------------
    self.start_time_ns = std.Io.Timestamp.now(io, .real).toNanoseconds();
    //------------------------------------------------------------
    self.stdout_writer = std.Io.File.Writer.init(.stdout(), io, &.{});
    self.stderr_writer = std.Io.File.Writer.init(.stderr(), io, &.{});
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
    return self;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn compareStringResultError(self: *Self, name: []const u8, result_error: anyerror![]const u8, expected_result: []const u8, expected_error: ?anyerror) !void {
    //------------------------------------------------------------
    var fail_count: usize = 0;
    //------------------------------------------------------------
    if (result_error) |result| {
        //----------------------------------------
        if (expected_error != null) {
            //----------------------------------------
            fail_count += 1;
            try self.errorExpectedFail(name, expected_error.?);
            //----------------------------------------
        } else {
            //----------------------------------------
            if (!std.mem.eql(u8, result, expected_result)) {
                //----------------------------------------
                fail_count += 1;
                //----------------------------------------
                try self.compareStringSlice(name, expected_result, result);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //------------------------------------------------------------
    } else |err| {
        //----------------------------------------
        if (expected_error != null) {
            //----------------------------------------
            if (err != expected_error.?) {
                //----------------------------------------
                fail_count += 1;
                try self.compareError(name, expected_error.?, err);
                //----------------------------------------
            }
            //----------------------------------------
        } else {
            //----------------------------------------
            fail_count += 1;
            try self.errorFail(name, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    if (fail_count == 0) try self.pass(name, "");
    //------------------------------------------------------------
    return;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn compareStringSlice(self: *Self, name: []const u8, expected: []const u8, actual: []const u8) !void {
    //------------------------------------------------------------
    if (std.mem.eql(u8, expected, actual)) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {s}\n", .{expected});
        try self.printActual();
        try self.stdout_print(":   {s}\n", .{actual});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Checks string formatting.
///
/// d => Digits (0-9)
/// D => Not Digits (0-9)
///
/// a => Uppercase or Lowercase Letters
/// A => Not Uppercase or Lowercase Letters
///
/// n => Alphanumeric
/// N => Not Alphanumeric
///
/// u => Uppercase Letters
/// U => Not Uppercase Letters
///
/// l => Lowercase Letters
/// L => Not Lowercase Letters
///
/// (Other characters ignored).
pub fn compareStringFormat(self: *Self, name: []const u8, string: []const u8, format: []const u8) !void {
    //------------------------------------------------------------

    var pass_count: usize = 0;
    //------------------------------------------------------------
    if (string.len == format.len) {
        //------------------------------------------------------------
        for (string, format) |string_byte, format_byte| {
            //------------------------------------------------------------
            switch (format_byte) {
                'd' => {
                    if (std.ascii.isDigit(string_byte)) pass_count += 1;
                },
                'D' => {
                    if (!std.ascii.isDigit(string_byte)) pass_count += 1;
                },
                'a' => {
                    if (std.ascii.isAlphabetic(string_byte)) pass_count += 1;
                },
                'A' => {
                    if (!std.ascii.isAlphabetic(string_byte)) pass_count += 1;
                },
                'n' => {
                    if (std.ascii.isAlphanumeric(string_byte)) pass_count += 1;
                },
                'N' => {
                    if (!std.ascii.isAlphanumeric(string_byte)) pass_count += 1;
                },
                'u' => {
                    if (std.ascii.isUpper(string_byte)) pass_count += 1;
                },
                'U' => {
                    if (!std.ascii.isUpper(string_byte)) pass_count += 1;
                },
                'l' => {
                    if (std.ascii.isLower(string_byte)) pass_count += 1;
                },
                'L' => {
                    if (!std.ascii.isLower(string_byte)) pass_count += 1;
                },
                else => {
                    pass_count += 1;
                },
            }
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    if (string.len == format.len and pass_count == format.len) {
        //------------------------------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //------------------------------------------------------------
    } else {
        //------------------------------------------------------------
        try self.printFail();
        try self.stdout_print(": {s}\n", .{name});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareByteSlice(self: *Self, name: []const u8, expected: []const u8, actual: []const u8) !void {
    //------------------------------------------------------------
    if (std.mem.eql(u8, expected, actual)) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {any}\n", .{expected});
        try self.printActual();
        try self.stdout_print(":   {any}\n", .{actual});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn compareByte(self: *Self, name: []const u8, expected: u8, actual: u8) !void {
    //------------------------------------------------------------
    if (expected == actual) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {d}\n", .{expected});
        try self.printActual();
        try self.stdout_print(":   {d}\n", .{actual});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn compareInt(self: *Self, name: []const u8, expected: u64, actual: u64) !void {
    //------------------------------------------------------------
    if (expected == actual) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {d}\n", .{expected});
        try self.printActual();
        try self.stdout_print(":   {d}\n", .{actual});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn compareBool(self: *Self, name: []const u8, expected: bool, actual: bool) !void {
    //----------------------------------------------------------------------------
    if (expected == actual) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {}\n", .{expected});
        try self.printActual();
        try self.stdout_print(":   {}\n", .{actual});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareError(self: *Self, name: []const u8, expected_error: anyerror, actual_error: anyerror) !void {
    //----------------------------------------------------------------------------
    if (expected_error == actual_error) {
        //----------------------------------------
        try self.printPass();
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFail();
        try self.stdout_print(":     {s}\n", .{name});
        try self.printExpected();
        try self.stdout_print(": {}\n", .{expected_error});
        try self.printActual();
        try self.stdout_print(":   {}\n", .{actual_error});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn pass(self: *Self, name: []const u8, message: []const u8) !void {
    //----------------------------------------------------------------------------
    try self.stderr_writeAll(GREEN);
    try self.stdout_writeAll("PASS");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    if (message.len == 0) {
        try self.stdout_print(": {s}\n", .{name});
    } else {
        try self.stdout_print(": {s}: {s}\n", .{ name, message });
    }
    //----------------------------------------
    self.count_passed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn fail(self: *Self, name: []const u8, message: []const u8) !void {
    //----------------------------------------------------------------------------
    try self.stderr_writeAll(RED);
    try self.stdout_writeAll("FAIL");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    if (message.len == 0) {
        try self.stdout_print(": {s}\n", .{name});
    } else {
        try self.stdout_print(": {s}: {s}\n", .{ name, message });
    }
    //----------------------------------------
    self.count_failed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn errorPass(self: *Self, name: []const u8, err: anyerror) !void {
    //----------------------------------------------------------------------------
    try self.stderr_writeAll(GREEN);
    try self.stdout_writeAll("PASS");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    try self.stdout_print(": {s} (correctly returned: {})\n", .{ name, err });
    //----------------------------------------
    self.count_passed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorFail(self: *Self, name: []const u8, err: anyerror) !void {
    //----------------------------------------------------------------------------
    try self.stderr_writeAll(RED);
    try self.stdout_writeAll("FAIL");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    try self.stdout_print(": {s}: (incorrectly returned: {})\n", .{ name, err });
    //----------------------------------------
    self.count_failed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorExpectedFail(self: *Self, name: []const u8, expected_error: anyerror) !void {
    //----------------------------------------------------------------------------
    try self.stderr_writeAll(RED);
    try self.stdout_writeAll("FAIL");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    try self.stdout_print(": {s}: (expected error not returned: {})\n", .{ name, expected_error });
    //----------------------------------------
    self.count_failed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn printExpected(self: *Self) !void {
    try self.printColour(BLUE, "EXPECTED");
}
pub fn printActual(self: *Self) !void {
    try self.printColour(MAGENTA, "ACTUAL");
}
pub fn printPass(self: *Self) !void {
    try self.printColour(GREEN, "PASS");
}
pub fn printFail(self: *Self) !void {
    try self.printColour(RED, "FAIL");
}
pub fn printColour(self: *Self, colour: []const u8, comptime string: []const u8) !void {
    try self.stderr_writeAll(colour);
    try self.stdout_writeAll(string);
    try self.stderr_writeAll(RESET);
}
//------------------------------------------------------------
pub fn printLine(self: *Self) !void {
    //------------------------------------------------------------
    try self.stdout_print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn printSummary(self: *Self) !void {
    //------------------------------------------------------------
    const io = self.io orelse return error.InvalidStdIo;
    //------------------------------------------------------------
    try self.stdout_print("PASSED = {d}", .{self.count_passed});
    //------------------------------------------------------------
    if (self.count_failed > 0) {
        try self.stdout_print(" / FAILED = {d}", .{self.count_failed});
    }
    //------------------------------------------------------------
    if (self.start_time_ns > 0) {
        //-----------------------------------
        const duration_ns: i96 = std.Io.Timestamp.now(io, .real).toNanoseconds() - self.start_time_ns;
        const duration_ms: f64 = @as(f64, @floatFromInt(duration_ns)) / 1_000_000;
        //-----------------------------------
        try self.stdout_print(" ({d} ms)", .{duration_ms});
        //-----------------------------------
    }
    //------------------------------------------------------------
    try self.stdout_print("\n", .{});
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn stdout_print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
    if (self.stdout_writer == null) return error.InvalidStdOut;
    try self.stdout_writer.?.interface.print(fmt, args);
}
//------------------------------------------------------------
pub fn stdout_writeAll(self: *Self, bytes: []const u8) !void {
    if (self.stdout_writer == null) return error.InvalidStdOut;
    try self.stdout_writer.?.interface.writeAll(bytes);
}
//------------------------------------------------------------
pub fn stderr_print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
    if (self.stderr_writer == null) return error.InvalidStdErr;
    try self.stderr_writer.?.interface.print(fmt, args);
}
//------------------------------------------------------------
pub fn stderr_writeAll(self: *Self, bytes: []const u8) !void {
    if (self.stderr_writer == null) return error.InvalidStdErr;
    try self.stderr_writer.?.interface.writeAll(bytes);
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn main(processInit: std.process.Init) !void {
    //------------------------------------------------------------
    //############################################################
    //------------------------------------------------------------
    var ut = try init(.{ .io = processInit.io });
    //------------------------------------------------------------
    //############################################################
    //------------------------------------------------------------
    // compareStringResultError expected_result
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError expected_result", "expected_result", "expected_result", null);
    //------------------------------------------------------------
    // compareStringResultError invalid_result - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError invalid_result", "expected_result", "invalid_result", null);
    //------------------------------------------------------------
    // compareStringResultError error.ExpectedError - should pass
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError error.ExpectedError", error.ExpectedError, "", error.ExpectedError);
    //------------------------------------------------------------
    // compareStringResultError error.UnexpectedError - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError error.UnexpectedError", error.UnexpectedError, "", null);
    //------------------------------------------------------------
    // compareStringSlice pass
    //------------------------------------------------------------
    try ut.compareStringSlice("compareStringSlice pass", "foo", "foo");
    //------------------------------------------------------------
    // compareStringSlice fail
    //------------------------------------------------------------
    try ut.compareStringSlice("compareStringSlice fail", "foo", "bar");
    //------------------------------------------------------------
    // compareStringFormat pass
    //------------------------------------------------------------
    try ut.compareStringFormat("compareStringFormat pass", "2026-03-19T10:13:00.072978925Z", "dddd-dd-ddTdd:dd:dd.dddddddddZ");
    //------------------------------------------------------------
    // compareStringFormat fail
    //------------------------------------------------------------
    try ut.compareStringFormat("compareStringFormat fail", "2026-03-19T10:13:00.072978925Z", "");
    //------------------------------------------------------------
    // compareByteSlice pass
    //------------------------------------------------------------
    try ut.compareByteSlice("compareByteSlice pass", "hello", "hello");
    //------------------------------------------------------------
    // compareByteSlice fail
    //------------------------------------------------------------
    try ut.compareByteSlice("compareByteSlice fail", "hello", "world");
    //------------------------------------------------------------
    // compareByte pass
    //------------------------------------------------------------
    try ut.compareByte("compareByte pass", 0, 0);
    //------------------------------------------------------------
    // compareByte fail
    //------------------------------------------------------------
    try ut.compareByte("compareByte fail", 0, 1);
    //------------------------------------------------------------
    // compareInt pass
    //------------------------------------------------------------
    try ut.compareInt("compareInt pass", 0, 0);
    //------------------------------------------------------------
    // compareInt fail
    //------------------------------------------------------------
    try ut.compareInt("compareInt fail", 0, 1);
    //------------------------------------------------------------
    // compareBool pass
    //------------------------------------------------------------
    try ut.compareBool("compareBool pass", true, true);
    //------------------------------------------------------------
    // compareBool fail
    //------------------------------------------------------------
    try ut.compareBool("compareBool fail", true, false);
    //------------------------------------------------------------
    // compareError pass
    //------------------------------------------------------------
    try ut.compareError("compareError ExpectError", error.ExpectError, error.ExpectError);
    //------------------------------------------------------------
    // compareError fail
    //------------------------------------------------------------
    try ut.compareError("compareError InvalidError", error.ExpectError, error.InvalidError);
    //------------------------------------------------------------
    // pass
    //------------------------------------------------------------
    try ut.pass("pass", "");
    //------------------------------------------------------------
    // fail
    //------------------------------------------------------------
    try ut.fail("fail", "");
    //------------------------------------------------------------
    // errorPass error.ExpectedError
    //------------------------------------------------------------
    try ut.errorPass("errorPass error.ExpectedError", error.ExpectedError);
    //------------------------------------------------------------
    // errorFail error.UnexpectedError
    //------------------------------------------------------------
    try ut.errorFail("errorFail error.UnexpectedError", error.UnexpectedError);
    //------------------------------------------------------------
    // errorExpectedFail error.ExpectedError
    //------------------------------------------------------------
    try ut.errorExpectedFail("errorExpectedFail error.ExpectedError", error.ExpectedError);
    //------------------------------------------------------------
    //############################################################
    //------------------------------------------------------------
    try ut.printSummary();
    //------------------------------------------------------------
    //############################################################
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------

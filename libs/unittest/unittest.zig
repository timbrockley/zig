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
const SourceLocationDefaults = struct { src: std.builtin.SourceLocation = .{
    .module = "",
    .file = "",
    .fn_name = "",
    .line = 0,
    .column = 0,
} };
//------------------------------------------------------------
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
pub fn compareStringResultError(self: *Self, name: []const u8, result_error: anyerror![]const u8, expected_result: []const u8, expected_error: ?anyerror, options: anytype) !void {
    //------------------------------------------------------------
    var fail_count: usize = 0;
    //------------------------------------------------------------
    if (result_error) |result| {
        //----------------------------------------
        if (expected_error != null) {
            //----------------------------------------
            fail_count += 1;
            try self.errorExpectedFail(name, expected_error.?, options);
            //----------------------------------------
        } else {
            //----------------------------------------
            if (!std.mem.eql(u8, result, expected_result)) {
                //----------------------------------------
                fail_count += 1;
                //----------------------------------------
                try self.compareStringSlice(name, result, expected_result, options);
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
                try self.compareError(name, err, expected_error.?, options);
                //----------------------------------------
            }
            //----------------------------------------
        } else {
            //----------------------------------------
            fail_count += 1;
            try self.errorFail(name, err, options);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    if (fail_count == 0) try self.pass(name, "", options);
    //------------------------------------------------------------
    return;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn compareType(
    self: *Self,
    name: []const u8,
    actual: type,
    expected: type,
    options: anytype,
) !void {
    //------------------------------------------------------------
    if (actual == expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(": {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {s}\n", .{@typeName(actual)});
        try self.printExpected();
        try self.stdout_print(": {s}\n", .{@typeName(expected)});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareStringSlice(self: *Self, name: []const u8, actual: []const u8, expected: []const u8, options: anytype) !void {
    //------------------------------------------------------------
    if (std.mem.eql(u8, actual, expected)) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {s}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {s}\n", .{expected});
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
pub fn compareCString(self: *Self, name: []const u8, actual: ?[*:0]const u8, expected: [*:0]const u8, options: anytype) !void {
    //------------------------------------------------------------
    if (actual == null) return self.compareStringSlice(name, "", std.mem.span(expected), options);
    //------------------------------------------------------------
    return self.compareStringSlice(name, std.mem.span(actual.?), std.mem.span(expected), options);
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
pub fn compareStringFormat(self: *Self, name: []const u8, string: []const u8, format: []const u8, options: anytype) !void {
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
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //------------------------------------------------------------
    } else {
        //------------------------------------------------------------
        try self.printFail(options);
        try self.stdout_print(": {s}\n", .{name});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareByteSlice(self: *Self, name: []const u8, actual: []const u8, expected: []const u8, options: anytype) !void {
    //------------------------------------------------------------
    if (std.mem.eql(u8, actual, expected)) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {any}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {any}\n", .{expected});
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
pub fn compareByte(self: *Self, name: []const u8, actual: u8, expected: u8, options: anytype) !void {
    //------------------------------------------------------------
    if (actual == expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {d}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {d}\n", .{expected});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn compareInteger(self: *Self, name: []const u8, actual: anytype, expected: anytype, options: anytype) !void {
    //------------------------------------------------------------
    comptime {
        if (!isInteger(@TypeOf(actual))) @compileError("actual must be an integer");
        if (!isInteger(@TypeOf(expected))) @compileError("expected must be an integer");
    }
    //------------------------------------------------------------
    const _actual: i128 = @intCast(actual);
    const _expected: i128 = @intCast(expected);
    //------------------------------------------------------------
    if (_actual == _expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {d}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {d}\n", .{expected});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn compareFloat(self: *Self, name: []const u8, actual: f64, expected: f64, options: anytype) !void {
    //------------------------------------------------------------
    if (actual == expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {d}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {d}\n", .{expected});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn compareBool(self: *Self, name: []const u8, actual: bool, expected: bool, options: anytype) !void {
    //----------------------------------------------------------------------------
    if (actual == expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {}\n", .{actual});
        try self.printExpected();
        try self.stdout_print(": {}\n", .{expected});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareNull(self: *Self, name: []const u8, actual: anytype, options: anytype) !void {
    //----------------------------------------------------------------------------
    const T = @TypeOf(actual);
    //----------------------------------------------------------------------------
    const is_optional = switch (@typeInfo(T)) {
        .null => true,
        .optional => true,
        else => false,
    };
    //----------------------------------------------------------------------------
    if (is_optional) {
        if (actual == null) {
            try self.printPass(options);
            self.count_passed += 1;
        } else {
            try self.printFail(options);
            self.count_failed += 1;
        }
    } else {
        try self.printFail(options);
        self.count_failed += 1;
    }
    //----------------------------------------------------------------------------
    try self.stdout_print(": {s}\n", .{name});
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareEnum(self: *Self, name: []const u8, actual: anytype, expected: @TypeOf(actual), options: anytype) !void {
    //------------------------------------------------------------
    if (actual == expected) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(": {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   .{s}\n", .{@tagName(actual)});
        try self.printExpected();
        try self.stdout_print(": .{s}\n", .{@tagName(expected)});
        //----------------------------------------
        self.count_failed += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareError(self: *Self, name: []const u8, actual_error: anyerror, expected_error: anyerror, options: anytype) !void {
    //----------------------------------------------------------------------------
    if (actual_error == expected_error) {
        //----------------------------------------
        try self.printPass(options);
        try self.stdout_print(": {s}\n", .{name});
        //----------------------------------------
        self.count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        try self.printFailDetailed(options);
        try self.stdout_print(":     {s}\n", .{name});
        try self.printActual();
        try self.stdout_print(":   {}\n", .{actual_error});
        try self.printExpected();
        try self.stdout_print(": {}\n", .{expected_error});
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
pub fn pass(self: *Self, name: []const u8, message: []const u8, options: anytype) !void {
    //----------------------------------------------------------------------------
    try self.printPass(options);
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
pub fn fail(self: *Self, name: []const u8, message: []const u8, options: anytype) !void {
    //----------------------------------------------------------------------------
    try self.printFail(options);
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
pub fn errorPass(self: *Self, name: []const u8, err: anyerror, options: anytype) !void {
    //----------------------------------------------------------------------------
    try self.printPass(options);
    //----------------------------------------
    try self.stdout_print(": {s} (correctly returned: {})\n", .{ name, err });
    //----------------------------------------
    self.count_passed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorFail(self: *Self, name: []const u8, err: anyerror, options: anytype) !void {
    //----------------------------------------------------------------------------
    try self.printFail(options);
    //----------------------------------------
    try self.stdout_print(": {s}: (incorrectly returned: {})\n", .{ name, err });
    //----------------------------------------
    self.count_failed += 1;
    //----------------------------------------------------------------------------
    try self.printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorExpectedFail(self: *Self, name: []const u8, expected_error: anyerror, options: anytype) !void {
    //----------------------------------------------------------------------------
    try self.printFail(options);
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
pub fn printActual(self: *Self) !void {
    try self.printColour(BLUE, "ACTUAL");
}
pub fn printExpected(self: *Self) !void {
    try self.printColour(MAGENTA, "EXPECTED");
}
pub fn printPass(self: *Self, options: anytype) !void {
    const opts = setOptions(SourceLocationDefaults, options);
    if (opts.src.line > 0) try self.stdout_print("({d}) ", .{opts.src.line});
    try self.printColour(GREEN, "PASS");
}
pub fn printFail(self: *Self, options: anytype) !void {
    const opts = setOptions(SourceLocationDefaults, options);
    if (opts.src.line > 0) try self.stdout_print("({d}) ", .{opts.src.line});
    try self.printColour(RED, "FAIL");
}
pub fn printFailDetailed(self: *Self, options: anytype) !void {
    const opts = setOptions(SourceLocationDefaults, options);
    if (opts.src.line > 0) try self.stdout_print("({d}) [{s}]\n", .{ opts.src.line, opts.src.file });
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
//------------------------------------------------------------
pub fn isInteger(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .int, .comptime_int => true,
        else => false,
    };
}
//--------------------------------------------------------------------------------
pub fn setOptions(T: type, options: anytype) T {
    var target = T{};
    inline for (std.meta.fields(@TypeOf(target))) |field| {
        if (@hasField(@TypeOf(options), field.name)) {
            @field(target, field.name) = @field(options, field.name);
        }
    }
    return target;
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
    // compareStringResultError expected_result - should pass
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError expected_result", "expected_result", "expected_result", null, .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringResultError invalid_result - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError invalid_result", "invalid_result", "expected_result", null, .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringResultError error.ExpectedError - should pass
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError error.ExpectedError", error.ExpectedError, "", error.ExpectedError, .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringResultError error.UnexpectedError - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("compareStringResultError error.UnexpectedError", error.UnexpectedError, "", null, .{ .src = @src() });
    //------------------------------------------------------------
    // compareType pass
    //------------------------------------------------------------
    try ut.compareType("compareType pass", i64, i64, .{ .src = @src() });
    //------------------------------------------------------------
    // compareType fail
    //------------------------------------------------------------
    try ut.compareType("compareType fail", i32, i64, .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringSlice pass
    //------------------------------------------------------------
    try ut.compareStringSlice("compareStringSlice pass", "foo", "foo", .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringSlice fail
    //------------------------------------------------------------
    try ut.compareStringSlice("compareStringSlice fail", "bar", "foo", .{ .src = @src() });
    //------------------------------------------------------------
    // compareCString pass
    //------------------------------------------------------------
    try ut.compareCString("compareCString pass", "foo", "foo", .{ .src = @src() });
    try ut.compareCString("compareCString pass", null, "", .{ .src = @src() });
    //------------------------------------------------------------
    // compareCString fail
    //------------------------------------------------------------
    try ut.compareCString("compareCString fail", "bar", "foo", .{ .src = @src() });
    try ut.compareCString("compareCString fail", null, "foo", .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringFormat pass
    //------------------------------------------------------------
    try ut.compareStringFormat("compareStringFormat pass", "2026-03-19T10:13:00.072978925Z", "dddd-dd-ddTdd:dd:dd.dddddddddZ", .{ .src = @src() });
    //------------------------------------------------------------
    // compareStringFormat fail
    //------------------------------------------------------------
    try ut.compareStringFormat("compareStringFormat fail", "2026-03-19T10:13:00.072978925Z", "", .{ .src = @src() });
    //------------------------------------------------------------
    // compareByteSlice pass
    //------------------------------------------------------------
    try ut.compareByteSlice("compareByteSlice pass", "hello", "hello", .{ .src = @src() });
    //------------------------------------------------------------
    // compareByteSlice fail
    //------------------------------------------------------------
    try ut.compareByteSlice("compareByteSlice fail", "goodbye", "hello", .{ .src = @src() });
    //------------------------------------------------------------
    // compareByte pass
    //------------------------------------------------------------
    try ut.compareByte("compareByte pass", 42, 42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareByte fail
    //------------------------------------------------------------
    try ut.compareByte("compareByte fail", 0, 42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareInteger pass
    //------------------------------------------------------------
    try ut.compareInteger("compareInteger pass", 42, 42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareInteger fail
    //------------------------------------------------------------
    try ut.compareInteger("compareInteger fail", 0, 42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareFloat pass
    //------------------------------------------------------------
    try ut.compareFloat("compareFloat pass", 42.42, 42.42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareFloat fail
    //------------------------------------------------------------
    try ut.compareFloat("compareFloat fail", 0, 42.42, .{ .src = @src() });
    //------------------------------------------------------------
    // compareBool pass
    //------------------------------------------------------------
    try ut.compareBool("compareBool pass", true, true, .{ .src = @src() });
    //------------------------------------------------------------
    // compareBool fail
    //------------------------------------------------------------
    try ut.compareBool("compareBool fail", false, true, .{ .src = @src() });
    //------------------------------------------------------------
    // compareNull pass
    //------------------------------------------------------------
    try ut.compareNull("compareNull pass", null, .{ .src = @src() });
    try ut.compareNull("compareNull pass", @as(?bool, null), .{ .src = @src() });
    //------------------------------------------------------------
    // compareNull fail
    //------------------------------------------------------------
    try ut.compareNull("compareNull fail", false, .{ .src = @src() });
    try ut.compareNull("compareNull fail", @as(?bool, false), .{ .src = @src() });
    //------------------------------------------------------------
    // compareEnum
    //------------------------------------------------------------
    const testEnum = enum { enum1, enum2 };
    //------------------------------------------------------------
    // compareEnum pass
    //------------------------------------------------------------
    try ut.compareEnum("compareEnum pass", testEnum.enum1, testEnum.enum1, .{ .src = @src() });
    //------------------------------------------------------------
    // compareEnum fail
    //------------------------------------------------------------
    try ut.compareEnum("compareEnum fail", testEnum.enum2, testEnum.enum1, .{ .src = @src() });
    //------------------------------------------------------------
    // compareError pass
    //------------------------------------------------------------
    try ut.compareError("compareError ExpectError", error.ExpectError, error.ExpectError, .{ .src = @src() });
    //------------------------------------------------------------
    // compareError fail
    //------------------------------------------------------------
    try ut.compareError("compareError InvalidError", error.InvalidError, error.ExpectError, .{ .src = @src() });
    //------------------------------------------------------------
    // pass
    //------------------------------------------------------------
    try ut.pass("pass", "", .{ .src = @src() });
    //------------------------------------------------------------
    // fail
    //------------------------------------------------------------
    try ut.fail("fail", "", .{ .src = @src() });
    //------------------------------------------------------------
    // errorPass error.ExpectedError
    //------------------------------------------------------------
    try ut.errorPass("errorPass error.ExpectedError", error.ExpectedError, .{ .src = @src() });
    //------------------------------------------------------------
    // errorFail error.UnexpectedError
    //------------------------------------------------------------
    try ut.errorFail("errorFail error.UnexpectedError", error.UnexpectedError, .{ .src = @src() });
    //------------------------------------------------------------
    // errorExpectedFail error.ExpectedError
    //------------------------------------------------------------
    try ut.errorExpectedFail("errorExpectedFail error.ExpectedError", error.ExpectedError, .{ .src = @src() });
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

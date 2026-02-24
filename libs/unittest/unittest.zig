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
//------------------------------------------------------------
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
//------------------------------------------------------------
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
//------------------------------------------------------------
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
    var ut = try init(.{ .io = processInit.io });
    //------------------------------------------------------------
    // test case 1: compareStringResultError - should pass
    //------------------------------------------------------------
    try ut.compareStringResultError("test case 1: compareStringResultError - should pass", "expected_result", "expected_result", null);
    //------------------------------------------------------------
    // test case 2: compareStringResultError - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("test case 2: compareStringResultError - should fail", "expected_result", "invalid_result", null);
    //------------------------------------------------------------
    // test case 3: compareStringResultError - should pass
    //------------------------------------------------------------
    try ut.compareStringResultError("test case 3: compareStringResultError - should pass", error.ExpectedError, "", error.ExpectedError);
    //------------------------------------------------------------
    // test case 4: compareStringResultError - should fail
    //------------------------------------------------------------
    try ut.compareStringResultError("test case 4: compareStringResultError - should fail", error.UnexpectedError, "", null);
    //------------------------------------------------------------
    // test case 5: compareStringSlice - should pass
    //------------------------------------------------------------
    try ut.compareStringSlice("test case 5 should pass", "foo", "foo");
    //------------------------------------------------------------
    // test case 6: compareStringSlice - should fail
    //------------------------------------------------------------
    try ut.compareStringSlice("test case 6 should fail", "foo", "bar");
    //------------------------------------------------------------
    // test case 7: compareByteSlice - should pass
    //------------------------------------------------------------
    try ut.compareByteSlice("test case 7 should pass", "hello", "hello");
    //------------------------------------------------------------
    // test case 8: compareByteSlice - should fail
    //------------------------------------------------------------
    try ut.compareByteSlice("test case 8 should fail", "hello", "world");
    //------------------------------------------------------------
    // test case 9: compareByte - should pass
    //------------------------------------------------------------
    try ut.compareByte("test case 9 should pass", 0, 0);
    //------------------------------------------------------------
    // test case 10: compareByte - should fail
    //------------------------------------------------------------
    try ut.compareByte("test case 10 should fail", 0, 1);
    //------------------------------------------------------------
    // test case 11: compareInt - should pass
    //------------------------------------------------------------
    try ut.compareInt("test case 11 should pass", 0, 0);
    //------------------------------------------------------------
    // test case 12: compareInt - should fail
    //------------------------------------------------------------
    try ut.compareInt("test case 12 should fail", 0, 1);
    //------------------------------------------------------------
    // test case 13: compareBool - should pass
    //------------------------------------------------------------
    try ut.compareBool("test case 13 should pass", true, true);
    //------------------------------------------------------------
    // test case 14: compareBool - should fail
    //------------------------------------------------------------
    try ut.compareBool("test case 14 should fail", true, false);
    //------------------------------------------------------------
    // test case 15: compareError - should pass
    //------------------------------------------------------------
    try ut.compareError("test case 15 should pass", error.ExpectError, error.ExpectError);
    //------------------------------------------------------------
    // test case 16: compareError - should fail
    //------------------------------------------------------------
    try ut.compareError("test case 16 should fail", error.ExpectError, error.InvalidError);
    //------------------------------------------------------------
    // test case 17: pass - should pass
    //------------------------------------------------------------
    try ut.pass("test case 17 should pass", "");
    //------------------------------------------------------------
    // test case 18: fail - should fail
    //------------------------------------------------------------
    try ut.fail("test case 18 should fail", "");
    //------------------------------------------------------------
    // test case 19: errorPass - should pass
    //------------------------------------------------------------
    try ut.errorPass("test case 19 should pass", error.ExpectedError);
    //------------------------------------------------------------
    // test case 20: errorFail - should fail
    //------------------------------------------------------------
    try ut.errorFail("test case 20 should fail", error.UnexpectedError);
    //------------------------------------------------------------
    // test case 21: errorExpectedFail - should fail
    //------------------------------------------------------------
    try ut.errorExpectedFail("test case 21 should fail", error.ExpectedError);
    //------------------------------------------------------------
    try ut.printSummary();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------

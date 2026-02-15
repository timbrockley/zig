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
const RED = "\x1B[91m";
const GREEN = "\x1B[92m";
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
//------------------------------------------------------------
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
pub fn pass(self: *Self, name: []const u8, message: []const u8) !void {
    //------------------------------------------------------------
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
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn fail(self: *Self, name: []const u8, message: []const u8) !void {
    //------------------------------------------------------------
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
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn errorPass(self: *Self, name: []const u8, err: anyerror) !void {
    //------------------------------------------------------------
    try self.stderr_writeAll(GREEN);
    try self.stdout_writeAll("PASS");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    try self.stdout_print(": {s} (correctly returned {})\n", .{ name, err });
    //----------------------------------------
    self.count_passed += 1;
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn errorFail(self: *Self, name: []const u8, err: anyerror) !void {
    //------------------------------------------------------------
    try self.stderr_writeAll(RED);
    try self.stdout_writeAll("FAIL");
    try self.stderr_writeAll(RESET);
    //----------------------------------------
    try self.stdout_print(": {s}: ERROR: {}\n", .{ name, err });
    //----------------------------------------
    self.count_failed += 1;
    //------------------------------------------------------------
    try self.printLine();
    //------------------------------------------------------------
}
//------------------------------------------------------------
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
pub fn printColour(self: *Self, comptime colour: []const u8, comptime string: []const u8) !void {
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
//------------------------------------------------------------
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
pub fn stdout_writeAll(self: *Self, comptime bytes: []const u8) !void {
    if (self.stdout_writer == null) return error.InvalidStdOut;
    try self.stdout_writer.?.interface.writeAll(bytes);
}
//------------------------------------------------------------
pub fn stderr_print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
    if (self.stderr_writer == null) return error.InvalidStdErr;
    try self.stderr_writer.?.interface.print(fmt, args);
}
//------------------------------------------------------------
pub fn stderr_writeAll(self: *Self, comptime bytes: []const u8) !void {
    if (self.stderr_writer == null) return error.InvalidStdErr;
    try self.stderr_writer.?.interface.writeAll(bytes);
}
//--------------------------------------------------------------------------------
pub fn main(processInit: std.process.Init) !void {
    //------------------------------------------------------------
    var ut = try init(.{ .io = processInit.io });
    //------------------------------------------------------------
    // test case 1: compareStringSlice - should pass
    //----------------------------------------
    const expected_string = "foo";
    const actual_string_pass = "foo";
    //----------------------------------------
    try ut.compareStringSlice("test case 1 should pass", expected_string, actual_string_pass);
    //----------------------------------------------------------------------------
    // test case 2: compareStringSlice - should fail
    //----------------------------------------
    const actual_string_fail = "bar";
    //----------------------------------------
    try ut.compareStringSlice("test case 2 should fail", expected_string, actual_string_fail);
    //----------------------------------------------------------------------------
    // test case 3: compareByteSlice - should pass
    //----------------------------------------
    const expected_bytes = "hello";
    const actual_bytes_pass = "hello";
    //----------------------------------------
    try ut.compareByteSlice("test case 3 should pass", expected_bytes, actual_bytes_pass);
    //----------------------------------------------------------------------------
    // test case 4: compareByteSlice - should fail
    //----------------------------------------
    const actual_bytes_fail = "world";
    //----------------------------------------
    try ut.compareByteSlice("test case 4 should fail", expected_bytes, actual_bytes_fail);
    //----------------------------------------------------------------------------
    // test case 5: compareByte - should pass
    //----------------------------------------
    const expected_byte = 0;
    const actual_byte_pass = 0;
    //----------------------------------------
    try ut.compareByte("test case 5 should pass", expected_byte, actual_byte_pass);
    //----------------------------------------------------------------------------
    // test case 6: compareByte - should fail
    //----------------------------------------
    const actual_byte_fail = 1;
    //----------------------------------------
    try ut.compareByte("test case 6 should fail", expected_byte, actual_byte_fail);
    //----------------------------------------------------------------------------
    // test case 7: compareInt - should pass
    //----------------------------------------
    const expected_int = 0;
    const actual_int_pass = 0;
    //----------------------------------------
    try ut.compareInt("test case 7 should pass", expected_int, actual_int_pass);
    //----------------------------------------------------------------------------
    // test case 8: compareInt - should fail
    //----------------------------------------
    const actual_int_fail = 1;
    //----------------------------------------
    try ut.compareInt("test case 8 should fail", expected_int, actual_int_fail);
    //----------------------------------------------------------------------------
    try ut.printSummary();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------

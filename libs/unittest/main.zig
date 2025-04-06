//--------------------------------------------------------------------------------
// Unit Test Library
// Copyright 2024, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
//--------------------------------------------------------------------------------
var start_time_ns: i128 = 0;
//--------------------------------------------------------------------------------
var count_passed: usize = 0;
var count_failed: usize = 0;
//--------------------------------------------------------------------------------
const BLUE = "\x1B[34m";
const MAGENTA = "\x1B[35m";
const RED = "\x1B[91m";
const GREEN = "\x1B[92m";
const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
pub fn init() void {
    //----------------------------------------------------------------------------
    start_time_ns = std.time.nanoTimestamp();
    // start_time_ms = std.time.milliTimestamp();
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareByteSlice(name: []const u8, expected: []const u8, actual: []const u8) void {
    //----------------------------------------------------------------------------
    if (std.mem.eql(u8, expected, actual)) {
        //----------------------------------------
        printPass();
        stdout.print(": {s}\n", .{name}) catch {};
        //----------------------------------------
        count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        printFail();
        stdout.print(":   {s}\n", .{name}) catch {};
        printExpected();
        stdout.print(": {any}\n", .{expected}) catch {};
        printActual();
        stdout.print(":   {any}\n", .{actual}) catch {};
        //----------------------------------------
        count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareStringSlice(name: []const u8, expected: []const u8, actual: []const u8) void {
    //----------------------------------------------------------------------------
    if (std.mem.eql(u8, expected, actual)) {
        //----------------------------------------
        printPass();
        stdout.print(": {s}\n", .{name}) catch {};
        //----------------------------------------
        count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        printFail();
        stdout.print(":   {s}\n", .{name}) catch {};
        printExpected();
        stdout.print(": {s}\n", .{expected}) catch {};
        printActual();
        stdout.print(":   {s}\n", .{actual}) catch {};
        //----------------------------------------
        count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn compareInt(name: []const u8, expected: u64, actual: u64) void {
    //----------------------------------------------------------------------------
    if (expected == actual) {
        //----------------------------------------
        printPass();
        stdout.print(": {s}\n", .{name}) catch {};
        //----------------------------------------
        count_passed += 1;
        //----------------------------------------
    } else {
        //----------------------------------------
        printFail();
        stdout.print(":   {s}\n", .{name}) catch {};
        printExpected();
        stdout.print(": {d}\n", .{expected}) catch {};
        printActual();
        stdout.print(":   {d}\n", .{actual}) catch {};
        //----------------------------------------
        count_failed += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn pass(name: []const u8, message: []const u8) void {
    //----------------------------------------------------------------------------
    stderr.write(GREEN) catch {};
    stdout.write("PASS") catch {};
    stderr.write(RESET) catch {};
    stdout.print(": {s}: {s}\n", .{ name, message }) catch {};
    //----------------------------------------
    count_passed += 1;
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn fail(name: []const u8, message: []const u8) void {
    //----------------------------------------------------------------------------
    _ = stderr.write(RED) catch {};
    _ = stdout.write("FAIL") catch {};
    _ = stderr.write(RESET) catch {};
    stdout.print(": {s}: {s}\n", .{ name, message }) catch {};
    //----------------------------------------
    count_failed += 1;
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorPass(name: []const u8, err: anyerror) void {
    //----------------------------------------------------------------------------
    _ = stderr.write(GREEN) catch {};
    _ = stdout.write("PASS") catch {};
    _ = stderr.write(RESET) catch {};
    stdout.print(": {s} (correctly returned {})\n", .{ name, err }) catch {};
    //----------------------------------------
    count_passed += 1;
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn errorFail(name: []const u8, err: anyerror) void {
    //----------------------------------------------------------------------------
    _ = stderr.write(RED) catch {};
    _ = stdout.write("FAIL") catch {};
    _ = stderr.write(RESET) catch {};
    stdout.print(": {s}: ERROR: {}\n", .{ name, err }) catch {};
    //----------------------------------------
    count_failed += 1;
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn printExpected() void {
    printColour(BLUE, "EXPECTED");
}
pub fn printActual() void {
    printColour(MAGENTA, "ACTUAL");
}
pub fn printPass() void {
    printColour(GREEN, "PASS");
}
pub fn printFail() void {
    printColour(RED, "FAIL");
}
pub fn printColour(color: []const u8, string: []const u8) void {
    _ = stderr.write(color) catch {};
    _ = stdout.write(string) catch {};
    _ = stderr.write(RESET) catch {};
}
//--------------------------------------------------------------------------------
pub fn printLine() void {
    stdout.print("{s}\n", .{"-" ** 80}) catch {};
}
//--------------------------------------------------------------------------------
pub fn printSummary() void {
    //----------------------------------------------------------------------------
    stdout.print("PASSED = {d}", .{count_passed}) catch {};
    //----------------------------------------------------------------------------
    if (count_failed > 0) {
        stdout.print(" / FAILED = {d}", .{count_failed}) catch {};
    }
    //----------------------------------------------------------------------------
    if (start_time_ns > 0) {
        //-----------------------------------
        const duration_ns = std.time.nanoTimestamp() - start_time_ns;
        const duration_ms: f64 = @as(f64, @floatFromInt(duration_ns)) / 1_000_000;
        //-----------------------------------
        stdout.print(" ({d} ms)", .{duration_ms}) catch {};
        //-----------------------------------
    }
    //----------------------------------------------------------------------------
    stdout.print("\n", .{}) catch {};
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn main() void {
    //----------------------------------------------------------------------------
    printLine();
    //----------------------------------------------------------------------------
    // test case 1: compareByteSlice - should pass
    const expected_bytes = "hello";
    //----------------------------------------
    const actual_bytes_pass = "hello";
    compareByteSlice("test case 1 should pass", expected_bytes, actual_bytes_pass);
    //----------------------------------------
    // test case 2: compareByteSlice - should fail
    const actual_bytes_fail = "world";
    compareByteSlice("test case 2 should fail", expected_bytes, actual_bytes_fail);
    //----------------------------------------------------------------------------
    // test case 3: compareStringSlice - should pass
    const expected_string = "foo";
    //----------------------------------------
    const actual_string_pass = "foo";
    compareStringSlice("test case 3 should pass", expected_string, actual_string_pass);
    //----------------------------------------
    // test case 4: compareStringSlice - should fail
    const actual_string_fail = "bar";
    compareStringSlice("test case 4 should fail", expected_string, actual_string_fail);
    //----------------------------------------------------------------------------
    printSummary();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------

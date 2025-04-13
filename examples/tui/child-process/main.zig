//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

const MAX_OUTPUT_BYTES: usize = 50 * 1024;

//--------------------------------------------------------------------------------

pub fn child_process(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    stdout: *std.ArrayListUnmanaged(u8),
    stderr: *std.ArrayListUnmanaged(u8),
    maxOutputBytes: usize,
) !u8 {
    //------------------------------------------------------------
    var child = std.process.Child.init(
        argv,
        allocator,
    );
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    //------------------------------------------------------------
    try child.spawn();
    try child.collectOutput(
        allocator,
        stdout,
        stderr,
        maxOutputBytes,
    );
    //------------------------------------------------------------
    const term = try child.wait();
    return term.Exited;
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------

pub const ChildProcess = struct {
    exitCode: u8,
    stdOutput: []const u8,
    stdError: []const u8,
};

pub fn child_process_owned(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    maxOutputBytes: usize,
) !ChildProcess {
    //------------------------------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    var child = std.process.Child.init(
        argv,
        allocator,
    );
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    //------------------------------------------------------------
    try child.spawn();
    try child.collectOutput(
        allocator,
        &stdout,
        &stderr,
        maxOutputBytes,
    );
    const term = try child.wait();
    //------------------------------------------------------------
    return ChildProcess{
        .exitCode = term.Exited,
        .stdOutput = try stdout.toOwnedSlice(allocator),
        .stdError = try stderr.toOwnedSlice(allocator),
    };
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena_allocator.deinit();
    const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    var stdout = std.ArrayListUnmanaged(u8){};
    var stderr = std.ArrayListUnmanaged(u8){};
    defer stdout.deinit(allocator);
    defer stderr.deinit(allocator);
    //------------------------------------------------------------
    const exitCode = child_process(
        allocator,
        &[_][]const u8{
            "ls",
            "",
        },
        &stdout,
        &stderr,
        MAX_OUTPUT_BYTES,
    ) catch |err| {
        std.debug.print("process error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    //------------------------------------------------------------
    std.debug.print("exit code: {d}\n", .{exitCode});
    std.debug.print("stdout: {s}\n", .{stdout.items});
    std.debug.print("stderr: {s}\n", .{stderr.items});
    //------------------------------------------------------------
    const process2 = child_process_owned(
        allocator,
        &[_][]const u8{
            "printf",
            "printf test 2",
        },
        MAX_OUTPUT_BYTES,
    ) catch |err| {
        std.debug.print("process error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    //------------------------------------------------------------
    std.debug.print("exit code: {d}\n", .{process2.exitCode});
    std.debug.print("stdout: {s}\n", .{process2.stdOutput});
    std.debug.print("stderr: {s}\n", .{process2.stdError});
    //------------------------------------------------------------
}

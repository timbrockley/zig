//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

const MAX_OUTPUT_BYTES: usize = 50 * 1024;

//--------------------------------------------------------------------------------

pub fn child_process_pre_allocated(
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
    switch (term) {
        .Exited => return term.Exited,
        else => return 1,
    }
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------
pub const ChildProcessReturnValues = struct {
    exitCode: u8 = 0,
    stdOutput: []const u8 = &[_]u8{},
    stdError: []const u8 = &[_]u8{},
    err: ?anyerror = null,
};
//--------------------------------------------------------------------------------
pub fn child_process_owned_slice(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    maxOutputBytes: usize,
) ChildProcessReturnValues {
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
    child.spawn() catch |err| return ChildProcessReturnValues{ .exitCode = 1, .err = err };

    child.collectOutput(
        allocator,
        &stdout,
        &stderr,
        maxOutputBytes,
    ) catch |err| return ChildProcessReturnValues{ .exitCode = 1, .err = err };

    const term = child.wait() catch |err| return ChildProcessReturnValues{ .exitCode = 1, .err = err };
    //------------------------------------------------------------
    const exitCode = switch (term) {
        .Exited => term.Exited,
        else => 1,
    };
    //------------------------------------------------------------
    const stdOutput = stdout.toOwnedSlice(allocator) catch |err| return ChildProcessReturnValues{ .exitCode = 1, .err = err };
    errdefer allocator.free(stdOutput);
    //------------------------------------------------------------
    const stdError = stderr.toOwnedSlice(allocator) catch |err| return ChildProcessReturnValues{ .exitCode = 1, .err = err };
    //------------------------------------------------------------
    return ChildProcessReturnValues{
        .exitCode = exitCode,
        .stdOutput = stdOutput,
        .stdError = stdError,
        .err = null,
    };
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    // var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer _ = arena_allocator.deinit();
    // const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stdout = std.ArrayListUnmanaged(u8){};
        var stderr = std.ArrayListUnmanaged(u8){};
        defer stdout.deinit(allocator);
        defer stderr.deinit(allocator);
        //------------------------------------------------------------
        const exitCode = child_process_pre_allocated(
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
    }
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        const process2 = child_process_owned_slice(
            allocator,
            &[_][]const u8{
                "printf",
                "printf test 2",
            },
            MAX_OUTPUT_BYTES,
        );
        //------------------------------------------------------------
        defer allocator.free(process2.stdOutput);
        defer allocator.free(process2.stdError);
        //------------------------------------------------------------
        std.debug.print("exit code: {d}\n", .{process2.exitCode});
        std.debug.print("stdout: {s}\n", .{process2.stdOutput});
        std.debug.print("stderr: {s}\n", .{process2.stdError});
        std.debug.print("err: {?}\n", .{process2.err});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}

const std = @import("std");

pub fn main() !void {
    //--------------------------------------------------------------------------------
    // debug only
    std.debug.print("stderr: Hello World (debug)\n", .{});
    //--------------------------------------------------------------------------------
    // stderr
    const stderr = std.io.getStdErr().writer();
    try stderr.print("stderr: Hello World\n", .{});
    //--------------------------------------------------------------------------------
    // stderr buffered
    const stderr_file = std.io.getStdErr().writer();
    //----------------------------------------
    var stderr_bw = std.io.bufferedWriter(stderr_file);
    const stderr_buffered = stderr_bw.writer();
    //----------------------------------------
    try stderr_buffered.print("stderr: Hello World (buffered)\n", .{});
    //----------------------------------------
    try stderr_bw.flush();
    //--------------------------------------------------------------------------------
    // stdout
    const stdout = std.io.getStdOut().writer();
    try stdout.print("stdout: Hello World\n", .{});
    //--------------------------------------------------------------------------------
    // stdout buffered
    const stdout_file = std.io.getStdOut().writer();
    //----------------------------------------
    var stdout_bw = std.io.bufferedWriter(stdout_file);
    const stdout_buffered = stdout_bw.writer();
    //----------------------------------------
    try stdout_buffered.print("stdout: Hello World (buffered)\n", .{});
    //----------------------------------------
    try stdout_bw.flush();
    //--------------------------------------------------------------------------------
}

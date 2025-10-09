const std = @import("std");

pub fn main() !void {
    //------------------------------------------------------------
    // debug
    //------------------------------------------------------------

    std.debug.print("stderr: Hello World (debug)\n", .{});

    //------------------------------------------------------------
    // stderr
    //------------------------------------------------------------
    {
        // buffered

        var stderr_buffer: [1024]u8 = undefined;
        var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
        const stderr = &stderr_writer.interface;

        try stderr.print("stderr: Hello World (buffered)\n", .{});
        try stderr.flush();
    }
    //------------------------------------------------------------
    {
        // unbuffered

        var stderr_writer = std.fs.File.stderr().writer(&.{});
        const stderr = &stderr_writer.interface;

        try stderr.print("stderr: Hello World (unbuffered)\n", .{});
        try stderr.flush();
    }
    //------------------------------------------------------------
    // stdout
    //------------------------------------------------------------
    {
        // buffered

        var stdout_buffer: [1024]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
        const stdout = &stdout_writer.interface;

        try stdout.print("stdout: Hello World (buffered)\n", .{});
        try stdout.flush();
    }
    //------------------------------------------------------------
    {
        // unbuffered

        var stdout_writer = std.fs.File.stdout().writer(&.{});
        const stdout = &stdout_writer.interface;

        try stdout.print("stdout: Hello World (unbuffered)\n", .{});
        try stdout.flush();
    }
    //------------------------------------------------------------
}

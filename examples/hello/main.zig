const std = @import("std");

pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    // stdout
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        // unbuffered
        //------------------------------------------------------------
        try std.Io.File.stdout().writeStreamingAll(init.io, "stdout: Hello World - writeStreamingAll (unbuffered)\n");
        //------------------------------------------------------------
        // stdout().writerStreaming streaming (not positional)
        var stdout1 = std.Io.File.stdout().writerStreaming(init.io, &.{});
        try stdout1.interface.print("stdout: Hello World - print - streaming (unbuffered)\n", .{});
        try stdout1.interface.writeAll("stdout: Hello World - writeAll - streaming (unbuffered)\n");
        try stdout1.flush();
        //------------------------------------------------------------
        // stdout().writer uses positional syscall but falls back to streaming if that fails
        var stdout2 = std.Io.File.stdout().writer(init.io, &.{});
        try stdout2.interface.print("stdout: Hello World - print (unbuffered)\n", .{});
        try stdout2.interface.writeAll("stdout: Hello World - writeAll (unbuffered)\n");
        try stdout2.flush();
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // buffered
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        // stdout().writerStreaming streaming (not positional)
        var stdout_buffer1: [1024]u8 = undefined;
        var stdout1 = std.Io.File.stdout().writerStreaming(init.io, &stdout_buffer1);
        try stdout1.interface.print("stdout: Hello World - print - streaming (buffered)\n", .{});
        try stdout1.interface.writeAll("stdout: Hello World - writeAll - streaming (buffered)\n");
        try stdout1.flush();
        //------------------------------------------------------------
        // stdout().writer uses positional syscall but falls back to streaming if that fails
        var stdout_buffer2: [1024]u8 = undefined;
        var stdout2 = std.Io.File.stdout().writer(init.io, &stdout_buffer2);
        try stdout2.interface.print("stdout: Hello World - print (buffered)\n", .{});
        try stdout2.interface.writeAll("stdout: Hello World - writeAll (buffered)\n");
        try stdout2.flush();
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    // stderr
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        // unbuffered
        //------------------------------------------------------------
        try std.Io.File.stderr().writeStreamingAll(init.io, "stderr: Hello World - writeStreamingAll (unbuffered)\n");
        //------------------------------------------------------------
        // stderr().writerStreaming streaming (not positional)
        var stderr1 = std.Io.File.stderr().writerStreaming(init.io, &.{});
        try stderr1.interface.print("stderr: Hello World - print - streaming (unbuffered)\n", .{});
        try stderr1.interface.writeAll("stderr: Hello World - writeAll - streaming (unbuffered)\n");
        try stderr1.flush();
        //------------------------------------------------------------
        // stderr().writer uses positional syscall but falls back to streaming if that fails
        var stderr2 = std.Io.File.stderr().writer(init.io, &.{});
        try stderr2.interface.print("stderr: Hello World - print (unbuffered)\n", .{});
        try stderr2.interface.writeAll("stderr: Hello World - writeAll (unbuffered)\n");
        try stderr2.flush();
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // buffered
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        // stderr().writerStreaming streaming (not positional)
        var stderr_buffer1: [1024]u8 = undefined;
        var stderr1 = std.Io.File.stderr().writerStreaming(init.io, &stderr_buffer1);
        try stderr1.interface.print("stderr: Hello World - print - streaming (buffered)\n", .{});
        try stderr1.interface.writeAll("stderr: Hello World - writeAll - streaming (buffered)\n");
        try stderr1.flush();
        //------------------------------------------------------------
        // stderr().writer uses positional syscall but falls back to streaming if that fails
        var stderr_buffer2: [1024]u8 = undefined;
        var stderr2 = std.Io.File.stderr().writer(init.io, &stderr_buffer2);
        try stderr2.interface.print("stderr: Hello World - print (buffered)\n", .{});
        try stderr2.interface.writeAll("stderr: Hello World - writeAll (buffered)\n");
        try stderr2.flush();
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // debug
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        std.debug.print("stderr: Hello World (debug)\n", .{});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
}

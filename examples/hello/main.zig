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
        var stdout_writer = std.Io.File.Writer.init(.stdout(), init.io, &.{});
        const stdout_writer_interface = &stdout_writer.interface;
        //------------------------------------------------------------
        try stdout_writer_interface.print("stdout: Hello World - print (unbuffered)\n", .{});
        try stdout_writer_interface.writeAll("stdout: Hello World - writeAll (unbuffered)\n");
        //------------------------------------------------------------
        try std.Io.File.stdout().writeStreamingAll(init.io, "stdout: Hello World - writeStreamingAll (unbuffered)\n");
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // buffered
    //------------------------------------------------------------
    {
        var stdout_buffer: [1024]u8 = undefined;
        var stdout_file_writer = std.Io.File.Writer.init(.stdout(), init.io, &stdout_buffer);
        //------------------------------------------------------------
        const stdout_writer = &stdout_file_writer.interface;
        try stdout_writer.print("stdout: Hello World - print (buffered)\n", .{});
        try stdout_writer.flush();
        //------------------------------------------------------------
        try std.Io.Writer.writeAll(stdout_writer, "stdout: Hello World - writeAll(buffered)\n");
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    // stderr
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // unbuffered
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stderr_writer2 = std.Io.File.Writer.init(.stderr(), init.io, &.{});
        const stderr_writer2_interface = &stderr_writer2.interface;
        //------------------------------------------------------------
        try stderr_writer2_interface.print("stderr: Hello World - print (unbuffered)\n", .{});
        try stderr_writer2_interface.writeAll("stderr: Hello World - writeAll (unbuffered)\n");
        //------------------------------------------------------------
        try std.Io.File.stderr().writeStreamingAll(init.io, "stderr: Hello World - writeStreamingAll (unbuffered)\n");
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    // buffered
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stderr_buffer: [1024]u8 = undefined;
        var stderr_file_writer = std.Io.File.Writer.init(.stderr(), init.io, &stderr_buffer);
        const stderr_writer = &stderr_file_writer.interface;
        //------------------------------------------------------------
        try stderr_writer.print("stderr: Hello World - print (buffered)\n", .{});
        try stderr_writer.flush();
        //------------------------------------------------------------
        try stderr_writer.writeAll("stderr: Hello World - writeAll (buffered)\n");
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

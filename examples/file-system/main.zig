//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

pub const TEST_DIR = "test";
pub const TEST_DIR1 = "test/1";
pub const TEST_DIR2 = "test/1/2";
pub const TEST_DIR3 = "test/1/2/3";

// todo v0.16 changes => create / read file .list directory entries / change directory

pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const allocator = init.arena.allocator();
    //------------------------------------------------------------
    //
    // current working directory
    //
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    const cwd_handle = std.Io.Dir.cwd();
    const cwd_string = try cwd_handle.realPathFileAlloc(init.io, ".", allocator);
    std.debug.print("cwd: {s}\n", .{cwd_string});
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    //
    // delete file if exists
    //
    //------------------------------------------------------------
    if (std.Io.Dir.statFile(cwd_handle, init.io, TEST_DIR, .{})) |stat| {
        if (stat.kind == .file) {
            try std.Io.Dir.deleteFile(cwd_handle, init.io, TEST_DIR);
        }
    } else |_| {}
    //------------------------------------------------------------
    //
    // create directory
    //
    //------------------------------------------------------------
    std.Io.Dir.createDirPath(cwd_handle, init.io, TEST_DIR) catch |err| {
        if (err != error.PathAlreadyExists) {
            std.debug.print("createDirPath: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        }
    };
    std.debug.print("createDirPath: directory created\n", .{});
    //------------------------------------------------------------
    std.Io.Dir.createDirPath(cwd_handle, init.io, TEST_DIR2) catch |err| {
        std.debug.print("createDirPath: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    std.debug.print("createDirPath: directory created\n", .{});
    //------------------------------------------------------------
    //
    // directory / file exists
    //
    //------------------------------------------------------------
    const statExisting = std.Io.Dir.statFile(cwd_handle, init.io, TEST_DIR2, .{}) catch |err| {
        std.debug.print("statExisting: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    switch (statExisting.kind) {
        .directory => std.debug.print("statFile: directory exists\n", .{}),
        .file => std.debug.print("statFile: file exists\n", .{}),
        else => std.debug.print("statFile: exists, type: {s}\n", .{@tagName(statExisting.kind)}),
    }
    //------------------------------------------------------------
    if (std.Io.Dir.statFile(cwd_handle, init.io, TEST_DIR3, .{})) |statResult| {
        switch (statResult.kind) {
            .directory => std.debug.print("statFile: directory exists\n", .{}),
            .file => std.debug.print("statFile: file exists\n", .{}),
            else => std.debug.print("statFile: exists, type: {s}\n", .{@tagName(statResult.kind)}),
        }
    } else |err| {
        std.debug.print("statFile: {s}\n", .{@errorName(err)});
    }
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    //
    // create file
    //
    //------------------------------------------------------------
    {
        const file = std.Io.Dir.createFile(
            cwd_handle,
            init.io,
            "test.txt",
            .{
                .read = true,
                .truncate = true, // truncate file if it exists (overwrite)
            },
        ) catch |err| {
            std.debug.print("createFile: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        defer file.close(init.io);

        try file.writeStreamingAll(init.io, "zig createFile/writeStreamingAll test");

        const stat = try file.stat(init.io);
        const size = stat.size;

        // try file.see(0);

        // var buffer: [100]u8 = undefined;
        // const bytesRead = try file.readAll(&buffer);

        var buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);
        // var buffer: [4096]u8 = undefined;

        const bytesRead = try file.readStreaming(init.io, &buffer);

        std.debug.print("createFile: writeAll: size: {d}\n", .{size});
        std.debug.print("readAll: bytesRead: {d}\n", .{bytesRead});
        std.debug.print("readAll: fileContents: {s}\n", .{buffer[0..bytesRead]});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    //
    // read file
    //
    //------------------------------------------------------------
    // {
    //     const file = try std.fs.cwd().openFile("test.txt", .{});
    //     defer file.close();

    //     const stat = try file.stat();
    //     const size = stat.size;

    //     try file.seekTo(0);

    //     // var buffer: [100]u8 = undefined;
    //     // const bytesRead = try file.readAll(&buffer);

    //     var buffer = try allocator.alloc(u8, size);
    //     defer allocator.free(buffer);

    //     const bytesRead = try file.readAll(buffer);

    //     std.debug.print("openFile: size: {d}\n", .{size});
    //     std.debug.print("readAll: bytesRead: {d}\n", .{bytesRead});
    //     std.debug.print("readAll: fileContents: {s}\n", .{buffer[0..bytesRead]});
    //     std.debug.print("\n", .{});
    // }
    //------------------------------------------------------------
    //
    // list directory entries
    //
    //------------------------------------------------------------
    // {
    //     var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    //     defer dir.close();

    //     var dirIterator = dir.iterate();
    //     while (try dirIterator.next()) |dirContent| {
    //         std.debug.print("openDir: {}: {s}\n", .{ dirContent.kind, dirContent.name });
    //     }
    //     std.debug.print("\n", .{});
    // }
    //------------------------------------------------------------
}

//------------------------------------------------------------

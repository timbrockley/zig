//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

pub const TEST_DIR = "test";
pub const TEST_DIR1 = "test/1";
pub const TEST_DIR2 = "test/1/2";
pub const TEST_DIR3 = "test/1/2/3";

pub const FILENAME1 = "test1.txt";
pub const FILENAME2 = "test2.txt";

const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";

pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const io = init.io;
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    //
    // current working directory
    //
    //------------------------------------------------------------
    // Closing the returned `Dir` is checked illegal behavior.
    // Iterating over the result is illegal behavior.
    var dir = std.Io.Dir.cwd();
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    const dir_string = try dir.realPathFileAlloc(io, ".", allocator);
    defer allocator.free(dir_string);
    //------------------------------------------------------------
    std.debug.print("realPathFileAlloc: {s}\n", .{dir_string});
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    //
    // delete file if exists
    //
    //------------------------------------------------------------
    if (std.Io.Dir.statFile(dir, io, TEST_DIR, .{})) |stat| {
        if (stat.kind == .file) {
            try std.Io.Dir.deleteFile(dir, io, TEST_DIR);
        }
    } else |_| {}
    //------------------------------------------------------------
    //
    // create directory
    //
    //------------------------------------------------------------
    dir.createDirPath(io, TEST_DIR) catch |err| {
        if (err != error.PathAlreadyExists) {
            std.debug.print("createDirPath: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        }
    };
    std.debug.print("createDirPath: directory created\n", .{});
    //------------------------------------------------------------
    dir.createDirPath(io, TEST_DIR2) catch |err| {
        std.debug.print("createDirPath: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    std.debug.print("createDirPath: directory created\n", .{});
    //------------------------------------------------------------
    //
    // directory / file exists
    //
    //------------------------------------------------------------
    const statExisting = dir.statFile(io, TEST_DIR2, .{}) catch |err| {
        std.debug.print("statExisting: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    switch (statExisting.kind) {
        .directory => std.debug.print("statFile: directory exists\n", .{}),
        .file => std.debug.print("statFile: file exists\n", .{}),
        else => std.debug.print("statFile: exists, type: {s}\n", .{@tagName(statExisting.kind)}),
    }
    //------------------------------------------------------------
    if (dir.statFile(io, TEST_DIR3, .{})) |statResult| {
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
        const file = dir.createFile(io, FILENAME1, .{
            .read = true,
            .truncate = true, // truncate file if it exists (overwrite)
        }) catch |err| {
            std.debug.print("createFile: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        defer file.close(io);

        try file.writeStreamingAll(io, "zig createFile/writeStreamingAll test");

        const stat = try file.stat(io);
        const size = stat.size;

        std.debug.print("createFile: writeStreamingAll: size: {d}\n", .{size});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    //
    // read file
    //
    //------------------------------------------------------------
    {
        const file = try dir.openFile(io, FILENAME1, .{});
        defer file.close(io);

        const stat = try file.stat(io);

        var read_buffer: [1024]u8 = undefined;
        var file_reader = file.reader(io, &read_buffer);

        const data = try file_reader.interface.readAlloc(
            allocator,
            stat.size,
        );
        defer allocator.free(data);

        std.debug.print("openFile: stat.size: {d}\n", .{stat.size});
        std.debug.print("reader: toOwnedSlice: {s}\n", .{data});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    //
    // read file / write file
    //
    //------------------------------------------------------------
    {
        const read_handle = try dir.openFile(io, FILENAME1, .{});
        defer read_handle.close(io);

        const read_stat = try read_handle.stat(io);

        var read_buffer: [1024]u8 = undefined;
        var reader = read_handle.reader(io, &read_buffer);

        const data = try reader.interface.readAlloc(
            allocator,
            read_stat.size,
        );
        defer allocator.free(data);

        std.debug.print("openFile: stat.size: {d}\n", .{read_stat.size});
        std.debug.print("reader: data: {s}\n", .{data});

        const write_handle = try dir.createFile(io, FILENAME2, .{});
        defer write_handle.close(io);
        var write_buffer: [1024]u8 = undefined;
        var writer = write_handle.writer(io, &write_buffer);

        try writer.interface.writeAll(data);
        try writer.interface.flush(); // required

        const write_stat = try write_handle.stat(io);

        std.debug.print("writer: stat.size: {d}\n", .{write_stat.size});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    //
    // list directory entries
    //
    //------------------------------------------------------------
    {
        var opendir_handle = try dir.openDir(io, ".", .{ .iterate = true });
        defer opendir_handle.close(io);

        const stat = try opendir_handle.stat(io);

        std.debug.print("openDir: mtime: {d}\n", .{stat.mtime});

        var dirIterator = opendir_handle.iterate();
        while (try dirIterator.next(io)) |dirEntry| {
            std.debug.print("iterate: {}: {s}\n", .{ dirEntry.kind, dirEntry.name });
        }

        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
}

//------------------------------------------------------------

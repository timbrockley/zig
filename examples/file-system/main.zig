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
    const allocator = init.gpa;
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
            try dir.deleteFile(io, TEST_DIR);
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
        //------------------------------------------------------------
        // if file currently locked then code should wait until unlocked
        //------------------------------------------------------------
        const file_handle = dir.createFile(io, FILENAME1, .{
            .read = true,
            .truncate = true, // truncate file if it exists (overwrite)
        }) catch |err| {
            std.debug.print("createFile: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        defer file_handle.close(io);
        //------------------------------------------------------------
        try file_handle.writeStreamingAll(io, "zig createFile/writeStreamingAll test");
        //------------------------------------------------------------
        const stat = try file_handle.stat(io);
        const size = stat.size;
        //------------------------------------------------------------
        std.debug.print("createFile: writeStreamingAll: size: {d}\n", .{size});
        std.debug.print("\n", .{});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    //
    // read / lock file
    //
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        const file_handle1 = try dir.openFile(io, FILENAME1, .{});
        defer file_handle1.close(io);
        //------------------------------------------------------------
        try file_handle1.lock(io, .exclusive);
        // defer file_handle1.unlock(io);
        const t = try std.Thread.spawn(.{}, unlockAfterTimeout, .{ io, file_handle1, 3000 });
        t.detach();
        //------------------------------------------------------------
        const stat1 = try file_handle1.stat(io);
        //------------------------------------------------------------
        var read_buffer1: [1024]u8 = undefined;
        var file_reader1 = file_handle1.reader(io, &read_buffer1);
        //----------------------------------------
        const data1A = try file_reader1.interface.readAlloc(
            allocator,
            stat1.size,
        );
        defer allocator.free(data1A);
        //----------------------------------------
        try file_reader1.seekTo(0);
        //----------------------------------------
        var data1B = try std.ArrayList(u8).initCapacity(allocator, 0);
        defer data1B.deinit(allocator);
        //----------------------------------------
        try std.Io.Reader.appendRemainingUnlimited(&file_reader1.interface, allocator, &data1B);
        //----------------------------------------
        std.debug.print("openFile: stat.size: {d}\n", .{stat1.size});
        std.debug.print("reader: readAlloc: {s}\n", .{data1A});
        std.debug.print("reader: appendRemainingUnlimited: {s}\n", .{data1B.items});
        std.debug.print("\n", .{});
        //------------------------------------------------------------
        std.debug.print("waiting for file handle to unlock before acessing file again ...\n\n", .{});
        //------------------------------------------------------------
        const file_handle2 = try dir.openFile(io, FILENAME1, .{});
        defer file_handle2.close(io);
        //----------------------------------------
        try file_handle2.lock(io, .exclusive);
        defer file_handle2.unlock(io);
        //----------------------------------------
        var read_buffer2: [1024]u8 = undefined;
        var file_reader2 = file_handle2.reader(io, &read_buffer2);
        //----------------------------------------
        const data2 = try file_reader2.interface.readAlloc(
            allocator,
            stat1.size,
        );
        defer allocator.free(data2);
        //----------------------------------------
        std.debug.print("reader: readAlloc: {s}\n", .{data2});
        std.debug.print("\n", .{});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    //
    // read file / write file
    //
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
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
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    //
    // list directory entries
    //
    //------------------------------------------------------------
    {
        //------------------------------------------------------------
        var opendir_handle = try dir.openDir(io, ".", .{ .iterate = true });
        defer opendir_handle.close(io);

        const stat = try opendir_handle.stat(io);

        std.debug.print("openDir: mtime: {d}\n", .{stat.mtime});

        var dirIterator = opendir_handle.iterate();
        while (try dirIterator.next(io)) |dirEntry| {
            std.debug.print("iterate: {}: {s}\n", .{ dirEntry.kind, dirEntry.name });
        }

        std.debug.print("\n", .{});
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//------------------------------------------------------------
fn unlockAfterTimeout(
    io: std.Io,
    file_handle: std.Io.File,
    ms: i64,
) !void {
    //------------------------------------------------------------
    std.debug.print("file handle will unlock after {d} milliseconds ... unaffected code can continue to run ...\n\n", .{ms});
    //------------------------------------------------------------
    try io.sleep(.fromMilliseconds(ms), .awake);
    //------------------------------------------------------------
    defer file_handle.unlock(io);
    //------------------------------------------------------------
}
//------------------------------------------------------------

//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

pub const TEST_DIR = "test";
pub const TEST_DIR1 = "test/1";
pub const TEST_DIR2 = "test/1/2";
pub const TEST_DIR3 = "test/1/2/3";

pub fn main() !void {
    //------------------------------------------------------------
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    const cwdString = try std.fs.cwd().realpathAlloc(allocator, ".");
    std.debug.print("cwd: {s}\n", .{cwdString});
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    if (std.fs.cwd().statFile(TEST_DIR)) |stat| {
        if (stat.kind == .file) {
            try std.fs.cwd().deleteFile(TEST_DIR);
        }
    } else |_| {}
    //------------------------------------------------------------
    std.fs.cwd().makeDir(TEST_DIR) catch |err| {
        if (err != error.PathAlreadyExists) {
            std.debug.print("makeDir: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        }
    };
    std.debug.print("makeDir: directory created\n", .{});
    //------------------------------------------------------------
    std.fs.cwd().makePath(TEST_DIR2) catch |err| {
        std.debug.print("makePath: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    std.debug.print("makePath: directory created\n", .{});
    //------------------------------------------------------------
    const statExisting = try std.fs.cwd().statFile(TEST_DIR2);
    switch (statExisting.kind) {
        .directory => std.debug.print("statFile: directory exists\n", .{}),
        .file => std.debug.print("statFile: file exists\n", .{}),
        else => std.debug.print("statFile: exists, type: {s}\n", .{@tagName(statExisting.kind)}),
    }
    //------------------------------------------------------------
    if (std.fs.cwd().statFile(TEST_DIR3)) |statResult| {
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
    {
        const file = try std.fs.cwd().createFile(
            "test.txt",
            .{
                .read = true,
                .truncate = true, // truncate file if it exists (overwrite)
            },
        );
        defer file.close();

        try file.writeAll("zig createFile test");

        const stat = try file.stat();
        const size = stat.size;

        try file.seekTo(0);

        // var buffer: [100]u8 = undefined;
        // const bytesRead = try file.readAll(&buffer);

        var buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);

        const bytesRead = try file.readAll(buffer);

        std.debug.print("createFile: writeAll: size: {d}\n", .{size});
        std.debug.print("readAll: bytesRead: {d}\n", .{bytesRead});
        std.debug.print("readAll: fileContents: {s}\n", .{buffer[0..bytesRead]});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    {
        const file = try std.fs.cwd().openFile("test.txt", .{});
        defer file.close();

        const stat = try file.stat();
        const size = stat.size;

        try file.seekTo(0);

        // var buffer: [100]u8 = undefined;
        // const bytesRead = try file.readAll(&buffer);

        var buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);

        const bytesRead = try file.readAll(buffer);

        std.debug.print("openFile: size: {d}\n", .{size});
        std.debug.print("readAll: bytesRead: {d}\n", .{bytesRead});
        std.debug.print("readAll: fileContents: {s}\n", .{buffer[0..bytesRead]});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    {
        var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
        defer dir.close();

        var dirIterator = dir.iterate();
        while (try dirIterator.next()) |dirContent| {
            std.debug.print("openDir: {}: {s}\n", .{ dirContent.kind, dirContent.name });
        }
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
}

//------------------------------------------------------------

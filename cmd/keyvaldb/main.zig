//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
const tbt = @import("libs/time26057.zig");
//--------------------------------------------------------------------------------
pub const config_filename = ".keyvaldb.conf";
//--------------------------------------------------------------------------------
pub const BRIGHT_ORANGE = "\x1B[38;5;214m";
pub const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
pub fn main(processInit: std.process.Init) !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
    const allocator = gpa.allocator();
    //------------------------------------------------------------
    var self = try init(.{ .allocator = allocator, .processInit = processInit });
    //------------------------------------------------------------
    const output: []const u8 = try self.processArguments();
    defer allocator.free(output);
    //------------------------------------------------------------
    try std.Io.File.stdout().writeStreamingAll(processInit.io, output);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
const Self = @This();
//------------------------------------------------------------
allocator: std.mem.Allocator = undefined,
processInit: std.process.Init = undefined,
//------------------------------------------------------------
pub fn init(options: anytype) !Self {
    //------------------------------------------------------------
    var self = Self{};
    //------------------------------------------------------------
    if (!@hasField(@TypeOf(options), "processInit")) return error.InvalidProcessInit;
    //------------------------------------------------------------
    self.processInit = options.processInit;
    //------------------------------------------------------------
    self.allocator = if (@hasField(@TypeOf(options), "allocator")) options.allocator else options.processInit.arena.allocator();
    //------------------------------------------------------------
    return self;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn processArguments(self: *Self) ![]const u8 {
    //------------------------------------------------------------
    var it = self.processInit.minimal.args.iterate();
    //------------------------------------------------------------
    const cmd_name = if (it.next()) |s| std.fs.path.basename(s) else "";
    //------------------------------------------------------------
    const _directory = if (it.next()) |s| s else "";
    const directory = std.mem.trimStart(u8, _directory, "/");
    //------------------------------------------------------------
    if (std.mem.eql(u8, directory, "") or
        std.mem.eql(u8, directory, "help") or
        std.mem.eql(u8, directory, "--help") or
        std.mem.eql(u8, directory, "-h"))
    {
        //----------------------------------------
        return self.printHelp(cmd_name);
        //----------------------------------------
    }
    //------------------------------------------------------------
    const _instruction = if (it.next()) |s| s else "";
    //------------------------------------------------------------
    const Instruction = enum { create, repair, drop, list, set, get, mtime, remove };
    const instruction = std.meta.stringToEnum(Instruction, _instruction) orelse {
        return error.InvalidInstruction;
    };
    //------------------------------------------------------------
    const key = if (it.next()) |s| s else "";
    const value = if (it.next()) |s| s else "";
    //------------------------------------------------------------
    return switch (instruction) {
        .create => self.createDatabase(directory),
        .repair => self.repairDatabase(directory),
        .drop => self.dropDatabase(directory),
        .list => self.listKeys(directory),
        .set => self.setKey(directory, key, value),
        .get => self.getKey(directory, key),
        .mtime => self.mtimeKey(directory, key),
        .remove => self.removeKey(directory, key),
    };
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn createDatabase(self: *Self, directory: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (self.exists(directory)) {
        if (!self.isDirectory(directory)) return error.InvalidDatabaseFilepath;
        if (self.exists(config_filepath) and self.isFile(config_filepath)) {
            return error.DatabaseAlreadyExists;
        }
        return error.InvalidConfigFile;
    }
    //------------------------------------------------------------
    try std.Io.Dir.cwd().createDirPath(self.processInit.io, directory);
    //------------------------------------------------------------
    const file = try std.Io.Dir.cwd().createFile(self.processInit.io, config_filepath, .{ .read = true, .truncate = true });
    defer file.close(self.processInit.io);
    //------------------------------------------------------------
    return try self.allocator.alloc(u8, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn repairDatabase(self: *Self, directory: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) {
        //------------------------------------------------------------
        const file = try std.Io.Dir.cwd().createFile(self.processInit.io, config_filepath, .{ .read = true, .truncate = true });
        defer file.close(self.processInit.io);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return try self.allocator.alloc(u8, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn dropDatabase(self: *Self, directory: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    try std.Io.Dir.cwd().deleteTree(self.processInit.io, directory);
    //------------------------------------------------------------
    return try self.allocator.alloc(u8, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn listKeys(self: *Self, directory: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    var opendir_handle = try std.Io.Dir.cwd().openDir(self.processInit.io, directory, .{ .iterate = true });
    defer opendir_handle.close(self.processInit.io);
    //------------------------------------------------------------
    var max_key_len: usize = 3;
    var count: usize = 0;
    //------------------------------------------------------------
    var dirIterator = opendir_handle.iterate();
    //----------------------------------------
    while (try dirIterator.next(self.processInit.io)) |dirEntry| {
        //----------------------------------------
        if (std.mem.eql(u8, dirEntry.name, config_filename)) continue;
        //----------------------------------------
        if (max_key_len < dirEntry.name.len) max_key_len = dirEntry.name.len;
        //----------------------------------------
        count += 1;
        //----------------------------------------
    }
    //------------------------------------------------------------
    if (count == 0) {
        //------------------------------------------------------------
        return try self.allocator.dupe(u8, "no key-value pairs exist\n");
        //------------------------------------------------------------
    } else {
        //------------------------------------------------------------
        var buffer = std.ArrayList(u8){};
        errdefer buffer.deinit(self.allocator);
        //------------------------------------------------------------
        const header_key = try self.rightPad("KEY", max_key_len);
        defer self.allocator.free(header_key);
        //------------------------------------------------------------
        try buffer.print(self.allocator, "\n{s}  VALUE\n", .{header_key});
        //------------------------------------------------------------
        dirIterator = opendir_handle.iterate();
        while (try dirIterator.next(self.processInit.io)) |dirEntry| {
            //----------------------------------------
            if (std.mem.eql(u8, dirEntry.name, config_filename)) continue;
            //----------------------------------------
            const key = try self.rightPad(dirEntry.name, max_key_len);
            defer self.allocator.free(key);
            //----------------------------------------
            const value = self.getKey(directory, dirEntry.name) catch |err| {
                try buffer.print(self.allocator, "{s}  {s}{}{s}\n", .{ key, BRIGHT_ORANGE, err, RESET });
                continue;
            };
            defer self.allocator.free(value);
            //----------------------------------------
            self.escapeString(value);
            //----------------------------------------
            try buffer.print(self.allocator, "{s}  {s}\n", .{ key, value });
            //----------------------------------------
        }
        //------------------------------------------------------------
        try buffer.print(self.allocator, "\n", .{});
        //------------------------------------------------------------
        return try buffer.toOwnedSlice(self.allocator);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn setKey(self: *Self, directory: []const u8, key: []const u8, value: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    if (!self.checkKeyName(key)) return error.InvalidKeyName;
    //------------------------------------------------------------
    const key_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, key });
    defer self.allocator.free(key_filepath);
    //------------------------------------------------------------
    if (self.exists(key_filepath) and !self.isFile(key_filepath)) return error.InvalidKeyFile;
    //------------------------------------------------------------
    const file = try std.Io.Dir.cwd().createFile(self.processInit.io, key_filepath, .{ .read = true, .truncate = true });
    defer file.close(self.processInit.io);
    //------------------------------------------------------------
    const stdin_file = std.Io.File.stdin();
    //------------------------------------------------------------
    if (value.len == 0 and !try stdin_file.isTty(self.processInit.io)) {
        //----------------------------------------
        var read_buffer: [1024]u8 = undefined;
        var file_reader = stdin_file.reader(self.processInit.io, &read_buffer);
        //----------------------------------------
        var data = std.ArrayList(u8){};
        defer data.deinit(self.allocator);
        //----------------------------------------
        try std.Io.Reader.appendRemainingUnlimited(&file_reader.interface, self.allocator, &data);
        //----------------------------------------
        try file.writeStreamingAll(self.processInit.io, data.items);
        //----------------------------------------
    } else {
        //----------------------------------------
        try file.writeStreamingAll(self.processInit.io, value);
        //----------------------------------------
    }
    //------------------------------------------------------------
    return try self.allocator.alloc(u8, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn getKey(self: *Self, directory: []const u8, key: []const u8) ![]u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    if (!self.checkKeyName(key)) return error.InvalidKeyName;
    //------------------------------------------------------------
    const key_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, key });
    defer self.allocator.free(key_filepath);
    //------------------------------------------------------------
    if (self.exists(key_filepath) and !self.isFile(key_filepath)) return error.InvalidKeyFile;
    //------------------------------------------------------------
    const read_handle = std.Io.Dir.cwd().openFile(self.processInit.io, key_filepath, .{}) catch |err| {
        if (err == error.FileNotFound) return try self.allocator.alloc(u8, 0);
        return err;
    };
    defer read_handle.close(self.processInit.io);
    //------------------------------------------------------------
    const read_stat = try read_handle.stat(self.processInit.io);
    //------------------------------------------------------------
    var read_buffer: [1024]u8 = undefined;
    var reader = read_handle.reader(self.processInit.io, &read_buffer);
    //------------------------------------------------------------
    return try reader.interface.readAlloc(
        self.allocator,
        read_stat.size,
    );
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn mtimeKey(self: *Self, directory: []const u8, key: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    if (!self.checkKeyName(key)) return error.InvalidKeyName;
    //------------------------------------------------------------
    const key_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, key });
    defer self.allocator.free(key_filepath);
    //------------------------------------------------------------
    if (self.exists(key_filepath) and !self.isFile(key_filepath)) return error.InvalidKeyFile;
    //------------------------------------------------------------
    const read_handle = std.Io.Dir.cwd().openFile(self.processInit.io, key_filepath, .{}) catch |err| {
        if (err == error.FileNotFound) return try self.allocator.alloc(u8, 0);
        return err;
    };
    defer read_handle.close(self.processInit.io);
    //------------------------------------------------------------
    const read_stat = try read_handle.stat(self.processInit.io);
    //------------------------------------------------------------
    const ns = read_stat.mtime.toNanoseconds();
    const utms: i64 = @intCast(@divTrunc(ns, 1_000_000));
    const datetime = try tbt.unix_milliseconds_to_datetime(utms);
    //------------------------------------------------------------
    var buffer: [20]u8 = undefined;
    _ = try tbt.format(datetime, "CY-m-dThh:mm:ss.", &buffer);
    //------------------------------------------------------------
    return try std.fmt.allocPrint(
        self.allocator,
        "{s}{d:0>9}Z",
        .{ buffer, @as(u64, @intCast(@mod(ns, 1_000_000_000))) },
    );
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn removeKey(self: *Self, directory: []const u8, key: []const u8) ![]const u8 {
    //------------------------------------------------------------
    try self.checkDirectoryPath(directory);
    //------------------------------------------------------------
    if (!self.exists(directory)) return error.DatabaseDoesNotExist;
    //------------------------------------------------------------
    const config_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, config_filename });
    defer self.allocator.free(config_filepath);
    //------------------------------------------------------------
    if (!self.exists(config_filepath)) return error.InvalidConfigFile;
    //------------------------------------------------------------
    if (!self.checkKeyName(key)) return error.InvalidKeyName;
    //------------------------------------------------------------
    const key_filepath = try std.fs.path.join(self.allocator, &[_][]const u8{ directory, key });
    defer self.allocator.free(key_filepath);
    //------------------------------------------------------------
    if (self.exists(key_filepath) and !self.isFile(key_filepath)) return error.InvalidKeyFile;
    //------------------------------------------------------------
    if (self.exists(key_filepath) and self.isFile(key_filepath)) {
        //------------------------------------------------------------
        try std.Io.Dir.cwd().deleteFile(self.processInit.io, key_filepath);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return try self.allocator.alloc(u8, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn printHelp(self: *Self, cmd_name: []const u8) ![]const u8 {
    //------------------------------------------------------------
    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(self.allocator);
    //------------------------------------------------------------
    try buffer.print(self.allocator,
        \\
        \\{s} <DATABASE_DIRECTORY> create
        \\{s} <DATABASE_DIRECTORY> repair
        \\{s} <DATABASE_DIRECTORY> drop
        \\{s} <DATABASE_DIRECTORY> list
        \\{s} <DATABASE_DIRECTORY> set <KEY> <VALUE>
        \\{s} <DATABASE_DIRECTORY> set <KEY> <<< "STDIN_DATA"
        \\{s} <DATABASE_DIRECTORY> get <KEY>
        \\{s} <DATABASE_DIRECTORY> mtime <KEY>
        \\{s} <DATABASE_DIRECTORY> remove <KEY>
        \\
        \\
    , .{cmd_name} ** 9);
    //------------------------------------------------------------
    return try buffer.toOwnedSlice(self.allocator);
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------
pub fn checkDirectoryPath(self: *Self, directory: []const u8) !void {
    //------------------------------------------------------------
    if (std.mem.eql(u8, directory, "")) return error.InvalidDirectoryLocation;
    if (std.mem.eql(u8, directory, "/")) return error.InvalidDirectoryLocation;
    if (std.mem.eql(u8, directory, "/root")) return error.InvalidDirectoryLocation;
    if (std.mem.eql(u8, directory, "/tmp")) return error.InvalidDirectoryLocation;
    if (std.mem.eql(u8, directory, "~")) return error.InvalidDirectoryLocation;
    //------------------------------------------------------------
    const home_directory = if (self.processInit.environ_map.get("HOME")) |home| home else "";
    //------------------------------------------------------------
    if (std.mem.eql(u8, directory, home_directory)) return error.InvalidDirectoryLocation;
    //------------------------------------------------------------
    if (!self.checkDirectoryName(std.fs.path.basename(directory))) return error.InvalidDatabaseName;
    //------------------------------------------------------------
    return;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn checkDirectoryName(_: *Self, name: []const u8) bool {
    //------------------------------------------------------------
    if (name.len == 0) return false;
    //------------------------------------------------------------
    for (name) |char| {
        switch (char) {
            '.', '_', '0'...'9', 'A'...'Z', 'a'...'z' => continue,
            else => return false,
        }
    }
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn checkKeyName(_: *Self, name: []const u8) bool {
    //------------------------------------------------------------
    if (name.len == 0 or std.mem.eql(u8, name, config_filename)) {
        return false;
    }
    //------------------------------------------------------------
    for (name) |char| {
        switch (char) {
            '_', '0'...'9', 'A'...'Z', 'a'...'z' => continue,
            else => return false,
        }
    }
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn escapeString(_: *Self, data: []u8) void {
    for (data) |*char| {
        if ((char.* >= 0x00 and char.* <= 0x20) or char.* == 0x7F) char.* = 0x20;
    }
}
//--------------------------------------------------------------------------------
pub fn exists(self: *Self, filepath: []const u8) bool {
    if (std.Io.Dir.cwd().statFile(self.processInit.io, filepath, .{})) |stat| {
        if (stat.kind == .directory or stat.kind == .file or stat.kind == .sym_link) return true;
    } else |_| {}
    return false;
}
//--------------------------------------------------------------------------------
pub fn isDirectory(self: *Self, filepath: []const u8) bool {
    if (std.Io.Dir.cwd().statFile(self.processInit.io, filepath, .{})) |stat| {
        if (stat.kind == .directory) return true;
    } else |_| {}
    return false;
}
//--------------------------------------------------------------------------------
pub fn isFile(self: *Self, filepath: []const u8) bool {
    if (std.Io.Dir.cwd().statFile(self.processInit.io, filepath, .{})) |stat| {
        if (stat.kind == .file) return true;
    } else |_| {}
    return false;
}
//--------------------------------------------------------------------------------
pub fn rightPad(self: *Self, input: []const u8, min_len: usize) ![]u8 {
    //------------------------------------------------------------
    if (input.len >= min_len) return try self.allocator.dupe(u8, input);
    //------------------------------------------------------------
    const output = try self.allocator.alloc(u8, min_len);
    //------------------------------------------------------------
    std.mem.copyForwards(u8, output[0..input.len], input);
    @memset(output[input.len..], ' ');
    //------------------------------------------------------------
    return output;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

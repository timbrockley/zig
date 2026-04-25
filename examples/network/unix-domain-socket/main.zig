//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
//--------------------------------------------------------------------------------
const SOCKET_ADDR: []const u8 = "/tmp/zig-socket-test.sock";
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const io = init.io;
    //------------------------------------------------------------
    const server_thread = try std.Thread.spawn(.{}, serverFunc, .{io});
    server_thread.detach();
    //------------------------------------------------------------
    try io.sleep(.fromMilliseconds(100), .real);
    //------------------------------------------------------------
    try clientFunc(io);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn serverFunc(io: std.Io) !void {
    //------------------------------------------------------------
    std.debug.print("server: waiting for data from client\n", .{});
    //------------------------------------------------------------
    _ = std.Io.Dir.cwd().deleteFile(io, SOCKET_ADDR) catch {};
    //------------------------------------------------------------
    const address = try std.Io.net.UnixAddress.init(SOCKET_ADDR);
    //------------------------------------------------------------
    var server = try address.listen(io, .{});
    defer server.deinit(io);
    //------------------------------------------------------------
    var read_buffer: [1024]u8 = undefined;
    //-----------------------------------------
    var shutdown = false;
    //-----------------------------------------
    while (!shutdown) {
        //-----------------------------------------
        const stream = try server.accept(io);
        defer stream.close(io);
        //-----------------------------------------
        var reader = stream.reader(io, &.{});
        var writer = stream.writer(io, &.{});
        //-----------------------------------------
        while (true) {
            //-----------------------------------------
            const bytes_read = try reader.interface.readSliceShort(&read_buffer);
            if (bytes_read == 0) break;
            //-----------------------------------------
            const bytes = read_buffer[0..bytes_read];
            //-----------------------------------------
            if (std.mem.startsWith(u8, bytes, "STOP")) {
                shutdown = true;
                return;
            }
            //-----------------------------------------
            writer.interface.writeAll(bytes) catch |err| {
                std.debug.print("connection closed ({})\n", .{err});
            };
            //-----------------------------------------
            std.debug.print("server: received from client: {s}\n", .{bytes});
            //-----------------------------------------
        }
        //-----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn clientFunc(io: std.Io) !void {
    //------------------------------------------------------------
    std.debug.print("client: waiting for data from server\n", .{});
    //------------------------------------------------------------
    const address = try std.Io.net.UnixAddress.init(SOCKET_ADDR);
    //-----------------------------------------
    var stream = address.connect(io) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("socket does not exit: {s}\n", .{SOCKET_ADDR});
            return;
        },
        else => {
            std.debug.print("unknown socket error: {s}\n", .{SOCKET_ADDR});
            return err;
        },
    };
    defer stream.close(io);
    //-----------------------------------------
    var reader = stream.reader(io, &.{});
    var writer = stream.writer(io, &.{});
    //-----------------------------------------
    try writer.interface.writeAll("client data");
    try writer.interface.flush();
    try stream.shutdown(io, .send);
    //-----------------------------------------
    var read_buffer: [1024]u8 = undefined;
    //-----------------------------------------
    const bytes_read = try reader.interface.readSliceShort(&read_buffer);
    //-----------------------------------------
    std.debug.print("client: received back from server: {s}\n", .{read_buffer[0..bytes_read]});
    //-----------------------------------------
}
//--------------------------------------------------------------------------------

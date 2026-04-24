//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
//--------------------------------------------------------------------------------
const SERVER_ADDR: []const u8 = "127.0.0.1";
const SERVER_PORT: u16 = 3000;
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
    const address = try std.Io.net.IpAddress.resolve(io, SERVER_ADDR, SERVER_PORT);
    //------------------------------------------------------------
    var server = try address.listen(io, .{ .reuse_address = true });
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
    const address = try std.Io.net.IpAddress.resolve(io, SERVER_ADDR, SERVER_PORT);
    //-----------------------------------------
    var stream = address.connect(io, .{ .mode = .stream }) catch |err| switch (err) {
        error.ConnectionRefused => {
            std.debug.print("connection refused {s}:{d}\n", .{ SERVER_ADDR, SERVER_PORT });
            return;
        },
        error.NetworkUnreachable => {
            std.debug.print("network unreachable {s}:{d}\n", .{ SERVER_ADDR, SERVER_PORT });
            return;
        },
        else => return err,
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

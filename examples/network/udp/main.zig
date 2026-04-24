//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std: type = @import("std");
//--------------------------------------------------------------------------------
const IP_ADDR: []const u8 = "127.0.0.1";
const SERVER_PORT: u16 = 3001;
const CLIENT_PORT: u16 = 3002;
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
    const server_addr = try std.Io.net.IpAddress.resolve(io, IP_ADDR, SERVER_PORT);
    const client_addr = try std.Io.net.IpAddress.resolve(io, IP_ADDR, CLIENT_PORT);
    //------------------------------------------------------------
    var server = try server_addr.bind(io, .{ .mode = .dgram });
    //-----------------------------------------
    var read_buffer: [1024]u8 = undefined;
    //-----------------------------------------
    var shutdown = false;
    //-----------------------------------------
    while (!shutdown) {
        //-----------------------------------------
        const incoming_message = try server.receive(io, &read_buffer);
        //-----------------------------------------
        // const from = incoming_message.from;
        const message = incoming_message.data;
        //-----------------------------------------
        if (std.mem.startsWith(u8, message, "STOP")) {
            shutdown = true;
            return;
        }
        //-----------------------------------------
        std.debug.print("server: received from client: {s}\n", .{message});
        //-----------------------------------------
        try server.send(io, &client_addr, message);
        //-----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn clientFunc(io: std.Io) !void {
    //------------------------------------------------------------
    std.debug.print("client: waiting for data from server\n", .{});
    //------------------------------------------------------------
    const server_addr = try std.Io.net.IpAddress.resolve(io, IP_ADDR, SERVER_PORT);
    //------------------------------------------------------------
    const stream = try std.Io.net.IpAddress.connect(&server_addr, io, .{ .mode = .dgram });
    defer stream.close(io);
    //------------------------------------------------------------
    try stream.socket.send(io, &server_addr, "client data");
    //------------------------------------------------------------
    const client_addr = try std.Io.net.IpAddress.resolve(io, IP_ADDR, CLIENT_PORT);
    var client = try client_addr.bind(io, .{ .mode = .dgram });
    //------------------------------------------------------------
    var read_buffer: [1024]u8 = undefined;
    //-----------------------------------------
    const incoming_message = try client.receive(io, &read_buffer);
    //-----------------------------------------
    // const from = incoming_message.from;
    const message = incoming_message.data;
    //-----------------------------------------
    std.debug.print("client: received back from server: {s}\n", .{message});
    //------------------------------------------------------------
    try io.sleep(.fromMilliseconds(100), .real);
    //-----------------------------------------
    try stream.socket.send(io, &server_addr, "STOP");
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

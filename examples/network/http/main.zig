const std = @import("std");
//--------------------------------------------------------------------------------
const SERVER_ADDR = "127.0.0.1";
const SERVER_PORT = 3000;
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
    // try io.sleep(.fromMilliseconds(3000), .real);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn serverFunc(io: std.Io) !void {
    //------------------------------------------------------------
    const address = try std.Io.net.IpAddress.resolve(io, SERVER_ADDR, SERVER_PORT);
    //------------------------------------------------------------
    var server = try address.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);
    //------------------------------------------------------------
    const stream = try server.accept(io);
    defer stream.close(io);

    var reader_buffer: [1024]u8 = undefined;
    var writer_buffer: [1024]u8 = undefined;

    var reader = stream.reader(io, &reader_buffer);
    var writer = stream.writer(io, &writer_buffer);

    var server_http = std.http.Server.init(&reader.interface, &writer.interface);

    var req = try server_http.receiveHead();

    try req.respond("hello from server", .{});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn clientFunc(io: std.Io) !void {
    //------------------------------------------------------------
    std.debug.print("waiting for data from server\n\n", .{});
    //------------------------------------------------------------
    const address = try std.Io.net.IpAddress.resolve(io, SERVER_ADDR, SERVER_PORT);
    //------------------------------------------------------------
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
    //------------------------------------------------------------
    var reader = stream.reader(io, &.{});
    var writer = stream.writer(io, &.{});
    //------------------------------------------------------------
    try writer.interface.writeAll(
        "GET / HTTP/1.1\r\n" ++
            "Host: 127.0.0.1\r\n" ++
            "Connection: close\r\n" ++
            "\r\n",
    );
    try writer.interface.flush();
    try stream.shutdown(io, .send);
    //-----------------------------------------
    var read_buffer: [1024]u8 = undefined;
    //-----------------------------------------
    const bytes_read = try reader.interface.readSliceShort(&read_buffer);
    //-----------------------------------------
    std.debug.print("{s}\n", .{read_buffer[0..bytes_read]});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

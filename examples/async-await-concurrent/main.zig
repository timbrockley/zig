//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const TESTS: usize = 5;
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const io = init.io;
    var group: std.Io.Group = .init;
    //------------------------------------------------------------
    std.debug.print("\nmain started\n", .{});
    std.debug.print("\nio.async (works using multiple or single threaded io)\n\n", .{});
    //------------------------------------------------------------
    for (1..TESTS + 1) |id| {
        group.async(init.io, worker1, .{
            init.io,
            id,
            @as(i64, @intCast((id) * 400)),
        });
    }
    //------------------------------------------------------------
    try group.await(init.io);
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var future1 = io.async(worker2, .{1});
        var future2 = io.async(worker2, .{2});
        var future3 = io.async(worker2, .{3});
        std.debug.print("<= returned id: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future3.await(io)});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var threaded: std.Io.Threaded = .init_single_threaded;
        const single_threaded_io = threaded.io();

        var future1 = single_threaded_io.async(worker2, .{1});
        var future2 = single_threaded_io.async(worker2, .{2});
        var future3 = single_threaded_io.async(worker2, .{3});
        std.debug.print("<= returned id: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future3.await(io)});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var futures: [3]@TypeOf(io.async(worker2, .{0})) = undefined;

        for (0..3) |index| {
            futures[index] = io.async(worker2, .{index + 1});
        }

        for (0..3) |index| {
            std.debug.print("<= returned id: {d}\n", .{futures[index].await(io)});
        }
    }
    //------------------------------------------------------------
    std.debug.print("\nio.concurrent (won't work if only using single threaded io)\n\n", .{});
    //------------------------------------------------------------
    for (1..TESTS + 1) |id| {
        try group.concurrent(init.io, worker1, .{
            init.io,
            id,
            @as(i64, @intCast((id) * 400)),
        });
    }
    //------------------------------------------------------------
    try group.await(init.io);
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var future1 = try io.concurrent(worker2, .{1});
        var future2 = try io.concurrent(worker2, .{2});
        var future3 = try io.concurrent(worker2, .{3});
        std.debug.print("<= returned id: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned id: {d}\n", .{future3.await(io)});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var futures: [3]@TypeOf(try io.concurrent(worker2, .{0})) = undefined;

        for (0..3) |index| {
            futures[index] = try io.concurrent(worker2, .{index + 1});
        }

        for (0..3) |index| {
            std.debug.print("<= returned id: {d}\n", .{futures[index].await(io)});
        }
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    std.debug.print("main ended\n\n", .{});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn worker1(io: std.Io, id: usize, ms: i64) !void {
    //------------------------------------------------------------
    std.debug.print("worker {d} started\n", .{id});
    //------------------------------------------------------------
    try io.sleep(.fromMilliseconds(ms), .real);
    //------------------------------------------------------------
    std.debug.print("worker {d} ended\n", .{id});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn worker2(id: usize) usize {
    //------------------------------------------------------------
    std.debug.print("=> received id: {d}\n", .{id});
    return id;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

//------------------------------------------------------------

const std = @import("std");

//------------------------------------------------------------

pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const io = init.io;
    //------------------------------------------------------------
    std.debug.print("\nio.async (single or multiple threads)\n\n", .{});
    //------------------------------------------------------------
    {
        var threaded: std.Io.Threaded = .init_single_threaded;
        const single_threaded_io = threaded.io();

        var future1 = single_threaded_io.async(work, .{1});
        var future2 = single_threaded_io.async(work, .{2});
        var future3 = single_threaded_io.async(work, .{3});
        std.debug.print("<= returned index: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future3.await(io)});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var future1 = io.async(work, .{1});
        var future2 = io.async(work, .{2});
        var future3 = io.async(work, .{3});
        std.debug.print("<= returned index: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future3.await(io)});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var futures: [3]@TypeOf(io.async(work, .{0})) = undefined;

        for (0..3) |index| {
            futures[index] = io.async(work, .{index + 1});
        }

        for (0..3) |index| {
            std.debug.print("<= returned index: {d}\n", .{futures[index].await(io)});
        }
    }
    //------------------------------------------------------------
    std.debug.print("\nio.concurrent (won't work if only using single threaded io)\n\n", .{});
    //------------------------------------------------------------
    {
        var future1 = try io.concurrent(work, .{1});
        var future2 = try io.concurrent(work, .{2});
        var future3 = try io.concurrent(work, .{3});
        std.debug.print("<= returned index: {d}\n", .{future1.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future2.await(io)});
        std.debug.print("<= returned index: {d}\n", .{future3.await(io)});
        std.debug.print("\n", .{});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var futures: [3]@TypeOf(try io.concurrent(work, .{0})) = undefined;

        for (0..3) |index| {
            futures[index] = try io.concurrent(work, .{index + 1});
        }

        for (0..3) |index| {
            std.debug.print("<= returned index: {d}\n", .{futures[index].await(io)});
        }
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
}

//------------------------------------------------------------

pub fn work(index: usize) usize {
    std.debug.print("=> received index: {d}\n", .{index});
    return index;
}

//------------------------------------------------------------

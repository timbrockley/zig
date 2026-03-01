//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------
fn work(io: std.Io, id: usize, ms: u8) !void {
    try io.sleep(.fromMilliseconds(ms), .awake);
    std.debug.print("{} finished\n", .{id});
}
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const cpus = try std.Thread.getCpuCount();
    //------------------------------------------------------------
    var threads = try std.heap.page_allocator.alloc(std.Thread, cpus);
    defer std.heap.page_allocator.free(threads);
    //------------------------------------------------------------
    for (0..cpus) |i| {
        //----------------------------------------
        var byte: [1]u8 = undefined;
        init.io.random(&byte);
        const ms = byte[0] & 0x0F;
        //----------------------------------------
        threads[i] = try std.Thread.spawn(.{}, work, .{ init.io, i, ms });
        //----------------------------------------
    }
    //------------------------------------------------------------
    for (threads) |t| {
        t.join(); // waits for the each thread to complete
    }
    //------------------------------------------------------------
}
//------------------------------------------------------------

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const allocator = init.arena.allocator();

    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(allocator);

    try buffer.appendSlice(allocator, "hello ");
    try buffer.print(allocator, "{s}, he answer is {}.", .{ "world", 42 });

    std.debug.print("{s}\n", .{buffer.items});
    //------------------------------------------------------------
}

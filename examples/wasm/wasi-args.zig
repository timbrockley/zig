const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const args = init.minimal.args.vector;
    for (0.., args) |i, arg| {
        std.debug.print("{d}: {s}\n", .{ i, arg });
    }
}

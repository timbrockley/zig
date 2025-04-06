const std = @import("std");

fn work(id: usize) void {
    std.time.sleep(1 * std.time.ns_per_s);
    std.debug.print("{} finished\n", .{id});
}

pub fn main() !void {
    const cpus = try std.Thread.getCpuCount();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = allocator });
    defer pool.deinit();

    for (0..cpus) |i| {
        try pool.spawn(work, .{i});
    }
}

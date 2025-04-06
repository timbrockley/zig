const std = @import("std");
const math = @import("math.zig");

pub fn main() void {
    const sum = math.add(5, 3);
    const diff = math.subtract(10, 7);

    std.debug.print("Name: {s}\n", .{math.name});
    std.debug.print("Sum: {d}\n", .{sum});
    std.debug.print("Difference: {d}\n", .{diff});
}

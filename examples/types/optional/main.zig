const std = @import("std");

pub fn main() void {
    var value: ?u32 = undefined;

    value = 42;
    printValue(value);

    value = null;
    printValue(value);
}

// print format cannot print null
fn printValue(value: ?u32) void {
    if (value) |v| {
        std.debug.print("hello, value = {}\n", .{v});
    } else {
        std.debug.print("hello, value = null\n", .{});
    }
}

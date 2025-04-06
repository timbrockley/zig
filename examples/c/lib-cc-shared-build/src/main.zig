const std = @import("std");

extern fn add(a: i32, b: i32) i32;
extern fn sub(a: i32, b: i32) i32;

pub fn main() void {
    const result_add = add(3, 2);
    const result_sub = sub(5, 2);

    std.debug.print("3 + 2 = {}\n", .{result_add});
    std.debug.print("5 - 2 = {}\n", .{result_sub});
}

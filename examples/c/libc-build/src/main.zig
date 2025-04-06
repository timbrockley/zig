const std = @import("std");

extern fn printf(format: [*]const u8, ...) callconv(.C) i32;

pub fn main() void {
    // add "exe.linkLibC();" to "build.zig" to allow following line
    _ = std.c.printf("libc: std.c.printf\n", .{});

    const num: i32 = 42;
    _ = printf("printf: The answer is: %d\n", num);
}

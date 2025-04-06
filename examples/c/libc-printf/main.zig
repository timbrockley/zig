const std = @import("std");

// Declare the C function `printf`
extern fn printf(format: [*]const u8, ...) callconv(.C) i32;

pub fn main() void {
    const num: i32 = 42;
    // Call the C `printf` function
    _ = printf("printf: The answer is: %d\n", num);
}

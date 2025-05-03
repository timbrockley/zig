const std = @import("std");
const c = @cImport(@cInclude("stdio.h"));

pub fn main() void {
    const num: i32 = 42;
    _ = c.printf("printf: The answer is: %d\n", num);
}

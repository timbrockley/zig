const std = @import("std");

pub fn main() !void {
    var lib = try std.DynLib.open("./libmath.so");
    defer lib.close();

    const add = lib.lookup(*const fn (i32, i32) callconv(.c) i32, "add") orelse return error.NoSuchFunction;
    const sub = lib.lookup(*const fn (i32, i32) callconv(.c) i32, "sub") orelse return error.NoSuchFunction;

    const result_add = add(3, 2);
    const result_sub = sub(5, 2);

    std.debug.print("3 + 2 = {}\n", .{result_add});
    std.debug.print("5 - 2 = {}\n", .{result_sub});
}

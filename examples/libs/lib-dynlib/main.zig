//--------------------------------------------------------------------------------
// 2026-05-07 => callconv(.c) used because testing without this returned blank strings
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
pub const ExampleRawString = extern struct { ptr: [*]const u8, len: usize };
//--------------------------------------------------------------------------------
pub fn main() !void {
    var lib = try std.DynLib.open("./lib-shared.so");
    defer lib.close();

    const add = lib.lookup(*const fn (i32, i32) callconv(.c) i32, "add") orelse return error.NoSuchFunction;
    const sub = lib.lookup(*const fn (i32, i32) callconv(.c) i32, "sub") orelse return error.NoSuchFunction;
    const getRawString = lib.lookup(*const fn () callconv(.c) ExampleRawString, "getRawString") orelse return error.NoSuchFunction;

    const result_add = add(3, 2);
    const result_sub = sub(5, 2);
    const result_getRawString = getRawString();

    const result_string = result_getRawString.ptr[0..result_getRawString.len];

    const test_add = result_add == 5;
    const test_sub = result_sub == 3;
    const test_getRawString = std.mem.eql(u8, result_string, "example_string");

    std.debug.print("({}) 3 + 2 = {}\n", .{ test_add, result_add });
    std.debug.print("({}) 5 - 2 = {}\n", .{ test_sub, result_sub });
    std.debug.print(
        "({}) ExampleRawString = \"{s}\"\n",
        .{ test_getRawString, result_string },
    );
}
//--------------------------------------------------------------------------------

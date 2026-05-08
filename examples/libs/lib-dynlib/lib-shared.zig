//--------------------------------------------------------------------------------
// 2026-05-07 => callconv(.c) used because testing without this returned blank strings
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
pub const ExampleRawString = extern struct { ptr: [*]const u8, len: usize };
//--------------------------------------------------------------------------------
test "test add function" {
    const result = add(3, 2);
    try std.testing.expect(result == 5);
}

export fn add(a: i32, b: i32) callconv(.c) i32 {
    return a + b;
}
//--------------------------------------------------------------------------------
test "test sub function" {
    const result = sub(5, 2);
    try std.testing.expect(result == 3);
}

export fn sub(a: i32, b: i32) callconv(.c) i32 {
    return a - b;
}
//--------------------------------------------------------------------------------
test "test getRawString function" {
    const example_string = "example_string";
    const result = getRawString();
    try std.testing.expect(result.len == example_string.len);
    try std.testing.expectEqualStrings(
        example_string,
        result.ptr[0..result.len],
    );
}

export fn getRawString() callconv(.c) ExampleRawString {
    const example_string = "example_string";
    return ExampleRawString{
        .ptr = example_string.ptr,
        .len = example_string.len,
    };
}
//--------------------------------------------------------------------------------

const std = @import("std");
//--------------------------------------------------------------------------------
// 2026-05-07 => callconv(.c) used because testing without this returned blank strings
//--------------------------------------------------------------------------------
// extern definitions
//--------------------------------------------------------------------------------
pub const ExampleEnum = enum(u8) { no = 0, yes = 1 };
pub const ExampleRawString = extern struct { ptr: [*]const u8, len: usize };
//--------------------------------------------------------------------------------
pub const Self = extern struct {
    example_byte: u8 = 0,
    example_enum: ExampleEnum = .no,
    example_raw_string: ExampleRawString = .{ .ptr = "", .len = 0 },
};
//--------------------------------------------------------------------------------
// extern fn init() Self;
extern fn setByte(self: *Self, byte_value: u8) callconv(.c) bool;
extern fn getByte(self: *Self) callconv(.c) u8;
extern fn setEnum(self: *Self, enum_value: ExampleEnum) callconv(.c) bool;
extern fn getEnum(self: *Self) callconv(.c) ExampleEnum;
extern fn setRawString(self: *Self, raw_string: ExampleRawString) callconv(.c) bool;
extern fn getRawString(self: *Self) callconv(.c) ExampleRawString;
//--------------------------------------------------------------------------------
// wrapper functions
//--------------------------------------------------------------------------------
pub fn setString(self: *Self, raw_string: []const u8) bool {
    return setRawString(self, ExampleRawString{
        .ptr = raw_string.ptr,
        .len = raw_string.len,
    });
}
//----------------------------------------
pub fn getString(self: *Self) []const u8 {
    const self_raw_string = getRawString(self);
    return self_raw_string.ptr[0..self_raw_string.len];
}
//--------------------------------------------------------------------------------
// main
//--------------------------------------------------------------------------------
pub fn main() !void {
    //--------------------------------------------------------------------------------
    // var self = init();
    //------------------------------------------------------------
    var self = Self{};
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const self_byte = getByte(&self);
        const test_byte = self_byte == 0;
        std.debug.print("({}) self_byte = {any}\n", .{ test_byte, self_byte });
        //----------------------------------------
        const self_enum = getEnum(&self);
        const test_enum = self_enum == .no;
        std.debug.print("({}) self_enum = {any}\n", .{ test_enum, self_enum });
        //----------------------------------------
        const new_string = getString(&self);
        const test_string = std.mem.eql(u8, "", new_string);
        std.debug.print("({}) new_string = \"{s}\"\n", .{ test_string, new_string });
        std.debug.print("\n", .{});
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        _ = setByte(&self, 1);
        //----------------------------------------
        const self_byte = getByte(&self);
        const test_byte = self_byte == 1;
        std.debug.print("({}) self_byte = {any}\n", .{ test_byte, self_byte });
        //----------------------------------------
        _ = setEnum(&self, .yes);
        //----------------------------------------
        const self_enum = getEnum(&self);
        const test_enum = self_enum == .yes;
        std.debug.print("({}) self_enum = {any}\n", .{ test_enum, self_enum });
        //----------------------------------------
        _ = setString(&self, "new_string");
        //----------------------------------------
        const new_string = getString(&self);
        const test_string = std.mem.eql(u8, "new_string", new_string);
        std.debug.print("({}) new_string = \"{s}\"\n", .{ test_string, new_string });
        std.debug.print("\n", .{});
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------

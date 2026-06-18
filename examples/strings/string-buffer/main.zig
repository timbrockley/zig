//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const allocator = init.arena.allocator();
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        var buffer: [32]u8 = [_]u8{'_'} ** 32;

        std.debug.print("buffer:       {s}\n", .{buffer});

        const string_start = buffer[0..10];
        const string_mid = buffer[11..21];
        const string_end = buffer[22..];

        @memcpy(string_start, "1234567890");
        @memcpy(buffer[11..21], "ABCDEFGHIJ");
        @memcpy(string_end, "abcdefghij");

        std.debug.print("string_start: {s}\n", .{string_start});
        std.debug.print("string_mid:   {s}\n", .{string_mid});
        std.debug.print("string_end:   {s}\n", .{string_end});
        std.debug.print("buffer:       {s}\n", .{buffer});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    {
        const buffer = try allocator.alloc(u8, 32);
        defer allocator.free(buffer);

        @memset(buffer, '_');

        std.debug.print("buffer:       {s}\n", .{buffer});

        const string_start = buffer[0..10];
        const string_mid = buffer[11..21];
        const string_end = buffer[22..];

        @memcpy(string_start, "1234567890");
        @memcpy(buffer[11..21], "ABCDEFGHIJ");
        @memcpy(string_end, "abcdefghij");

        std.debug.print("string_start: {s}\n", .{string_start});
        std.debug.print("string_mid:   {s}\n", .{string_mid});
        std.debug.print("string_end:   {s}\n", .{string_end});
        std.debug.print("buffer:       {s}\n", .{buffer});
    }
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
}
//------------------------------------------------------------

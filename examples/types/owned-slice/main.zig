const std = @import("std");

const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";

pub fn createOwnedSlice(allocator: std.mem.Allocator) ![]u8 {
    //------------------------------------------------------------
    const string = "string";
    //------------------------------------------------------------
    const buffer = try allocator.alloc(u8, string.len);
    @memcpy(buffer, string);
    //------------------------------------------------------------
    return buffer;
    //------------------------------------------------------------
}

pub fn main() !void {
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
    const allocator1 = gpa.allocator();
    //------------------------------------------------------------
    const string1 = try createOwnedSlice(allocator1);
    defer allocator1.free(string1);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{string1});
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator2 = arena_allocator.allocator();
    //------------------------------------------------------------
    const string2 = try createOwnedSlice(allocator2);
    defer allocator2.free(string2);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{string2});
    //------------------------------------------------------------
}

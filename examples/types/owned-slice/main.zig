const std = @import("std");

pub fn createOwnedSlice1(allocator: std.mem.Allocator) ![]u8 {
    //------------------------------------------------------------
    const string = "string1";
    //------------------------------------------------------------
    const buffer = try allocator.alloc(u8, string.len);
    @memcpy(buffer, string);
    //------------------------------------------------------------
    return buffer;
    //------------------------------------------------------------
}

pub fn createOwnedSlice2(allocator: *std.mem.Allocator) ![]u8 {
    //------------------------------------------------------------
    const string = "string2";
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
    defer _ = gpa.deinit();
    const allocator1 = gpa.allocator();
    //------------------------------------------------------------
    const string1 = try createOwnedSlice1(allocator1);
    defer allocator1.free(string1);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{string1});
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    var allocator2 = arena_allocator.allocator();
    //------------------------------------------------------------
    const string2 = try createOwnedSlice2(&allocator2);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{string2});
    //------------------------------------------------------------
}

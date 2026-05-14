//-------------------------------------------------------------
const std = @import("std");
//-------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------
    const allocator = init.gpa;
    //----------------------------------------
    {
        //----------------------------------------
        // var entries = try std.ArrayList([]const u8).initCapacity(allocator, 0);
        var entries: std.ArrayList([]const u8) = .empty;
        //----------------------------------------
        defer entries.deinit(allocator);
        //----------------------------------------
        try entries.append(allocator, "1");
        try entries.append(allocator, "2");
        try entries.append(allocator, "3");
        //----------------------------------------
        for (entries.items) |item| {
            std.debug.print("{s}\n", .{item});
        }
        //----------------------------------------
    }
    //----------------------------------------
    {
        //----------------------------------------
        // var entries = try std.ArrayList([]const u8).initCapacity(allocator, 0);
        var entries: std.ArrayList([]const u8) = .empty;
        //----------------------------------------
        defer {
            // free "allocator.dupe" used below
            for (entries.items) |item| allocator.free(item);
            entries.deinit(allocator);
        }
        //----------------------------------------
        try entries.append(allocator, try allocator.dupe(u8, "A"));
        try entries.append(allocator, try allocator.dupe(u8, "B"));
        try entries.append(allocator, try allocator.dupe(u8, "C"));
        //----------------------------------------
        for (entries.items) |item| {
            std.debug.print("{s}\n", .{item});
        }
        //----------------------------------------
    }
    //----------------------------------------
}
//-------------------------------------------------------------

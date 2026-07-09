//-------------------------------------------------------------
const std = @import("std");
//-------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------

    const allocator = init.gpa;
    //--------------------------------------------------------------------------------
    std.debug.print("\n", .{});
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        //
        // stack key and values used
        //
        //------------------------------------------------------------
        var string_hash_map = std.StringHashMap([]const u8).init(allocator);
        defer string_hash_map.deinit();
        //----------------------------------------
        try string_hash_map.put("key1", "value1");
        try string_hash_map.put("key2", "value2");
        //----------------------------------------
        const value1 = string_hash_map.get("key1") orelse "";
        const value2 = string_hash_map.get("key2") orelse "";
        const valueX = string_hash_map.get("NOT_USED") orelse "";
        //----------------------------------------
        std.debug.print("value1 = {s}\n", .{value1});
        std.debug.print("value2 = {s}\n", .{value2});
        std.debug.print("valueX = {s}\n", .{valueX});
        std.debug.print("\n", .{});
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        //
        // HEAP ALLOCATED
        //
        // if key or value are heap allocated then you will also need to free that memory too
        //
        //------------------------------------------------------------
        var string_hash_map = std.StringHashMap([]const u8).init(allocator);
        defer {
            var it = string_hash_map.iterator();
            while (it.next()) |entry| {
                allocator.free(entry.key_ptr.*);
                allocator.free(entry.value_ptr.*);
            }

            string_hash_map.deinit();
        }
        //----------------------------------------
        try string_hash_map.put(
            try allocator.dupe(u8, "key1"),
            try allocator.dupe(u8, "value1"),
        );
        try string_hash_map.put(
            try allocator.dupe(u8, "key2"),
            try allocator.dupe(u8, "value2"),
        );
        //----------------------------------------
        const value1 = string_hash_map.get("key1") orelse "";
        const value2 = string_hash_map.get("key2") orelse "";
        const valueX = string_hash_map.get("NOT_USED") orelse "";
        //----------------------------------------
        std.debug.print("value1 = {s}\n", .{value1});
        std.debug.print("value2 = {s}\n", .{value2});
        std.debug.print("valueX = {s}\n", .{valueX});
        std.debug.print("\n", .{});
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
}
//-------------------------------------------------------------

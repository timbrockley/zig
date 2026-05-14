//-------------------------------------------------------------
const std = @import("std");
//-------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------
    const allocator = init.gpa;
    //----------------------------------------
    var map = std.StringHashMap([]const u8).init(allocator);
    defer map.deinit();
    //----------------------------------------
    try map.put("key1", "value1");
    try map.put("key2", "value2");
    //----------------------------------------
    const value1 = map.get("key1") orelse "";
    const value2 = map.get("key2") orelse "";
    const valueX = map.get("NOT_USED") orelse "";
    //----------------------------------------
    std.debug.print("value1 = {s}\n", .{value1});
    std.debug.print("value2 = {s}\n", .{value2});
    std.debug.print("valueX = {s}\n", .{valueX});
    //----------------------------------------
}
//-------------------------------------------------------------

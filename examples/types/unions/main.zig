const std = @import("std");
const unittest = @import("libs/unittest.zig");
//-------------------------------------------------------------
// cannot store null value so void used in it's place
// consider using an optional instead
const Value = union(enum) {
    //-------------------------------------------------------------
    null: void,
    integer: i64,
    float: f64,
    string: []const u8,
    //-------------------------------------------------------------
    pub fn is(self: Value, tag: std.meta.Tag(Value)) bool {
        return self == tag;
    }
    //-------------------------------------------------------------
    pub fn get(self: Value, comptime T: type) T {
        return switch (self) {
            .null => std.mem.zeroes(T),
            .integer => |value| switch (@typeInfo(T)) {
                .int => @intCast(value),
                .float => @floatFromInt(value),
                else => std.mem.zeroes(T),
            },
            .float => |value| switch (@typeInfo(T)) {
                .int => @intFromFloat(value),
                .float => @floatCast(value),
                else => std.mem.zeroes(T),
            },
            .string => |value| switch (T) {
                []const u8 => value,
                []u8 => @constCast(value),
                else => std.mem.zeroes(T),
            },
        };
    }
    //-------------------------------------------------------------
    pub fn getWithError(self: Value, comptime T: type) !T {
        return switch (self) {
            .null => switch (@typeInfo(T)) {
                .optional => null,
                else => return error.InvalidType,
            },
            .integer => |value| if (T == i64) value else error.InvalidType,
            .float => |value| if (T == f64) value else error.InvalidType,
            .string => |value| switch (T) {
                []const u8 => value,
                []u8 => @constCast(value),
                else => error.InvalidType,
            },
        };
    }
    //-------------------------------------------------------------
    pub fn getNullString(self: Value) ?[]const u8 {
        return if (self == .string) self.string else null;
    }
    //-------------------------------------------------------------
    pub fn getString(self: Value) []const u8 {
        return if (self == .string) self.string else "";
    }
    //-------------------------------------------------------------
    pub fn getInteger(self: Value) i64 {
        return if (self == .integer) self.integer else 0;
    }
    //-------------------------------------------------------------
    pub fn getFloat(self: Value) f64 {
        return if (self == .float) self.float else 0;
    }
    //-------------------------------------------------------------
};
//-------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //-------------------------------------------------------------
    var ut = try unittest.init(.{ .io = init.io });
    //-------------------------------------------------------------
    try ut.compareInteger("@sizeOf(Value)", 24, @sizeOf(Value));
    //-------------------------------------------------------------
    var value: Value = undefined;
    //-------------------------------------------------------------
    {
        value = .{ .string = "getNullString" };

        try ut.compareStringSlice("value.getNullString()", "getNullString", value.getNullString().?);

        value = .{ .null = {} };

        try ut.compareNull("value.getNullString()", value.getNullString());
    }
    //-------------------------------------------------------------
    {
        value = .{ .string = "getString" };

        try ut.compareStringSlice("value.getString()", "getString", value.getString());

        value = .{ .null = {} };

        try ut.compareStringSlice("value.getString()", "", value.getString());
    }
    //-------------------------------------------------------------
    {
        value = .{ .integer = 42 };

        try ut.compareInteger("value.getInteger()", 42, value.getInteger());

        value = .{ .null = {} };

        try ut.compareInteger("value.getInteger()", 0, value.getInteger());
    }
    //-------------------------------------------------------------
    {
        value = .{ .float = 42.42 };

        try ut.compareFloat("value.getFloat()", 42.42, value.getFloat());

        value = .{ .null = {} };

        try ut.compareFloat("value.getFloat()", 0, value.getFloat());
    }
    //-------------------------------------------------------------
    {
        value = .{ .null = {} };

        try ut.compareBool("value.is(.null)", true, value.is(.null));
        try ut.compareEnum("std.meta.activeTag(value)", Value.null, std.meta.activeTag(value));

        try ut.compareNull("value.get(?void)", value.get(?void));
    }
    //-------------------------------------------------------------
    {
        value = .{ .integer = 42 };

        try ut.compareBool("value.is(.integer)", true, value.is(.integer));
        try ut.compareEnum("std.meta.activeTag(value)", Value.integer, std.meta.activeTag(value));
        try ut.compareType("@TypeOf(value.integer)", i64, @TypeOf(value.integer));

        try ut.compareFloat("value.get(f64)", 42, value.get(f64));
        try ut.compareInteger("value.get(i64)", 42, value.get(i64));
        try ut.compareStringSlice("value.get([]const u8)", "", value.get([]const u8));
        try ut.compareNull("value.get(?void)", value.get(?void));

        try ut.compareType("@TypeOf(value.get(f32))", f32, @TypeOf(value.get(f32)));
        try ut.compareType("@TypeOf(value.get(i32))", i32, @TypeOf(value.get(i32)));
        try ut.compareType("@TypeOf(value.get([]const u8))", []const u8, @TypeOf(value.get([]const u8)));
    }
    //-------------------------------------------------------------
    {
        value = .{ .float = 3.142 };

        try ut.compareBool("value.is(.float)", true, value.is(.float));
        try ut.compareEnum("std.meta.activeTag(value)", Value.float, std.meta.activeTag(value));
        try ut.compareType("@TypeOf(value.float)", f64, @TypeOf(value.float));

        try ut.compareFloat("value.get(f64)", 3.142, value.get(f64));
        try ut.compareType("@TypeOf(value.get(f32))", f32, @TypeOf(value.get(f32)));
    }
    //-------------------------------------------------------------
    {
        value = .{ .string = "get" };

        try ut.compareBool("value.is(.string)", true, value.is(.string));
        try ut.compareEnum("std.meta.activeTag(value)", Value.string, std.meta.activeTag(value));
        try ut.compareType("@TypeOf(value.string)", []const u8, @TypeOf(value.string));

        try ut.compareStringSlice("value.get([]const u8)", "get", value.get([]const u8));
        try ut.compareStringSlice("value.get([]u8)", "get", value.get([]u8));

        try ut.compareFloat("value.get(f64)", 0, value.get(f64));
        try ut.compareType("@TypeOf(value.get(f32))", f32, @TypeOf(value.get(f32)));

        try ut.compareNull("value.get(?void)", value.get(?void));
    }
    //-------------------------------------------------------------
    {
        value = .{ .string = "getWithError" };

        try ut.compareStringSlice("value.getWithError([]const u8)", "getWithError", try value.getWithError([]const u8));
        try ut.compareStringSlice("value.getWithError([]u8)", "getWithError", try value.getWithError([]u8));

        value = .{ .null = {} };

        try ut.compareNull("value.getWithError(?void)", try value.getWithError(?void));
        try ut.compareNull("value.getWithError(?[]const u8)", try value.getWithError(?[]const u8));
        try ut.compareNull("value.getWithError(?u8)", try value.getWithError(?u8));

        _ = value.getWithError(u8) catch |err| try ut.compareError("value.getWithError(u8)", error.InvalidType, err);
        _ = value.getWithError(i32) catch |err| try ut.compareError("value.getWithError(i32)", error.InvalidType, err);
    }
    //-------------------------------------------------------------
    try ut.printSummary();
    //-------------------------------------------------------------
}
//-------------------------------------------------------------

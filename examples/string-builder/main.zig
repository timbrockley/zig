const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var sb = StringBuilder.init(allocator);
    defer sb.deinit();

    try sb.append("Hello");
    try sb.append(", ");
    try sb.appendFmt("{s}! The answer is {}.", .{ "World", 42 });

    const result = sb.toSlice();

    std.debug.print("{s}\n", .{result});
}

pub const StringBuilder = struct {
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) StringBuilder {
        return .{
            .allocator = allocator,
            .buffer = std.ArrayList(u8){},
        };
    }

    pub fn deinit(self: *StringBuilder) void {
        self.buffer.deinit(self.allocator);
    }

    pub fn append(self: *StringBuilder, bytes: []const u8) !void {
        try self.buffer.appendSlice(self.allocator, bytes);
    }

    pub fn appendByte(self: *StringBuilder, byte: u8) !void {
        try self.buffer.append(self.allocator, byte);
    }

    pub fn appendFmt(
        self: *StringBuilder,
        comptime fmt: []const u8,
        args: anytype,
    ) !void {
        try self.buffer.writer(self.allocator).print(fmt, args);
    }

    pub fn toSlice(self: *StringBuilder) []const u8 {
        return self.buffer.items;
    }

    pub fn toOwnedSlice(self: *StringBuilder) ![]u8 {
        return self.buffer.toOwnedSlice(self.allocator);
    }

    pub fn clear(self: *StringBuilder) void {
        self.buffer.clearRetainingCapacity();
    }
};

//-------------------------------------------------------------
const std = @import("std");
//-------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------
    const allocator = init.arena.allocator();
    //----------------------------------------
    {
        const array1: []const u8 = "test";
        std.debug.print("array1: {s}\n", .{array1});

        const array2: []u8 = try allocator.dupe(u8, array1);
        std.debug.print("array2: {s}\n", .{array2});

        const array3: []u8 = try allocator.alloc(u8, array1.len);
        @memcpy(array3, array1);
        std.debug.print("array3: {s}\n", .{array3});
    }
    //----------------------------------------
    {
        const rows = 3;
        const cols = 4;

        // allocted memory
        const data = try allocator.alloc(u8, rows * cols);

        // pointers
        const matrix: [][]u8 = try allocator.alloc([]u8, rows);

        for (matrix, 0..) |*row, index| {
            row.* = data[index * cols .. (index + 1) * cols];

            @memset(row.*, 'A' + @as(u8, @intCast(index)));

            std.debug.print("row: {s}\n", .{row.*});
        }
    }
    //----------------------------------------
}
//-------------------------------------------------------------

//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
pub fn main() !void {
    //------------------------------------------------------------
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        // defer _ = gpa.deinit();
        defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
        const allocator = gpa.allocator();

        const size: usize = 1024;
        const buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);
    }
    //------------------------------------------------------------
    {
        var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena_allocator.deinit();
        const allocator = arena_allocator.allocator();

        const size: usize = 1024;
        const buffer = try allocator.alloc(u8, size);
        defer allocator.free(buffer);
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

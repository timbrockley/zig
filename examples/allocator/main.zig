//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
pub fn main() !void {
    //------------------------------------------------------------
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        _ = allocator;
    }
    //------------------------------------------------------------
    {
        var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena_allocator.deinit();
        const allocator = arena_allocator.allocator();

        _ = allocator;
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

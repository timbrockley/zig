//--------------------------------------------------------------------------------
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------

const std = @import("std");

//--------------------------------------------------------------------------------

pub fn getTuple(num: u32) (struct { u32, u32 }) {
    return .{ num, num + 1 };
}

pub fn getAnonymousStruct(num: u32) (struct { x: u32, y: u32 }) {
    return .{ .x = num, .y = num + 1 };
}

//--------------------------------------------------------------------------------

pub const ExampleStruct = struct {
    x: u32,
    y: u32,
};

pub fn getStruct(num: u32) ExampleStruct {
    return ExampleStruct{ .x = num, .y = num + 1 };
}

//--------------------------------------------------------------------------------

pub fn main() !void {
    //------------------------------------------------------------
    {
        const result = getTuple(11);
        std.debug.print("x: {}, y: {}\n", .{ result[0], result[1] });
    }
    //------------------------------------------------------------
    {
        const x, const y = getTuple(21);
        std.debug.print("x: {}, y: {}\n", .{ x, y });
    }
    //------------------------------------------------------------
    {
        const result = getAnonymousStruct(31);
        std.debug.print("x: {}, y: {}\n", .{ result.x, result.y });
    }
    //------------------------------------------------------------
    {
        const result = getStruct(41);
        std.debug.print("x: {}, y: {}\n", .{ result.x, result.y });
    }
    //------------------------------------------------------------
}

//--------------------------------------------------------------------------------

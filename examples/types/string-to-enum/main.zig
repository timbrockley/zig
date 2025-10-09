const std = @import("std");

const Color = enum {
    red,
    blue,
    green,
};

pub fn main() !void {
    const color = std.meta.stringToEnum(Color, "red") orelse {
        return error.None;
    };

    switch (color) {
        .red => std.debug.print("red\n", .{}),
        .blue => std.debug.print("blue\n", .{}),
        .green => std.debug.print("green\n", .{}),
    }
}

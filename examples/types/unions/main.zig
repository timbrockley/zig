const std = @import("std");

const Value = union(enum) {
    number: u32,
    null: void,
};

pub fn main() void {
    var value: Value = undefined;

    value = Value{ .number = 42 };
    printValue(value);

    value = Value{ .null = {} };
    printValue(value);
}

fn printValue(value: Value) void {
    switch (value) {
        .number => |v| {
            std.debug.print("hello, value = {}\n", .{v});
        },
        .null => {
            std.debug.print("hello, value = null\n", .{});
        },
    }
}

//----------------------------------------------------------------------
const std = @import("std");
//----------------------------------------------------------------------
const CustomError = error{ DivisionByZero, NegativeInput };
//----------------------------------------------------------------------
fn safeDivide(a: f64, b: f64) f64 {
    return if (b == 0) 0 else a / b;
}
//----------------------------------------------------------------------
fn divideWithErrors(a: f64, b: f64) !f64 {
    if (b == 0) return CustomError.DivisionByZero;
    if (a < 0 or b < 0) return CustomError.NegativeInput;
    return a / b;
}
//----------------------------------------------------------------------
pub fn main() !void {
    //----------------------------------------
    if (std.os.argv.len <= 1) {
        //----------------------------------------
        std.debug.print("usage:", .{});
        std.debug.print("\tzig run main.zig -- <FLOAT1> <FLOAT2>\n", .{});
        std.debug.print("\tzig test main.zig\n", .{});
        //----------------------------------------
    } else {
        //----------------------------------------
        var it = std.process.args();
        _ = it.skip();
        //----------------------------------------
        const arg_a = if (it.next()) |a| a else "1.0";
        const a = try std.fmt.parseFloat(f64, arg_a);
        //----------------------------------------
        const arg_b = if (it.next()) |b| b else "2.0";
        const b = try std.fmt.parseFloat(f64, arg_b);
        //----------------------------------------
        const result = safeDivide(a, b);
        //----------------------------------------
        std.debug.print("{d:.2} / {d:.2} = {d:.2}\n", .{ a, b, result });
        //----------------------------------------
    }
    //----------------------------------------
}
//----------------------------------------------------------------------
test "safeDivide" {
    try std.testing.expect(safeDivide(0, 0) == 0);
    try std.testing.expect(safeDivide(1, 0) == 0);
    try std.testing.expect(safeDivide(0, 1) == 0);
    try std.testing.expect(safeDivide(1, 1) == 1);
    try std.testing.expect(safeDivide(-1, 1) == -1);
    try std.testing.expect(safeDivide(1, -1) == -1);
    try std.testing.expect(safeDivide(-1, -1) == 1);
}

test "DivisionByZero" {
    if (divideWithErrors(1, 1)) |result| {
        try std.testing.expect(result == 1); // should have returned 1
    } else |_| {
        try std.testing.expect(false); // should not have returned an error
    }

    if (divideWithErrors(1, 0)) |_| {
        try std.testing.expect(false); // should have returned an error
    } else |e| {
        try std.testing.expect(e == CustomError.DivisionByZero); // should have returned an error
    }
}

test "NegativeInput" {
    if (divideWithErrors(0, 1)) |result| {
        try std.testing.expect(result == 0); // should have returned 0
    } else |_| {
        try std.testing.expect(false); // should not have returned an error
    }

    if (divideWithErrors(1, 1)) |result| {
        try std.testing.expect(result == 1); // should have returned 1
    } else |_| {
        try std.testing.expect(false); // should not have returned an error
    }

    if (divideWithErrors(-1, 1)) |_| {
        try std.testing.expect(false); // should have returned an error
    } else |e| {
        try std.testing.expect(e == CustomError.NegativeInput); // should have returned an error
    }

    if (divideWithErrors(1, -1)) |_| {
        try std.testing.expect(false); // should have returned an error
    } else |e| {
        try std.testing.expect(e == CustomError.NegativeInput); // should have returned an error
    }
}
//----------------------------------------------------------------------

const std = @import("std");

pub fn main() !void {
    var output: [10]u8 = [_]u8{0} ** 10;

    var output_index: usize = 0;

    try appendOutputBuffer(&output, &output_index, 0);
    try appendOutputBuffer(&output, &output_index, 1);
    try appendOutputBuffer(&output, &output_index, 2);
    try appendOutputBuffer(&output, &output_index, 3);

    std.debug.print("{any}\n", .{output});

    xorOutput(&output);

    std.debug.print("{any}\n", .{output});
}

fn appendOutputBuffer(output: []u8, output_index: *usize, byte: u8) !void {
    if (output_index.* >= output.len) return error.BufferOverflow;
    output[output_index.*] = byte;
    output_index.* += 1;
}

fn xorOutput(output: []u8) void {
    for (output[0..output.len]) |*pad| pad.* ^= 0b01010101;
}

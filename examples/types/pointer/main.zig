const std = @import("std");

pub fn main() !void {
    var output: [10]u8 = [_]u8{0} ** 10;

    var outputIndex: usize = 0;

    try appendOutputBuffer(&output, &outputIndex, 0);
    try appendOutputBuffer(&output, &outputIndex, 1);
    try appendOutputBuffer(&output, &outputIndex, 2);
    try appendOutputBuffer(&output, &outputIndex, 3);

    std.debug.print("{any}\n", .{output});

    xorOutput(&output);

    std.debug.print("{any}\n", .{output});
}

fn appendOutputBuffer(output: []u8, outputIndex: *usize, byte: u8) !void {
    if (outputIndex.* >= output.len) return error.BufferOverflow;
    output[outputIndex.*] = byte;
    outputIndex.* += 1;
}

fn xorOutput(output: []u8) void {
    for (output[0..output.len]) |*pad| pad.* ^= 0b01010101;
}

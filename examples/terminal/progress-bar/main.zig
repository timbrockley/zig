const std: type = @import("std");
//------------------------------------------------------------
const MAX_LEN: u8 = 10;
const DURATION: u64 = 100;
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    var stdout_writer = std.Io.File.Writer.init(.stdout(), init.io, &.{});
    const stdout = &stdout_writer.interface;
    //------------------------------------------------------------
    var bar_index: u8 = 1;

    var bar: [MAX_LEN]u8 = undefined;

    for (0..3 * MAX_LEN) |_| {
        fillBar(&bar, bar_index);

        try stdout.print("\rProgress Bar Example [{s}]", .{bar});

        bar_index = if (bar_index < MAX_LEN) bar_index + 1 else 1;

        try init.io.sleep(.fromMilliseconds(DURATION), .awake);
    }
    //------------------------------------------------------------
    try stdout.writeAll("\r\x1b[2K"); // carriage return + clear line
    //------------------------------------------------------------
}
//------------------------------------------------------------
fn fillBar(bar: *[MAX_LEN]u8, bar_index: u8) void {
    const index: u8 = if (bar_index < MAX_LEN) bar_index else MAX_LEN;
    for (bar[0..index]) |*b| {
        b.* = '.';
    }
    for (bar[index..]) |*b| {
        b.* = ' ';
    }
}
//------------------------------------------------------------

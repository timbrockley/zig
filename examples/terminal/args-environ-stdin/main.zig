//----------------------------------------------------------------------
const std = @import("std");
//----------------------------------------------------------------------
const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
const line = [_]u8{'-'} ** 60;
//----------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
    var it = init.minimal.args.iterate();
    // _ = it.skip();
    //----------------------------------------
    var index: usize = 0;
    while (it.next()) |arg| {
        std.debug.print("arg[{d}]: {s}\n", .{ index, arg });
        index += 1;
    }
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
    const allocator = gpa.allocator();
    //----------------------------------------
    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);
    //----------------------------------------
    std.debug.print("args.len: {d}\n", .{args.len});
    //----------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------
    for (0..args.len) |i| {
        std.debug.print("arg[{d}]: {s}\n", .{ i, args[i] });
    }
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
    if (init.environ_map.get("HOME")) |home| {
        std.debug.print("HOME: {s}\n", .{home});
    } else {
        std.debug.print("HOME not set\n", .{});
    }
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
    const stdin_file = std.Io.File.stdin();
    const stdin_stat = try stdin_file.stat(init.io);

    if (stdin_stat.kind == .character_device) std.debug.print("enter stdin (ctrl + D to end): ", .{});

    var read_buffer: [1024]u8 = undefined;
    var file_reader = stdin_file.reader(init.io, &read_buffer);

    var data = std.ArrayList(u8){};
    defer data.deinit(allocator);

    try std.Io.Reader.appendRemainingUnlimited(&file_reader.interface, allocator, &data);

    if (stdin_stat.kind == .character_device) std.debug.print("\n", .{});
    std.debug.print("stdin ({d} bytes): [{s}]\n", .{ data.items.len, data.items });
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
}
//----------------------------------------------------------------------

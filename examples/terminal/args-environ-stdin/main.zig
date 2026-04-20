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
    const allocator = init.gpa;
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
    //----------------------------------------------------------------------
    var stdin_read_buffer: [1024]u8 = undefined;
    var stdin_file_reader = stdin_file.reader(init.io, &stdin_read_buffer);
    //----------------------------------------------------------------------
    // const stdin_stat = try stdin_file.stat(init.io);
    // if (stdin_stat.kind == .character_device) std.debug.print("enter stdin: ", .{});
    if (try stdin_file.isTty(init.io)) {
        //----------------------------------------------------------------------
        std.debug.print("enter stdin: ", .{});

        const data = try stdin_file_reader.interface.takeDelimiterExclusive('\n');

        std.debug.print("stdin ({d} bytes): [{s}]\n", .{ data.len, data });
        //----------------------------------------------------------------------
    } else {
        //----------------------------------------------------------------------
        var data = try std.ArrayList(u8).initCapacity(allocator, 0);
        defer data.deinit(allocator);

        try std.Io.Reader.appendRemainingUnlimited(&stdin_file_reader.interface, allocator, &data);

        std.debug.print("stdin ({d} bytes): [{s}]\n", .{ data.items.len, data.items });
        //----------------------------------------------------------------------
    }
    //----------------------------------------------------------------------
    std.debug.print("{s}\n", .{line});
    //----------------------------------------------------------------------
}
//----------------------------------------------------------------------

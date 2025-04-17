const std = @import("std");

pub fn main() !void {
    //----------------------------------------
    // quicker compilation and a smaller compiled binary
    // no memory allocation required and uses an iterator to return args
    //----------------------------------------
    var it = std.process.args();
    _ = it.skip();

    const arg_a = if (it.next()) |a| a else "1";
    const a = try std.fmt.parseInt(u32, arg_a, 10);

    const arg_b = if (it.next()) |b| b else "2";
    const b = try std.fmt.parseInt(u32, arg_b, 10);

    const result: u32 = a + b;

    std.debug.print("{d} + {d} = {d}\n", .{ a, b, result });
    //----------------------------------------
    // // slower compilation and a larger compiled binary
    // // uses memory allocation and returns a slice or args stored on the heap
    // //----------------------------------------
    // const allocator = std.heap.page_allocator;
    // const args = try std.process.argsAlloc(allocator);
    // defer std.process.argsFree(allocator, args);

    // const a: u32 = if (args.len > 1) try std.fmt.parseInt(u32, args[1], 10) else 1;
    // const b: u32 = if (args.len > 2) try std.fmt.parseInt(u32, args[2], 10) else 2;

    // const result: u32 = a + b;

    // std.debug.print("{d} + {d} = {d}\n", .{ a, b, result });
    //----------------------------------------
}

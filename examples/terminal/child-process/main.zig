//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const allocator = init.gpa;
    //------------------------------------------------------------
    const runOptions = std.process.RunOptions{
        .argv = &[_][]const u8{ "ls", "-la" },
    };
    //------------------------------------------------------------
    const runResult = std.process.run(
        allocator,
        init.io,
        runOptions,
    ) catch |err| {
        return err;
    };
    defer {
        allocator.free(runResult.stdout);
        allocator.free(runResult.stderr);
    }
    //------------------------------------------------------------
    // (2005) => in testing .exited did not always exist
    const exit_code = switch (runResult.term) {
        .exited => runResult.term.exited,
        else => 1,
    };
    //------------------------------------------------------------
    std.debug.print("exit_code: {d}\n", .{exit_code});
    //------------------------------------------------------------
    std.debug.print("\nterm: {any}\n", .{runResult.term});
    std.debug.print("\nstdout:\n {s}\n", .{runResult.stdout});
    std.debug.print("stderr:\n {s}\n", .{runResult.stderr});
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------

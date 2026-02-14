//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    const allocator = init.arena.allocator();
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
        // std.debug.print("Failed to run child process: {any}\n", .{err});
        return err;
    };
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

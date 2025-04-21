const std = @import("std");

pub fn main() !void {
    const log = std.log;

    // "debug", "info" and "warn" only output if compiled in debug mode
    log.debug("This is a debug message, will only show in debug builds", .{});
    log.info("This is an info message", .{});
    log.warn("This is a warning message", .{});

    log.err("This is an error message", .{});
}

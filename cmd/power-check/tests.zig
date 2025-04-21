const std = @import("std");
const builtin = @import("builtin");

const pc = @import("main.zig");

comptime {
    switch (builtin.os.tag) {
        .linux, .macos => _ = @import("tests_linux_macos.zig"),
        .windows => _ = @import("tests_windows.zig"),
        else => @compileError("Unsupported OS"),
    }
}

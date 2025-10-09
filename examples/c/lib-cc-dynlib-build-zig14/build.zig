const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "math",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFiles(.{ .files = &.{"src/math.c"} });

    b.installArtifact(lib);

    const install_lib = b.addInstallArtifact(lib, .{
        .dest_dir = .{
            .override = .{ .custom = "." },
        },
    });
    b.default_step.dependOn(&install_lib.step);

    const exe = b.addExecutable(.{
        .name = "lib-cc-dynlib-build",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const install_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{
            .override = .{ .custom = "." },
        },
    });
    b.default_step.dependOn(&install_exe.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

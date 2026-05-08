//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------
pub fn build(b: *std.Build) void {
    //------------------------------------------------------------
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    //------------------------------------------------------------
    {
        const lib = b.addLibrary(.{
            .name = "lib-shared",
            .linkage = .dynamic,
            .root_module = b.createModule(.{
                .root_source_file = b.path("root.zig"),
                .target = target,
                .optimize = optimize,
            }),
        });

        const install_lib = b.addInstallArtifact(lib, .{
            .dest_dir = .{ .override = .{ .custom = "." } },
        });
        b.getInstallStep().dependOn(&install_lib.step);

        // b.installArtifact(lib);
    }
    //------------------------------------------------------------
    {
        const lib = b.addLibrary(.{
            .name = "lib-static",
            .linkage = .static,
            .root_module = b.createModule(.{
                .root_source_file = b.path("root.zig"),
                .target = target,
                .optimize = optimize,
            }),
        });

        const install_lib = b.addInstallArtifact(lib, .{
            .dest_dir = .{ .override = .{ .custom = "." } },
        });
        b.getInstallStep().dependOn(&install_lib.step);

        // b.installArtifact(lib);
    }
    //------------------------------------------------------------
}
//------------------------------------------------------------

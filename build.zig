const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Translate the C header into an importable Zig module
    const pa_translate = b.addTranslateC(.{
        .root_source_file = b.path("libs/portaudio/include/portaudio.h"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "keyboard",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "portaudio", .module = pa_translate.createModule() },
            },
        }),
    });

    exe.root_module.addObjectFile(b.path("libs/portaudio/libportaudio.a"));
    exe.root_module.linkSystemLibrary("asound", .{});
    exe.root_module.linkSystemLibrary("m", .{});
    // Only if your ./configure found JACK:
    // exe.root_module.linkSystemLibrary("jack", .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the synth");
    run_step.dependOn(&run_cmd.step);
}

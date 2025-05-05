const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "TinySQL",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);

    const bench_exe = b.addExecutable(.{
        .name = "Bench",
        .root_source_file = b.path("src/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(bench_exe);
    const run_bench_step = b.step("bench", "Build the benchmark");
    run_bench_step.dependOn(&bench_exe.step);

    const test_cmd = b.addSystemCommand(&.{ "sh", "-c", "zig test src/main.zig 2>&1 | cat" });
    const test_step = b.step("test", "Run unit tests"); // https://github.com/ziglang/zig/issues/10203
    test_step.dependOn(&test_cmd.step);
}

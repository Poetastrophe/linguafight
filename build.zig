const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("linguafight", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const main_tests = b.addTest("src/main.zig");
    main_tests.setTarget(target);
    main_tests.setBuildMode(mode);
    const binom_tests = b.addTest("src/BinomialPermutations.zig");
    binom_tests.setTarget(target);
    binom_tests.setBuildMode(mode);
    const perm_tests = b.addTest("src/PermutationIterator.zig");
    perm_tests.setTarget(target);
    perm_tests.setBuildMode(mode);
    const wordlist_tests = b.addTest("src/WordList.zig");
    wordlist_tests.setTarget(target);
    wordlist_tests.setBuildMode(mode);
    const lingua_tests = b.addTest("src/LinguaFight.zig");
    lingua_tests.setTarget(target);
    lingua_tests.setBuildMode(mode);


    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&binom_tests.step);
    test_step.dependOn(&perm_tests.step);
    test_step.dependOn(&wordlist_tests.step);
    // test_step.dependOn(&lingua_tests.step);
}

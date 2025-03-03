const std = @import("std");

const parts = @import("parts.zig");
const filter = @import("filter.zig");
const full = @import("full.zig");

const print = std.debug.print;

pub fn main() !void {
    const start_timestamp = std.time.milliTimestamp();

    print("\nrunning\n", .{});

    filter.initAllocator();
    defer filter.aa.deinit();

    // comment or uncomment these to decide which functions to run
    //
    filter.main(); // fast: latest and greatest
    //filter.test1(); // slow: brute-force accuracy testing
    //filter.test2(); // fast: smaller implementation of new method
    //try full.main(); // slow: old high-functionality brute-force method

    print("\n\nfinished in {d} seconds\n\n", .{@as(f32, @floatFromInt(std.time.milliTimestamp() - start_timestamp)) / @as(f32, @floatFromInt(std.time.ms_per_s))});
}

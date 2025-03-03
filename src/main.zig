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

    filter.main();
    //filter.test1();
    //filter.test2();
    //try full.main();

    print("\n\nfinished in {d} seconds\n\n", .{@as(f32, @floatFromInt(std.time.milliTimestamp() - start_timestamp)) / @as(f32, @floatFromInt(std.time.ms_per_s))});
}

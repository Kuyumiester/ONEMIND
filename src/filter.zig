//
//
//      this file contains newer code, that takes advantage of an equation i've
//      been developing to come to an answer much faster. it's still naive,
//      but it's much much faster than brute force methods. brute-force methods
//      in this file are for making sure the experimental methods are correct.
//
//

const std = @import("std");
const print = std.debug.print;
const parts = @import("parts.zig");

// y = ap
// x = weight
// y = mx + b
// m = (a1-a2)/(b1-b2)
// b = m * b1 - a1  or  m * b2 - a2    OR    (a1*b2 - a2*b1)/(b1-b2)
// x intercept: (1/m) * a1 - b1

//
//      find all viable frame sets for ap/weight (ignoring all other factors)
//
pub fn main() void {

    //
    //      find all viable head parts
    //
    outer: for (parts.head_array, 0..) |outer_p, outer_i| {
        const a1: f32 = @as(f32, @floatFromInt(outer_p.ap));
        const b1: f32 = @as(f32, @floatFromInt(outer_p.weight));
        var ceiling: f32 = 99999;
        var floor: f32 = 0;
        for (parts.head_array, 0..) |inner_p, inner_i| {
            if (outer_i == inner_i) {
                continue;
            }
            const a2: f32 = @as(f32, @floatFromInt(inner_p.ap));
            const b2: f32 = @as(f32, @floatFromInt(inner_p.weight));
            const slope = (a1 - a2) / (b1 - b2);
            if (b1 < b2) { // outer part is better "above" the line
                if (slope > floor) {
                    floor = slope;
                    if (ceiling < floor) continue :outer;
                }
            } else { // outer part is better "below" the line
                if (slope < ceiling) {
                    ceiling = slope;
                    if (ceiling < floor) continue :outer;
                }
            }
        }
        filtered_head_array[filtered_head_array_length] = outer_p;
        filtered_head_array_length += 1;
    }

    //
    //      find all viable core parts
    //
    outer: for (parts.core_array, 0..) |outer_p, outer_i| {
        const a1: f32 = @as(f32, @floatFromInt(outer_p.ap));
        const b1: f32 = @as(f32, @floatFromInt(outer_p.weight));
        var ceiling: f32 = 99999;
        var floor: f32 = 0;
        for (parts.core_array, 0..) |inner_p, inner_i| {
            if (outer_i == inner_i) { // there are more redundant calculations than this that we can optimize out
                continue;
            }
            const a2: f32 = @as(f32, @floatFromInt(inner_p.ap));
            const b2: f32 = @as(f32, @floatFromInt(inner_p.weight));
            const slope = (a1 - a2) / (b1 - b2);
            if (b1 < b2) { // outer part is better "above" the line
                if (slope > floor) {
                    floor = slope;
                    if (ceiling < floor) continue :outer;
                }
            } else { // outer part is better "below" the line
                if (slope < ceiling) {
                    ceiling = slope;
                    if (ceiling < floor) continue :outer;
                }
            }
        }
        filtered_core_array[filtered_core_array_length] = outer_p;
        filtered_core_array_length += 1;
    }

    //
    //      find all viable arm parts
    //
    outer: for (parts.arms_array, 0..) |outer_p, outer_i| {
        const a1: f32 = @as(f32, @floatFromInt(outer_p.ap));
        const b1: f32 = @as(f32, @floatFromInt(outer_p.weight));
        var ceiling: f32 = 99999;
        var floor: f32 = 0;
        for (parts.arms_array, 0..) |inner_p, inner_i| {
            if (outer_i == inner_i) { // there are more redundant calculations than this that we can optimize out
                continue;
            }
            const a2: f32 = @as(f32, @floatFromInt(inner_p.ap));
            const b2: f32 = @as(f32, @floatFromInt(inner_p.weight));
            const slope = (a1 - a2) / (b1 - b2);
            if (b1 < b2) { // outer part is better "above" the line
                if (slope > floor) {
                    floor = slope;
                    if (ceiling < floor) continue :outer;
                }
            } else { // outer part is better "below" the line
                if (slope < ceiling) {
                    ceiling = slope;
                    if (ceiling < floor) continue :outer;
                }
            }
        }
        filtered_arms_array[filtered_arms_array_length] = outer_p;
        filtered_arms_array_length += 1;
    }

    //
    //      find all viable leg parts
    //
    outer: for (parts.legs_array, 0..) |outer_p, outer_i| {
        const a1: f32 = @as(f32, @floatFromInt(outer_p.ap));
        const b1: f32 = @as(f32, @floatFromInt(outer_p.weight));
        var ceiling: f32 = 99999;
        var floor: f32 = 0;
        for (parts.legs_array, 0..) |inner_p, inner_i| {
            if (outer_i == inner_i) { // there are more redundant calculations than this that we can optimize out
                continue;
            }
            const a2: f32 = @as(f32, @floatFromInt(inner_p.ap));
            const b2: f32 = @as(f32, @floatFromInt(inner_p.weight));
            const slope = (a1 - a2) / (b1 - b2);
            if (b1 < b2) { // outer part is better "above" the line
                if (slope > floor) {
                    floor = slope;
                    if (ceiling < floor) continue :outer;
                }
            } else { // outer part is better "below" the line
                if (slope < ceiling) {
                    ceiling = slope;
                    if (ceiling < floor) continue :outer;
                }
            }
        }
        filtered_legs_array[filtered_legs_array_length] = outer_p;
        filtered_legs_array_length += 1;
    }

    //
    //      print viable parts
    //
    print("\nheads", .{});
    for (filtered_head_array[0..filtered_head_array_length]) |e| {
        print("\n{s}", .{e.name});
    }
    print("\n\ncores", .{});
    for (filtered_core_array[0..filtered_core_array_length]) |e| {
        print("\n{s}", .{e.name});
    }
    print("\n\narms", .{});
    for (filtered_arms_array[0..filtered_arms_array_length]) |e| {
        print("\n{s}", .{e.name});
    }
    print("\n\nlegs", .{});
    for (filtered_legs_array[0..filtered_legs_array_length]) |e| {
        print("\n{s}", .{e.name});
    }

    print("\n\n======================================\n", .{});

    //
    //      find all viable sets of frame parts
    //
    for (filtered_head_array[0..filtered_head_array_length], 0..) |outer_head_p, outer_head_i| {
        for (filtered_core_array[0..filtered_core_array_length], 0..) |outer_core_p, outer_core_i| {
            for (filtered_arms_array[0..filtered_arms_array_length], 0..) |outer_arms_p, outer_arms_i| {
                outer: for (filtered_legs_array[0..filtered_legs_array_length], 0..) |outer_legs_p, outer_legs_i| {
                    const a1: f32 = @as(f32, @floatFromInt(outer_head_p.ap + outer_core_p.ap + outer_arms_p.ap + outer_legs_p.ap));
                    const b1: f32 = @as(f32, @floatFromInt(@as(u32, outer_head_p.weight + outer_core_p.weight + outer_arms_p.weight) + outer_legs_p.weight));
                    const bar = a1 / b1;
                    var ceiling: f32 = 99999;
                    var floor: f32 = 0;

                    for (filtered_head_array[0..filtered_head_array_length], 0..) |inner_head_p, inner_head_i| {
                        for (filtered_core_array[0..filtered_core_array_length], 0..) |inner_core_p, inner_core_i| {
                            // optimization, we could do our normal math for each set of two parts to find the optimal combinations
                            for (filtered_arms_array[0..filtered_arms_array_length], 0..) |inner_arms_p, inner_arms_i| {
                                // optimization, then do math with only the optimal part pairs and arms(or whatever third part)
                                for (filtered_legs_array[0..filtered_legs_array_length], 0..) |inner_legs_p, inner_legs_i| {
                                    // optimization, then do this last part with only the optimal part trios
                                    if (outer_head_i == inner_head_i and
                                        outer_core_i == inner_core_i and
                                        outer_arms_i == inner_arms_i and
                                        outer_legs_i == inner_legs_i)
                                    {
                                        continue;
                                    }
                                    const a2: f32 = @as(f32, @floatFromInt(inner_head_p.ap + inner_core_p.ap + inner_arms_p.ap + inner_legs_p.ap));
                                    const b2: f32 = @as(f32, @floatFromInt(@as(u32, inner_head_p.weight + inner_core_p.weight + inner_arms_p.weight) + inner_legs_p.weight));
                                    const slope = (a1 - a2) / (b1 - b2);
                                    if (b1 < b2) { // outer part is better "above" the line
                                        if (slope > bar) continue :outer; // make sure the y intercept is <= 0; same as `if (slope * b1 - a1 > 0) continue :outer;`
                                        // we know that ap can't increase anymore, so we can eliminate sets that can only be viable from ap increases

                                        if (slope > floor) { // optimization, i feel like i can get rid of some of this, now that we're not concerned about adding ap anymore
                                            floor = slope;
                                            if (ceiling < floor) continue :outer;
                                            //
                                        }
                                        //if (a1 / b1 < a2 / b2 and a1 < a2) continue :outer;
                                    } else { // outer part is better "below" the line
                                        if (slope < ceiling) {
                                            ceiling = slope;
                                            if (ceiling < floor) continue :outer;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    print("\n{s}\n{s}\n{s}\n{s}\nap: {d}\nweight: {d}\nideal added weight: {d} - {d}\n", .{
                        outer_head_p.name,
                        outer_core_p.name,
                        outer_arms_p.name,
                        outer_legs_p.name,
                        a1,
                        b1,
                        (1 / ceiling) * a1 - b1, // x intercept: (1/m) * a1 - b1
                        (1 / floor) * a1 - b1, // x intercept: (1/m) * a1 - b1
                    });
                }
            }
        }
    }
}

var filtered_head_array_length: usize = 0;
var filtered_head_array: [parts.head_array.len]parts.head = undefined;
var filtered_core_array_length: usize = 0;
var filtered_core_array: [parts.core_array.len]parts.core = undefined;
var filtered_arms_array_length: usize = 0;
var filtered_arms_array: [parts.arms_array.len]parts.arms = undefined;
var filtered_legs_array_length: usize = 0;
var filtered_legs_array: [parts.legs_array.len]parts.legs = undefined;

// optimization, these should all be affected by things like "are we okay with tank treads"
const max_weight_without_legs = 100300; // load limit of LG-O22T BORNEMISSZA
const min_weight_without_legs = head_numbers.min_weight + core_numbers.min_weight + arms_numbers.min_weight;
const max_ap_without_legs = head_numbers.max_ap + core_numbers.max_ap + arms_numbers.max_ap;
const min_ap_without_legs = head_numbers.min_ap + core_numbers.min_ap + arms_numbers.min_ap;
const max_attitude_stability_without_legs = head_numbers.max_attitude_stability + core_numbers.max_attitude_stability;
const min_attitude_stability_without_legs = head_numbers.min_attitude_stability + core_numbers.min_attitude_stability;

const Numbers = struct {
    min_ap: u16 = 65535,
    max_ap: u16 = 0,
    min_weight: u16 = 65535,
    max_weight: u16 = 0,
    min_attitude_stability: u16 = 65535,
    max_attitude_stability: u16 = 0,
};

const head_numbers: Numbers = init: {
    var s: Numbers = .{};
    for (parts.head_array) |part| {
        s.min_ap = @min(s.min_ap, part.ap);
        s.max_ap = @max(s.max_ap, part.ap);
        s.min_weight = @min(s.min_weight, part.weight);
        s.max_weight = @max(s.max_weight, part.weight);
        s.min_attitude_stability = @min(s.min_attitude_stability, part.attitude_stability);
        s.max_attitude_stability = @max(s.max_attitude_stability, part.attitude_stability);
    }
    break :init s;
};

const core_numbers: Numbers = init: {
    var s: Numbers = .{};
    for (parts.core_array) |part| {
        s.min_ap = @min(s.min_ap, part.ap);
        s.max_ap = @max(s.max_ap, part.ap);
        s.min_weight = @min(s.min_weight, part.weight);
        s.max_weight = @max(s.max_weight, part.weight);
        s.min_attitude_stability = @min(s.min_attitude_stability, part.attitude_stability);
        s.max_attitude_stability = @max(s.max_attitude_stability, part.attitude_stability);
    }
    break :init s;
};

const arms_numbers: Numbers = init: {
    var s: Numbers = .{};
    for (parts.arms_array) |part| {
        s.min_ap = @min(s.min_ap, part.ap);
        s.max_ap = @max(s.max_ap, part.ap);
        s.min_weight = @min(s.min_weight, part.weight);
        s.max_weight = @max(s.max_weight, part.weight);
    }
    break :init s;
};

const legs_numbers: Numbers = init: {
    var s: Numbers = .{};
    for (parts.legs_array) |part| {
        s.min_ap = @min(s.min_ap, part.ap);
        s.max_ap = @max(s.max_ap, part.ap);
        s.min_weight = @min(s.min_weight, part.weight);
        s.max_weight = @max(s.max_weight, part.weight);
        s.min_attitude_stability = @min(s.min_attitude_stability, part.attitude_stability);
        s.max_attitude_stability = @max(s.max_attitude_stability, part.attitude_stability);
    }
    break :init s;
};

pub fn initAllocator() void {
    aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena = aa.allocator();
}

pub var aa: std.heap.ArenaAllocator = undefined;
var arena: std.mem.Allocator = undefined;

//
//      via brute force, finds all possibly viable leg parts for ap*stability/weight (ignoring other factors)
//
pub fn test1() void {
    var part_count = init: {
        var array: [parts.legs_array.len]u64 = undefined;
        for (&array) |*i| {
            i.* = 0;
        }
        break :init array;
    };

    const cpus = std.Thread.getCpuCount() catch unreachable;

    var handles: []std.Thread = arena.alloc(std.Thread, cpus) catch unreachable;
    defer arena.free(handles);

    var lock: std.Thread.Mutex = .{};

    // assign threads work - as even as you can
    const remainder = ((max_ap_without_legs + 1) - min_ap_without_legs) % cpus;
    const floored_quotient = @divFloor((max_ap_without_legs + 1) - min_ap_without_legs, cpus);
    const fq_plus_one = floored_quotient + 1;

    // assign work + 1 to account for remainder
    var start: usize = min_ap_without_legs;
    for (handles[0..remainder], 0..) |*handle, n| {
        const from = start + n * fq_plus_one;
        handle.* = std.Thread.spawn(.{}, test1Loops, .{ &lock, &part_count, from, from + fq_plus_one }) catch unreachable;
    }

    // assign normal work
    start += remainder * fq_plus_one;
    for (handles[remainder..cpus], 0..) |*handle, n| {
        const from = start + n * floored_quotient;
        handle.* = std.Thread.spawn(.{}, test1Loops, .{ &lock, &part_count, from, from + floored_quotient }) catch unreachable;
    }

    // wait for the threads to be done
    for (handles) |handle| handle.join();

    // print results
    for (parts.legs_array, part_count) |part, count| {
        print("\n{s}: {}", .{ part.name, count });
    }
}

fn test1Loops(lock: *std.Thread.Mutex, master_part_count: []u64, from: u64, to: u64) void {
    var part_count = init: {
        var array: [parts.legs_array.len]u64 = undefined;
        for (&array) |*i| {
            i.* = 0;
        }
        break :init array;
    };

    for (from..to) |ap| {
        for (min_attitude_stability_without_legs..max_attitude_stability_without_legs + 1) |as| {
            for (min_weight_without_legs..max_weight_without_legs + 1) |weight| {
                var best_quotient: f32 = 0;
                var best_part: u64 = 0;
                for (parts.legs_array, 0..) |part, i| {
                    const quotient: f32 = @as(f32, @floatFromInt(part.ap + ap)) * @as(f32, @floatFromInt(part.attitude_stability + as)) / @as(f32, @floatFromInt(part.weight + weight));
                    if (quotient > best_quotient) {
                        best_quotient = quotient;
                        best_part = i;
                    }
                }
                part_count[best_part] += 1;
            }
        }
    }

    lock.lock();
    for (master_part_count, part_count) |*augend, addend| augend.* += addend;
    lock.unlock();
}

//
//      via math, finds all possibly viable leg parts for ap/weight (ignoring other factors)
//
pub fn test2() void {
    outer: for (parts.legs_array, 0..) |outer_p, outer_i| {
        const a1: f32 = @as(f32, @floatFromInt(outer_p.ap)) * @as(f32, @floatFromInt(outer_p.attitude_stability));
        const b1: f32 = @as(f32, @floatFromInt(outer_p.weight));
        var ceiling: f32 = 99999;
        var floor: f32 = 0;
        for (parts.legs_array, 0..) |inner_p, inner_i| {
            if (outer_i == inner_i) { // there are more redundant calculations than this that we can optimize out
                continue;
            }
            const a2: f32 = @as(f32, @floatFromInt(inner_p.ap)) * @as(f32, @floatFromInt(outer_p.attitude_stability));
            const b2: f32 = @as(f32, @floatFromInt(inner_p.weight));
            const slope = (a1 - a2) / (b1 - b2);
            if (b1 < b2) { // outer part is better "above" the line
                if (slope > floor) {
                    floor = slope;
                    if (ceiling < floor) continue :outer;
                }
            } else { // outer part is better "below" the line
                if (slope < ceiling) {
                    ceiling = slope;
                    if (ceiling < floor) continue :outer;
                }
            }
        }
        filtered_legs_array[filtered_legs_array_length] = outer_p;
        filtered_legs_array_length += 1;
    }
    print("\n\nlegs", .{});
    for (filtered_legs_array[0..filtered_legs_array_length]) |e| {
        print("\n{s}", .{e.name});
    }
}

//
//
//      this code is many months old. its results are more sophisticated than what i've yet managed
//      with the new methods, but i abandoned it because it's much too slow to work on productively.
//
//

const std = @import("std");
const print = std.debug.print;
const pow = std.math.pow;

const parts = @import("parts.zig");

//  edit these
//
const total_healing: f32 = (4000 + (500 * 4)) * 3; // (base healing + ( upgrade difference * number of upgrades)) * number of repair kits
const additional_weight: u32 = 0;
const additional_en_load: u16 = 198;
//const thruster_weight: u32 = 1420;
//const thruster_en_load: u32 = 390;
//const additional_damage_per_minute: u16 = 886;

const max_weight: u32 = 100300 + 49800;
const effective_health_exponent: f16 = 1;
const attitude_stability_exponent: f16 = 1;
const defense_exponent: f16 = 0.5; // only for ricochets, not damage mitigation ie. effective health.
const req_recoil_control: u16 = 0;

const req_attitude_stability: u16 = 1218; // min is 1218
const req_effective_health: f32 = (5700 + total_healing) / 0.91833; // this doesn't have to be an equation. it can be any number. minimum effective health i've found is 6206.
const req_defense: u16 = 2901; // 2901 min

//

//  don't need to edit
//
const max_effective_health: f32 = (17540 + total_healing) / 0.318;
const max_defense: u16 = 4070; //4070 max
const max_attitude_stability: u16 = 3000; //idk the max
var req_numerator: f64 = std.math.pow(f64, @as(f64, @floatFromInt(req_attitude_stability)), attitude_stability_exponent) * std.math.pow(f64, req_defense, defense_exponent) * std.math.pow(f64, req_effective_health, effective_health_exponent);
const max_numerator: f64 = std.math.pow(f64, @as(f64, @floatFromInt(max_attitude_stability)), attitude_stability_exponent) * std.math.pow(f64, max_defense, defense_exponent) * std.math.pow(f64, max_effective_health, effective_health_exponent);
//

const set = struct {
    r_arm_unit: []const u8,
    l_arm_unit: []const u8,
    r_back_unit: []const u8,
    l_back_unit: []const u8,
    head: []const u8,
    core: []const u8,
    arms: []const u8,
    legs: []const u8,
    generator: []const u8,
    weight: u32,
    defense: u16,
    attitude_stability: u16,
    quotient: f64,
    effective_health: f32,
    avg_dps: f32,
};

var best_set: ?set = null;
var best_quotient: f64 = undefined;

var current_r_arm_unit: []const u8 = undefined;
var current_l_arm_unit: []const u8 = undefined;
var current_r_back_unit: []const u8 = undefined;
var current_l_back_unit: []const u8 = undefined;

const steps: u8 = 1;
const grain: f64 = (max_numerator - (std.math.pow(f64, @as(f64, @floatFromInt(req_attitude_stability)), attitude_stability_exponent) * std.math.pow(f64, req_defense, defense_exponent) * std.math.pow(f64, req_effective_health, effective_health_exponent))) / steps; //granularity/accuracy/number of steps
var streak: f64 = grain;

var iterations: u64 = 0;

pub fn main() !void {
    parts.fill_structs_of_arrays();

    const start_timestamp = std.time.microTimestamp();

    print("\n\nthinking", .{});
    defer print("\n\n\n", .{});
    var previous_best_set: ?set = null;
    var largest_range_set: ?set = null;
    var largest_streak: f64 = grain;

    //var do_once: u8 = 1;
    while (req_numerator <= max_numerator) : (req_numerator += grain) { //do_once > 0) : (do_once -= 1) {
        print(".", .{});

        best_set = null;
        best_quotient = 0;

        r_arm_units(); //where the action happens

        if (best_set == null) {
            if (previous_best_set == null) break;
            print("\n\n\n*info*\nrange: {d:.0}\nweight: {}\nquotient: {d:.6}\ndefense: {}\nattitude stability: {}", .{ streak, previous_best_set.?.weight, previous_best_set.?.quotient, previous_best_set.?.defense, previous_best_set.?.attitude_stability });
            printSet(previous_best_set);
            print("\n\n\n", .{});
            if (streak > largest_streak) { //swap between >= (stronger) and > (more efficient) to change who wins ties
                largest_streak = streak;
                largest_range_set = previous_best_set;
            }
            previous_best_set = best_set;

            print("\n\n\ncould not find any more sets that satisfy the requirements", .{});
            break;
        }
        if (previous_best_set == null) {
            previous_best_set = best_set;
            continue;
        }
        if (std.meta.eql(best_set.?, previous_best_set.?)) {
            streak += grain;
            if (req_numerator + grain < max_numerator) continue;
        }
        //where 'streak' was used
        printSet(previous_best_set);
        print("\n\n\n", .{});
        if (streak > largest_streak) { //swap between >= (stronger) and > (more efficient) to change who wins ties
            largest_streak = streak;
            largest_range_set = previous_best_set;
        }
        previous_best_set = best_set;
        streak = grain;
    }
    print("\n\n\n\n\n\n\n*inputs*\ndefense: {d:}\nrecoil control: {}\nadditional weight: {}\ngrain: {d:}", .{ req_defense, req_recoil_control, additional_weight, grain });
    print("\n\n\n", .{});
    if (largest_range_set != null) {
        print("your free win, sir:", .{});
        print("\n\nquotient: {d}\nrange: {d:.0}\n(there may be multiple sets with this range. priority is given to {s} sets)", .{ largest_range_set.?.quotient, largest_streak, "more efficient" });
        printSet(largest_range_set);
    } else {
        print("\ncould not find any set that satisfies the requirements", .{});
    }

    print("\n\n\n\niterations: {}", .{iterations});
    var seconds = @as(f32, @floatFromInt(std.time.microTimestamp() - start_timestamp)) / std.time.us_per_s;
    const minutes = @floor(seconds / 60);
    seconds -= minutes * 60;
    print("\nmain function finished in {d:.0}m {d:.0}s\n", .{ minutes, seconds });
    print("\n\nfailed load limit: {}\nfailed en_load: {}\n passed en_load: {}", .{ failed_load, failed_en, passed_en });

    //print("\n\n\n{d}\n{d}", .{ parts.r_arm_unit_array[0].normal.avg_dps(), parts.r_arm_unit_array[1].charge.avg_dps() });
}

fn printSet(s: ?set) void {
    print("\n\n\n*info*\nrange: {d:}\nweight: {}\nquotient: {d:}\ndefense: {}\nattitude stability: {}\neffective health: {d:.0}\naverage dps: {d}", .{ streak, s.?.weight, s.?.quotient, s.?.defense, s.?.attitude_stability, s.?.effective_health, s.?.avg_dps });
    print("\n\n\n{s}\n{s}\n{s}\n{s}\n\n{s}\n{s}\n{s}\n{s}\n\n{s}", .{ s.?.r_arm_unit, s.?.l_arm_unit, s.?.r_back_unit, s.?.l_back_unit, s.?.head, s.?.core, s.?.arms, s.?.legs, s.?.generator });
}

//weapon damages can depend on generator and arms. we should probably put engine and arms before weapons to make calculation easier.

const passed_struct = struct {
    weight: u32,
    en_load: u16,
    r_arm_unit: passed_weapon_info = undefined,
    l_arm_unit: passed_weapon_info = undefined,
    r_back_unit: passed_weapon_info = undefined,
    l_back_unit: passed_weapon_info = undefined,
};
const passed_weapon_info = struct {
    avg_dps: f32,
    ideal_range: u16,
    effective_range: u16,
};
// this is wrong. currently, increased weight makes range matter more. this means increasing weight increases effectiveness. i want weight to decrease effectiveness, but less the more range you have. so i want range to decrease the importance of weight, rather than weight increasing the importance of range. will these end up being the same? if we rearrange the equation, will we just get the same numbers? no, because increasing weight will decrease the number now.
fn effectiveness(weapon: passed_weapon_info, weight_int: u32) f64 {
    const weight: f32 = @as(f32, @floatFromInt(weight_int));
    const max_weight_float: f32 = @as(f32, @floatFromInt(max_weight));
    const ideal_range: f32 = @as(f32, @floatFromInt(weapon.ideal_range));
    const effective_range: f32 = @as(f32, @floatFromInt(weapon.effective_range));

    return weapon.avg_dps * (pow(f64, ideal_range, ideal_range_exponent * @min(weight, max_weight_float * 0.8) / max_weight_float * 0.8) + pow(f64, effective_range, effective_range_exponent * @min(weight, max_weight_float * 0.8) / max_weight_float * 0.8));
}
const ideal_range_exponent: f16 = 1;
const effective_range_exponent: f16 = 1 / 2;

//we're going through every weapon array/soa twice. can we manage to just do it once for both sides?

const en = @import("en.zig");

fn r_arm_units() void {
    //current_r_arm_unit = "nothing";
    //l_arm_units(0, 0, 0); //causes error
    //if (en()) continue;
    for (
        parts.arm_unit_normal_soa.name,
        parts.arm_unit_normal_soa.weight,
        parts.arm_unit_normal_soa.en_load,
        parts.arm_unit_normal_soa.avg_dps,
        parts.arm_unit_normal_soa.ideal_range,
        parts.arm_unit_normal_soa.effective_range,
    ) |name, weight, en_load, avg_dps, ideal_range, effective_range| {
        current_r_arm_unit = name;
        l_arm_units(passed_struct{
            .weight = weight,
            .en_load = en_load,
            .r_arm_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = ideal_range,
                .effective_range = effective_range,
            },
        });
    }
    for (
        parts.arm_unit_charge_soa.name, // optimization, don't loop through names
        parts.arm_unit_charge_soa.weight,
        parts.arm_unit_charge_soa.en_load,
        parts.arm_unit_charge_soa.avg_dps,
        parts.arm_unit_charge_soa.ideal_range,
        parts.arm_unit_charge_soa.effective_range,
    ) |name, weight, en_load, avg_dps, ideal_range, effective_range| {
        current_r_arm_unit = name;
        l_arm_units(passed_struct{
            .weight = weight,
            .en_load = en_load,
            .r_arm_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = ideal_range,
                .effective_range = effective_range,
            },
        });
    }
}

fn l_arm_units(passed: passed_struct) void {
    //current_r_arm_unit = "nothing";
    //l_arm_units(0, 0, 0); //causes error
    for (
        parts.arm_unit_normal_soa.name, // optimization, don't loop through names
        parts.arm_unit_normal_soa.weight,
        parts.arm_unit_normal_soa.en_load,
        parts.arm_unit_normal_soa.avg_dps,
        parts.arm_unit_normal_soa.ideal_range,
        parts.arm_unit_normal_soa.effective_range,
    ) |name, weight, en_load, avg_dps, ideal_range, effective_range| {
        current_l_arm_unit = name;
        r_back_units(passed_struct{
            .weight = passed.weight + weight,
            .en_load = passed.en_load + en_load,
            .r_arm_unit = passed.r_arm_unit,
            .l_arm_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = ideal_range,
                .effective_range = effective_range,
            },
        });
    }
    for (
        parts.arm_unit_charge_soa.name, // optimization, don't loop through names
        parts.arm_unit_charge_soa.weight,
        parts.arm_unit_charge_soa.en_load,
        parts.arm_unit_charge_soa.avg_dps,
        parts.arm_unit_charge_soa.ideal_range,
        parts.arm_unit_charge_soa.effective_range,
    ) |name, weight, en_load, avg_dps, ideal_range, effective_range| {
        current_l_arm_unit = name;
        r_back_units(passed_struct{
            .weight = passed.weight + weight,
            .en_load = passed.en_load + en_load,
            .r_arm_unit = passed.r_arm_unit,
            .l_arm_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = ideal_range,
                .effective_range = effective_range,
            },
        });
    }
}

fn r_back_units(passed: passed_struct) void {
    for (
        parts.back_unit_missile_launcher_soa.name, // optimization, don't loop through names
        parts.back_unit_missile_launcher_soa.weight,
        parts.back_unit_missile_launcher_soa.en_load,
        parts.back_unit_missile_launcher_soa.avg_dps,
        parts.back_unit_missile_launcher_soa.effective_range,
    ) |name, weight, en_load, avg_dps, effective_range| {
        current_r_back_unit = name;
        l_back_units(passed_struct{
            .weight = passed.weight + weight,
            .en_load = passed.en_load + en_load,
            .r_arm_unit = passed.r_arm_unit,
            .l_arm_unit = passed.l_arm_unit,
            .r_back_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = effective_range,
                .effective_range = effective_range,
            },
        });
    }
}

fn l_back_units(passed: passed_struct) void {
    for (
        parts.back_unit_missile_launcher_soa.name, // optimization, don't loop through names
        parts.back_unit_missile_launcher_soa.weight,
        parts.back_unit_missile_launcher_soa.en_load,
        parts.back_unit_missile_launcher_soa.avg_dps,
        parts.back_unit_missile_launcher_soa.effective_range,
    ) |name, weight, en_load, avg_dps, effective_range| {
        current_l_back_unit = name;
        the_function(passed_struct{
            .weight = passed.weight + weight,
            .en_load = passed.en_load + en_load,
            .r_arm_unit = passed.r_arm_unit,
            .l_arm_unit = passed.l_arm_unit,
            .r_back_unit = passed.r_back_unit,
            .l_back_unit = .{
                .avg_dps = avg_dps,
                .ideal_range = effective_range,
                .effective_range = effective_range,
            },
        });
    }
}

var failed_load: u64 = 0;
var passed_en: u64 = 0;
var failed_en: u64 = 0;
fn the_function(passed: passed_struct) void {
    for (parts.core_array) |core_p| {
        for (parts.generator_array) |generator_p| {
            if (((passed.en_load + core_p.en_load + 88 + 210 + 280 + 130 + 198) * 10) > (core_p.generator_output_adj * (generator_p.en_output / 10))) continue;

            for (parts.head_array) |head_p| {
                if (((passed.en_load + core_p.en_load + head_p.en_load + 210 + 280 + 130 + 198) * 10) > (core_p.generator_output_adj * (generator_p.en_output / 10))) continue;
                const defense_sum_2: u16 = core_p.kinetic_defense + core_p.energy_defense + core_p.explosive_defense + head_p.kinetic_defense + head_p.energy_defense + head_p.explosive_defense;
                const attitude_stability_sum_1: u16 = head_p.attitude_stability + core_p.attitude_stability;
                const weight_sum_2: u32 = core_p.weight + passed.weight + head_p.weight + additional_weight;
                const en_load_sum_1: u16 = passed.en_load + additional_en_load + head_p.en_load + core_p.en_load;

                for (parts.arms_array) |arms_p| {
                    if (((passed.en_load + core_p.en_load + head_p.en_load + arms_p.en_load + 280 + 130 + 198) * 10) > (core_p.generator_output_adj * (generator_p.en_output / 10))) continue;
                    //if (arms_p.melee_specialization < 158) continue;
                    if (arms_p.recoil_control < req_recoil_control) continue;
                    const defense_sum_3: u16 = arms_p.kinetic_defense + arms_p.energy_defense + arms_p.explosive_defense + defense_sum_2;
                    const weight_sum_3: u32 = arms_p.weight + weight_sum_2;

                    for (parts.legs_array) |legs_p| {
                        const defense_sum: u16 = legs_p.kinetic_defense + legs_p.energy_defense + legs_p.explosive_defense + defense_sum_3;
                        const defense_sum_stage: f32 = @as(f32, @floatFromInt(defense_sum)); //to make sure it works and for cleanliness and performance
                        const attitude_stability_sum: u16 = attitude_stability_sum_1 + legs_p.attitude_stability;
                        const ap_sum: u16 = head_p.ap + core_p.ap + arms_p.ap + legs_p.ap;
                        const effective_health: f32 = (@as(f32, @floatFromInt(ap_sum)) + total_healing) / (1 - ((defense_sum_stage - 3000) / 3000));

                        if (defense_sum < req_defense) continue;
                        if (attitude_stability_sum < req_attitude_stability) continue;

                        iterations += 1;

                        //if (legs_p.type == parts.legs_type.tank) continue; //could be moved to filter an array

                        const weight_sum: u32 = generator_p.weight + legs_p.weight + weight_sum_3; //useful for cleanliness, not performance
                        if (weight_sum - legs_p.weight > legs_p.load_limit) {
                            failed_load += 1;
                            continue;
                        }
                        if (weight_sum > max_weight) continue;

                        const en_load_sum = en_load_sum_1 + arms_p.en_load + legs_p.en_load;
                        if ((generator_p.en_output / 10) * core_p.generator_output_adj < en_load_sum * 10) {
                            failed_en += 1;
                            continue;
                        }
                        passed_en += 1;

                        const weapon_effectiveness: f64 = effectiveness(passed.r_arm_unit, weight_sum) + effectiveness(passed.l_arm_unit, weight_sum) + effectiveness(passed.r_back_unit, weight_sum) + effectiveness(passed.l_back_unit, weight_sum);
                        const numerator: f64 = (std.math.pow(f64, @as(f64, @floatFromInt(attitude_stability_sum)), attitude_stability_exponent) * std.math.pow(f64, defense_sum_stage, defense_exponent)) * std.math.pow(f64, effective_health, effective_health_exponent) * weapon_effectiveness;
                        const quotient: f64 = @as(f64, numerator) / @as(f64, @floatFromInt(weight_sum)); //to make sure it works and for cleanliness and performance

                        if (numerator < req_numerator) continue;
                        if (quotient < best_quotient) continue;
                        best_set = set{
                            .r_arm_unit = current_r_arm_unit,
                            .l_arm_unit = current_l_arm_unit,
                            .r_back_unit = current_r_back_unit,
                            .l_back_unit = current_l_back_unit,
                            .head = head_p.name,
                            .core = core_p.name,
                            .arms = arms_p.name,
                            .legs = legs_p.name,
                            .generator = generator_p.name,
                            .weight = weight_sum,
                            .defense = defense_sum,
                            .attitude_stability = attitude_stability_sum,
                            .quotient = quotient,
                            .effective_health = effective_health,
                            .avg_dps = passed.r_arm_unit.avg_dps + passed.l_arm_unit.avg_dps + passed.r_back_unit.avg_dps + passed.l_back_unit.avg_dps,
                        };
                        best_quotient = quotient;
                    }
                }
            }
        }
    }
}

//problem: i don't know how ricochets are calculated. at the moment, i just calculate using the raw defense number, but i assume that's not right.
//
//i should have a fix-all solution for minimums, so i don't have to go find them to make sure some sets don't have exaggerated ranges

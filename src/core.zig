const std = @import("std");
const expect = std.testing.expect;

pub const soul = @import("core/soul.zig");
pub const Soul = soul.Soul;
pub const SoulList = soul.SoulList;

pub const SoulFile = @import("core/SoulFile.zig");

pub fn todo() !void {
    unreachable;
}

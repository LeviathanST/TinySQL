const std = @import("std");

const Soul = struct {
    name: []const u8,
    age: u8,
};

pub fn main() !void {
    const soul = Soul{
        .name = "Hung",
        .age = 18,
    };

    std.debug.print(
        "{s} - {d}",
        .{
            soul.name,
            soul.age,
        },
    );
}

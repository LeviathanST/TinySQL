const std = @import("std");

const Soul = struct {
    name: []const u8,
    age: u8,
};

pub fn main() !void {
    const souls = [2]Soul{
        Soul{ .name = "Hung", .age = 19 },
        Soul{ .name = "Ngoc", .age = 18 },
    };

    for (souls) |soul| {
        std.debug.print(
            "{s} - {d}\n",
            .{
                soul.name,
                soul.age,
            },
        );
    }
}

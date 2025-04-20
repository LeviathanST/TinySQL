const std = @import("std");

const MAX_LIST_LENGTH: usize = 2;

const Soul = struct {
    name: []const u8,
    age: u8,
};

fn display_souls(list: *[MAX_LIST_LENGTH]Soul) anyerror!void {
    const stdout = std.io.getStdOut().writer();

    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    for (list) |soul| {
        try stdout.print("Name {s}\n", .{soul.name});
        try stdout.print("Age {d}\n", .{soul.age});
        try stdout.writeAll("----\n");
    }
}
fn write_soul(list: *[MAX_LIST_LENGTH]Soul, idx: usize, name: []u8, age: u8) void {
    const soul = Soul{
        .name = name,
        .age = age,
    };

    list[idx] = soul;
}

pub fn main() !void {
    var souls: [MAX_LIST_LENGTH]Soul = undefined;
    var current_idx: usize = 0;

    // Use ArenaAllocator to allocate mutiple times and only once free.
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var name_buffer: [100]u8 = undefined;
    var age_buffer: [100]u8 = undefined;

    while (current_idx < souls.len) : (current_idx += 1) {
        try stdout.print("Name:\n", .{});
        const name = try stdin.readUntilDelimiter(&name_buffer, '\n');
        const name_copy = try allocator.alloc(u8, name.len);
        @memcpy(name_copy, name);

        try stdout.print("Age:\n", .{});
        const age_input = try stdin.readUntilDelimiter(&age_buffer, '\n');
        const age = try std.fmt.parseInt(u8, age_input, 10);

        write_soul(&souls, current_idx, name_copy, age);
    }

    try display_souls(&souls);
}

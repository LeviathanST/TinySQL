const std = @import("std");
const Writer = std.io.Writer;
const Reader = std.io.Reader;

const MAX_LIST_LENGTH: usize = 2;
var current_idx: usize = 0;

const Soul = struct {
    name: []const u8,
    age: u8,
};

fn display_souls(
    stdout: anytype,
    list: *[MAX_LIST_LENGTH]Soul,
) anyerror!void {
    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    if (current_idx <= 0) {
        try stdout.writeAll("The storage is empty!\n");
    }
    for (list[0..current_idx]) |soul| {
        try stdout.print("Name {s}\n", .{soul.name});
        try stdout.print("Age {d}\n", .{soul.age});
        try stdout.writeAll("----\n");
    }
}
fn write_soul(
    stdin: anytype,
    stdout: anytype,
    allocator: std.mem.Allocator,
    list: *[MAX_LIST_LENGTH]Soul,
    idx: usize,
) anyerror!void {
    var name_buffer: [100]u8 = undefined;
    var age_buffer: [10]u8 = undefined;

    // readUntilDelimiter is deprecated since 0.11.0
    // but is still used and I don't know why.
    // I wanna use it and find out why.
    // Issue: https://github.com/ziglang/zig/issues/15528
    try stdout.print("Name:\n", .{});
    var fbs = std.io.fixedBufferStream(&name_buffer);
    try stdin.streamUntilDelimiter(fbs.writer(), '\n', fbs.buffer.len);
    var name_copy = try allocator.alloc(u8, fbs.getWritten().len);
    @memcpy(name_copy[0..], fbs.getWritten());

    try stdout.print("Age:\n", .{});
    const age_input = try stdin.readUntilDelimiter(&age_buffer, '\n');
    const age = try std.fmt.parseInt(u8, age_input, 10);
    const soul = Soul{
        .name = name_copy,
        .age = age,
    };

    list[idx] = soul;
}

fn find_by_name(
    stdin: anytype,
    stdout: anytype,
    list: *[MAX_LIST_LENGTH]Soul,
) anyerror!void {
    try stdout.writeAll("Search: ");
    var name_buffer: [100]u8 = undefined;
    const name = try stdin.readUntilDelimiter(&name_buffer, '\n');

    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    for (list) |soul| {
        if (std.mem.eql(u8, soul.name, name)) {
            try stdout.print("Name {s}\n", .{soul.name});
            try stdout.print("Age {d}\n", .{soul.age});
            try stdout.writeAll("---\n");
            return;
        }
    }
    try stdout.print("Not found {s}\n", .{name});
    try stdout.writeAll("---\n");
}

pub fn main() !void {
    var souls: [MAX_LIST_LENGTH]Soul = undefined;

    // Use ArenaAllocator to allocate mutiple times and only once free.
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var choice_buf: [2]u8 = undefined;

    while (true) {
        const choice_input = try stdin.readUntilDelimiter(&choice_buf, '\n');
        const choice = try std.fmt.parseInt(u8, choice_input, 10);
        switch (choice) {
            1 => {
                if (current_idx < souls.len) {
                    try write_soul(
                        stdin,
                        stdout,
                        allocator,
                        &souls,
                        current_idx,
                    );
                    current_idx += 1;
                    continue;
                } else {
                    try stdout.writeAll("The storage is full!");
                    continue;
                }
            },
            2 => {
                try display_souls(stdout, &souls);
                continue;
            },
            3 => {
                try find_by_name(stdin, stdout, &souls);
            },
            else => {
                try stdout.writeAll("Your choice not found!");
                continue;
            },
        }
    }
}

const std = @import("std");
const Writer = std.io.Writer;
const Reader = std.io.Reader;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Soul = struct {
    name: []u8,
    age: u8,
};

fn displaySouls(
    stdout: anytype,
    list: *ArrayList(Soul),
) anyerror!void {
    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    if (list.items.len <= 0) {
        try stdout.writeAll("The storage is empty!\n");
        return;
    }
    for (list.items) |soul| {
        try stdout.print("Name {s}\n", .{soul.name});
        try stdout.print("Age {d}\n", .{soul.age});
        try stdout.writeAll("----\n");
    }
}
fn writeSoul(
    stdin: anytype,
    stdout: anytype,
    allocator: Allocator,
    list: *ArrayList(Soul),
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
    const input_len = fbs.getWritten().len;

    var name_copy = try allocator.alloc(u8, input_len);
    @memcpy(name_copy[0..input_len], fbs.getWritten());

    try stdout.print("Age:\n", .{});
    const age_input = try stdin.readUntilDelimiter(&age_buffer, '\n');
    const age = try std.fmt.parseInt(u8, age_input, 10);
    const soul = Soul{
        .name = name_copy,
        .age = age,
    };

    try list.append(soul);
}

fn findByName(
    stdin: anytype,
    stdout: anytype,
    list: *ArrayList(Soul),
) anyerror!void {
    try stdout.writeAll("Search: ");
    var name_buffer: [100]u8 = undefined;
    const name = try stdin.readUntilDelimiter(&name_buffer, '\n');

    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    for (list.items) |soul| {
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
    const allocator = std.heap.page_allocator;

    // Here Im using ArrayList because we need an array of infinite size.
    // ArrayList, in other words, is just a fixed array,
    // when adding items reaches the limit we call "capacity"
    // it will calculate itself and increase the capacity amount.
    // Hence, we have a infinite growing array.
    var souls = ArrayList(Soul).init(std.heap.page_allocator);
    defer souls.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var choice_buf: [2]u8 = undefined;

    while (true) {
        try stdout.print("Current total:  {d}\n", .{souls.items.len});
        try stdout.writeAll("---\n");

        const choice_input = try stdin.readUntilDelimiter(&choice_buf, '\n');
        const choice = try std.fmt.parseInt(u8, choice_input, 10);
        switch (choice) {
            1 => {
                try writeSoul(
                    stdin,
                    stdout,
                    allocator,
                    &souls,
                );
                continue;
            },
            2 => {
                try displaySouls(stdout, &souls);
                continue;
            },
            3 => {
                try findByName(stdin, stdout, &souls);
                continue;
            },
            else => {
                try stdout.writeAll("Your choice not found!");
                continue;
            },
        }
    }
}

const std = @import("std");
pub const SoulList = @import("core/SoulList.zig").SoulList;
pub const Soul = @import("core/SoulList.zig").Soul;

pub fn displaySouls(
    stdout: anytype,
    list: *SoulList,
) anyerror!void {
    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    if (list.items.len <= 0) {
        try stdout.writeAll("The storage is empty!\n");
        return;
    }
    for (list.items[0..list.current_total]) |soul| {
        try stdout.print("Name {s}\n", .{soul.name});
        try stdout.print("Age {d}\n", .{soul.age});
        try stdout.writeAll("----\n");
    }
}
pub fn writeSoul(
    stdin: anytype,
    stdout: anytype,
    list: *SoulList,
) anyerror!void {
    var name_buffer: [32]u8 = undefined;
    var age_buffer: [10]u8 = undefined;

    // readUntilDelimiter is deprecated since 0.11.0
    // but is still used and I don't know why.
    // I wanna use it and find out why.
    // Issue: https://github.com/ziglang/zig/issues/15528
    try stdout.print("Name:\n", .{});
    var fbs = std.io.fixedBufferStream(&name_buffer);
    try stdin.streamUntilDelimiter(fbs.writer(), '\n', fbs.buffer.len);
    var name_input = fbs.getWritten();

    try stdout.print("Age:\n", .{});
    const age_input = try stdin.readUntilDelimiter(&age_buffer, '\n');
    const age = try std.fmt.parseInt(u8, age_input, 10);

    try list.append(name_input[0..], age);
}

pub fn findByName(
    stdin: anytype,
    stdout: anytype,
    list: *SoulList,
) anyerror!void {
    try stdout.writeAll("Search: ");
    var name_buffer: [100]u8 = undefined;
    const name = try stdin.readUntilDelimiter(&name_buffer, '\n');

    try stdout.writeAll("Result:\n");
    try stdout.writeAll("----\n");
    for (list.items[0..list.current_total]) |soul| {
        if (std.mem.eql(u8, &soul.name, name)) {
            try stdout.print("Name {s}\n", .{soul.name});
            try stdout.print("Age {d}\n", .{soul.age});
            try stdout.writeAll("---\n");
            return;
        }
    }
    try stdout.print("Not found {s}\n", .{name});
    try stdout.writeAll("---\n");
}

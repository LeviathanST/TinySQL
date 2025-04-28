//! The user input, display handler
const std = @import("std");
const core = @import("../core.zig");
const TinySQLContext = @import("../context.zig");
const Soul = core.Soul;
const SoulList = core.SoulList;
const todo = core.todo;

const WriteTuple = std.meta.Tuple(&[_]type{ [32]u8, u8 });

const Self = @This();

ctx: TinySQLContext,

pub fn init(comptime ctx: TinySQLContext) Self {
    return Self{ .ctx = ctx };
}
// Return user choice number
pub fn menuPrompt(self: Self) !u8 {
    const stdout = self.ctx.stdout;
    try stdout.writeAll("1> Insert new\n");
    try stdout.writeAll("2> Display all\n");
    try stdout.writeAll("3> Find\n");
    try stdout.writeAll("4> Delete\n");
    var choice_buf: [2]u8 = undefined;
    const choice_input = try self.ctx.stdin.readUntilDelimiter(&choice_buf, '\n');
    return try std.fmt.parseInt(u8, choice_input, 10);
}

pub fn displayAll(self: Self, list: SoulList) !void {
    const stdout = self.ctx.stdout;

    try stdout.print("{s}\n", .{"-" ** 45});
    try stdout.print("Name{s}|| Age\n", .{" " ** 32});
    try stdout.print("{s}\n", .{"-" ** 45});
    if (list.items.len <= 0) {
        try stdout.writeAll("Empty\n");
    } else {
        for (list.items[0..list.current_total]) |soul| {
            try stdout.print("{s}{s}|| {d}\n", .{ soul.name, " " ** 32, soul.age });
        }
    }

    try stdout.print("{s}\n", .{"-" ** 45});
    try stdout.print("Total: {}\n", .{list.current_total});
    try stdout.print("{s}\n", .{"-" ** 45});
}

pub fn displayA(self: Self, soul: ?Soul) !void {
    const stdout = self.ctx.stdout;

    try stdout.print("{s}\n", .{"-" ** 45});
    try stdout.print("Name{s}|| Age\n", .{" " ** 32});
    try stdout.print("{s}\n", .{"-" ** 45});
    if (soul) |value| {
        try stdout.print("{s}{s}|| {d}\n", .{ value.name, " " ** 32, value.age });
    } else {
        try stdout.writeAll("Not Found\n");
    }
    try stdout.print("{s}\n", .{"-" ** 45});
}

pub fn writePrompt(self: Self) !Soul {
    const stdout = self.ctx.stdout;
    const stdin = self.ctx.stdin;
    var name_buffer: [100]u8 = undefined;
    var age_buffer: [3]u8 = undefined;

    // readUntilDelimiter is deprecated since 0.11.0
    // but is still used and I don't know why.
    // I wanna use it and find out why.
    // Issue: https://github.com/ziglang/zig/issues/15528
    try stdout.print("Name: ", .{});
    var fbs = std.io.fixedBufferStream(name_buffer[0..]);
    try stdin.streamUntilDelimiter(fbs.writer(), '\n', fbs.buffer.len);
    var name_input = fbs.getWritten();

    try stdout.print("Age: ", .{});
    const age_input = try stdin.readUntilDelimiter(age_buffer[0..], '\n');
    const age = try std.fmt.parseInt(u8, age_input, 10);
    return try Soul.fromUserInput(name_input[0..], age);
}

pub fn findPrompt(self: Self) ![]u8 {
    var name_buffer: [100]u8 = undefined;
    const name_input = try self.ctx.stdin.readUntilDelimiter(name_buffer[0..], '\n');
    return name_input;
}

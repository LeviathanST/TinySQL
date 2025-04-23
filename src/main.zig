const std = @import("std");
const core = @import("core.zig");
const SoulList = core.SoulList;
const Soul = core.Soul;
const Writer = std.io.Writer;
const Reader = std.io.Reader;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var choice_buf: [2]u8 = undefined;

    while (true) {
        try stdout.print("Maximum:  {d}\n", .{souls.capacity});
        try stdout.print("Current total:  {d}\n", .{souls.current_total});
        try stdout.writeAll("---\n");

        const choice_input = try stdin.readUntilDelimiter(&choice_buf, '\n');
        const choice = try std.fmt.parseInt(u8, choice_input, 10);
        switch (choice) {
            1 => {
                try core.writeSoul(stdin, stdout, &souls);
                continue;
            },
            2 => {
                try core.displaySouls(stdout, &souls);
                continue;
            },
            3 => {
                try core.findByName(stdin, stdout, &souls);
                continue;
            },
            else => {
                continue;
            },
        }
    }
}

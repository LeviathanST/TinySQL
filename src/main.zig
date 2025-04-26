const std = @import("std");
const core = @import("core.zig");
const SoulUI = @import("ui.zig").SoulUI;
const TinySQLContext = @import("context.zig");
const SoulList = core.SoulList;
const SoulFile = core.SoulFile;
const Soul = core.Soul;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const ctx = comptime TinySQLContext.init("database.db");
    const fileHandler = try SoulFile.init(ctx);
    const ui = SoulUI.init(ctx);
    try fileHandler.createIfNotExists();

    var choice_buf: [2]u8 = undefined;

    w: while (true) {
        const choice_input = try ctx.stdin.readUntilDelimiter(&choice_buf, '\n');
        const choice = try std.fmt.parseInt(u8, choice_input, 10);
        switch (choice) {
            1 => {
                const soul = try ui.writePrompt();
                try fileHandler.write(soul);
                continue :w;
            },
            2 => {
                const list = try fileHandler.getAll(allocator);
                try ui.displayAll(list);
                continue :w;
            },
            3 => {
                const name = try ui.findPrompt();
                const soul = try fileHandler.findA(allocator, name);
                try ui.displayA(soul);
                continue :w;
            },
            else => {
                break;
            },
        }
    }
}

test {
    std.testing.refAllDecls(@This());
}

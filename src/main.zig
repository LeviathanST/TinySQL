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
    try ctx.stdout.writeAll("\x1B[2J\x1B[H");
    const fileHandler = try SoulFile.init(ctx);
    const ui = SoulUI.init(ctx);
    try fileHandler.createIfNotExists();

    w: while (true) {
        const choice = try ui.menuPrompt();
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
                const name = try ui.findPrompt(allocator);
                defer allocator.free(name);
                const soul = try fileHandler.findA(allocator, name);
                try ui.displayA(soul);
                continue :w;
            },
            4 => {
                const name = try ui.findPrompt(allocator);
                const newData = try ui.updatePrompt();
                const isUpdated = try fileHandler.updateA(name, newData);
                if (isUpdated) {
                    try ctx.stdout.writeAll("Updated!");
                } else {
                    try ctx.stdout.writeAll("Not updated!");
                }
            },
            5 => {
                const name = try ui.findPrompt(allocator);
                try fileHandler.deleteA(allocator, name);
            },
            else => {
                break;
            },
        }
    }

    const soul = try fileHandler.findA(allocator, "Hung");
    try ui.displayA(soul);
}

test {
    std.testing.refAllDecls(@This());
}

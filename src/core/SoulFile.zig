//!The soul data file operator.
//!
//!## Feature
//!
//!Create data file if not exists with specific filename.
//!Write soul into file.
//!
const std = @import("std");

const TinySQLContext = @import("../context.zig");
const Soul = @import("soul.zig").Soul;
const SoulList = @import("soul.zig").SoulList;
const SoulErr = @import("soul.zig").Soul.Error;
const File = std.fs.File;
const Allocator = std.mem.Allocator;

const cwd = std.fs.cwd;
const print = std.debug.print;
const expect = std.testing.expect;
// Only support Linux
const detectCpu = std.zig.system.linux.detectNativeCpuAndFeatures;

const FindError = error{ CpuArchNotFound, DataFileNotFound, SoulNotFound };
const Self = @This();

ctx: TinySQLContext,

pub fn init(comptime ctx: TinySQLContext) !Self {
    return Self{
        .ctx = ctx,
    };
}

///Create data file with 'filename' if not exists
pub fn createIfNotExists(self: Self) (File.OpenError || File.WriteError)!void {
    const file = std.fs.cwd().createFile(self.ctx.data_file_path, .{ .exclusive = true }) catch |err| {
        switch (err) {
            error.PathAlreadyExists => return,
            else => return err,
        }
    };
    defer file.close();

    try file.writer().writeInt(
        u16, // 2 bytes
        0, // Default total
        .little,
    );
    try std.io.getStdOut().writer().print("Initialized database file with name {s}!\n", .{self.ctx.data_file_path});
}

///Write a soul into data file
pub fn write(self: Self, soul: Soul) !void {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_write });
    defer file.close();
    try file.seekTo(0);
    const current_total = try file.reader().readInt(u16, .little);
    try file.seekTo(2 + current_total * @sizeOf(Soul));
    try file.writer().writeStruct(soul);
    try file.seekTo(0);
    try file.writer().writeInt(u16, current_total + 1, .little);
}

pub fn findA(self: Self, allocator: Allocator, name: []const u8) !?Soul {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_only });
    defer file.close();
    const souls = try self.getAll(allocator);
    if (name.len > 32) return SoulErr.NameTooLong;
    for (souls.items[0..souls.current_total]) |soul| {
        if (std.mem.eql(u8, &soul.name, @as(*[32]u8, @ptrCast(@constCast(name))))) {
            return soul;
        }
    }
    return null;
}

pub fn getAll(self: Self, allocator: Allocator) !SoulList {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_only });
    defer file.close();

    const current_total = try file.reader().readInt(u16, .little);

    var list = try SoulList.init(allocator);
    for (0..current_total) |_| {
        const soul = try file.reader().readStruct(Soul);
        try list.append(soul);
    }
    return list;
}

// TODO:
pub fn updateA() void {}

// TODO:
pub fn deleteA(self: Self, allocator: Allocator, name: []u8) !void {
    var found_idx: ?usize = undefined;
    if (name.len > 32) {
        return SoulErr.NameTooLong;
    }
    const souls = try self.getAll(allocator);
    find: for (souls.items, 0..) |soul, idx| {
        if (std.mem.eql(
            u8,
            &soul.name,
            @as(*[32]u8, @ptrCast(name)),
        )) {
            found_idx = idx;
            break :find;
        }
        found_idx = null;
    }
    if (found_idx) |idx| {
        print("{d}", .{idx});
    }
    return FindError.SoulNotFound;
}

test "file create, write, find" {
    const ctx = comptime TinySQLContext.init("test.db");
    const fileHandler = try Self.init(ctx);
    const allocator = std.heap.page_allocator;
    try fileHandler.createIfNotExists();

    const soul1 = try Soul.fromUserInput("Hung", 19);
    const soul2 = try Soul.fromUserInput("Ngoc", 18);
    const soul3 = try Soul.fromUserInput("Zigg", 20);

    try fileHandler.write(soul1);
    try fileHandler.write(soul2);
    try fileHandler.write(soul3);

    const found1 = try fileHandler.findA(allocator, "Hung");
    const found2 = try fileHandler.findA(allocator, "Ngoc");
    const found3 = try fileHandler.findA(allocator, "Zigg");

    try expect(found1 != null);
    try expect(found2 != null);
    try expect(found3 != null);
}

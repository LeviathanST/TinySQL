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
    if (!@import("builtin").is_test) {
        try std.io.getStdOut().writer().print("Initialized database file with name {s}!\n", .{self.ctx.data_file_path});
    }
}

///Write a soul into data file
pub fn write(self: Self, soul: Soul) !void {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_write });
    defer file.close();
    try file.seekTo(0);
    const current_total = try file.reader().readInt(u16, .little);
    try file.seekTo(2 + @as(usize, current_total) * @sizeOf(Soul));
    try file.writer().writeStruct(soul);
    try file.seekTo(0);
    try file.writer().writeInt(u16, current_total + 1, .little);
}

pub fn findA(self: Self, allocator: Allocator, name: []const u8) !?Soul {
    if (name.len > 32) return SoulErr.NameTooLong;
    const souls = try self.getAll(allocator);
    defer souls.deinit();
    for (souls.items[0..souls.current_total]) |soul| {
        if (std.mem.eql(u8, soul.name[0..name.len], name)) {
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

pub fn updateA(self: Self, name: []const u8, newData: Soul) !bool {
    var found_offset: usize = undefined;
    if (name.len > 32) return SoulErr.NameTooLong;
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_write });
    defer file.close();

    try file.seekTo(0);
    const currentTotal = try file.reader().readInt(u16, .little);

    find: for (0..currentTotal) |current_idx| {
        found_offset = 2 + current_idx * @sizeOf(Soul);
        try file.seekTo(found_offset);
        const soul: Soul = try file.reader().readStruct(Soul);
        if (std.mem.eql(u8, soul.name[0..name.len], name[0..])) {
            break :find;
        }
    }
    try file.seekTo(found_offset);
    try file.writer().writeStruct(newData);
    return true;
}

pub fn deleteA(self: Self, allocator: Allocator, name: []const u8) !void {
    var found_idx: ?usize = null;
    if (name.len > 32) return SoulErr.NameTooLong;
    var souls = try self.getAll(allocator);
    defer souls.deinit();
    find: for (souls.items, 0..) |soul, idx| {
        if (std.mem.eql(u8, soul.name[0..name.len], name[0..])) {
            found_idx = idx;
            break :find;
        }
    }
    if (found_idx) |idx| {
        try souls.removeAt(idx);
        try self.saveAll(souls);
        return;
    }
    return FindError.SoulNotFound;
}

fn saveAll(self: Self, souls: SoulList) !void {
    const file = cwd().createFile("temp", .{ .exclusive = true }) catch |err| {
        std.log.debug("Cannot create temp file!", .{});
        return err;
    };
    try file.seekTo(0);
    try file.writer().writeInt(u16, souls.current_total, .little);
    for (souls.items[0..souls.current_total]) |soul| {
        try file.writer().writeStruct(soul);
    }
    try cwd().deleteFile(self.ctx.data_file_path);
    try cwd().rename("temp", self.ctx.data_file_path);
}

test "File create" {
    const ctx = comptime TinySQLContext.init("test.db");
    const fileHandler = try Self.init(ctx);
    try fileHandler.createIfNotExists();
    try cwd().deleteFile("test.db");
}

test "Soul write, find, delete" {
    const expect = std.testing.expect;

    const ctx = comptime TinySQLContext.init("test.db");
    const fileHandler = try Self.init(ctx);
    const allocator = std.testing.allocator;
    try fileHandler.createIfNotExists();
    const soul1 = try Soul.fromUserInput("Hung", 19);

    try fileHandler.write(soul1);
    const hung = try fileHandler.findA(allocator, "Hung");
    try expect(hung != null);

    try fileHandler.deleteA(allocator, "Hung");
    const removed_hung = try fileHandler.findA(allocator, "Hung");
    try expect(removed_hung == null);

    try cwd().deleteFile("test.db");
}

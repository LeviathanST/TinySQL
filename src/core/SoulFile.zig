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
// Only support Linux
const detectCpu = std.zig.system.linux.detectNativeCpuAndFeatures;

const Error = error{CpuArchNotFound};
const Self = @This();

ctx: TinySQLContext,

pub fn init(comptime ctx: TinySQLContext) !Self {
    return Self{
        .ctx = ctx,
    };
}

///Create data file with 'filename' if not exists
pub fn createIfNotExists(self: Self) (File.OpenError || File.WriteError || Error)!void {
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

pub fn write(self: Self, soul: Soul) !void {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_write });
    defer file.close();

    var current_total = try file.reader().readInt(u16, .little);

    try file.seekBy(2 + current_total * @sizeOf(Soul));
    try file.writer().writeStruct(soul);

    current_total += 1;
    try file.seekTo(0);
    try file.writer().writeInt(u16, current_total, .little);
}

pub fn findA(self: Self, allocator: Allocator, name: []u8) !?Soul {
    const file = try cwd().openFile(self.ctx.data_file_path, .{ .mode = File.OpenMode.read_only });
    defer file.close();
    const souls = try self.getAll(allocator);
    const name_len = name.len;
    if (name_len > 32) return SoulErr.NameTooLong;
    var buf = [1]u8{0} ** 32;
    @memcpy(buf[0..name_len], name);
    for (souls.items[0..souls.current_total]) |soul| {
        std.debug.print("{d}\n", .{buf[0..]});
        std.debug.print("{d}\n", .{soul.name[0..]});
        if (std.mem.eql(u8, &soul.name, &buf)) {
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

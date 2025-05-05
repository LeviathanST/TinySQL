const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const assert = std.debug.assert;

pub const Soul = extern struct {
    pub const Error = error{NameTooLong};
    const Self = @This();

    name: [32]u8,
    age: u8,

    pub fn fromUserInput(name: []const u8, age: u8) Error!Self {
        const validated_name = try Self.getNameFromSlice(name);
        return .{
            .name = validated_name,
            .age = age,
        };
    }

    pub fn getNameFromSlice(name: []const u8) Error![32]u8 {
        if (name.len > 32) return Error.NameTooLong;
        var validated_name = [_]u8{0} ** 32;
        @memcpy(validated_name[0..name.len], name[0..]);
        return validated_name;
    }
};

/// The copied ArrayList for Soul
/// corresponds to std.ArrayList(Soul)
pub const SoulList = struct {
    const Self = @This();

    allocator: Allocator,
    items: []Soul,
    current_total: u16,
    capacity: usize,

    pub fn init(allocator: Allocator) !Self {
        return Self{
            .allocator = allocator,
            .items = &[0]Soul{},
            .current_total = 0,
            .capacity = 0,
        };
    }

    /// Free whole slice memory
    pub fn deinit(self: Self) void {
        self.allocator.free(self.intoSlice());
    }

    /// Returns a slice of all the souls plus the extra capacity,
    /// whose memory contents are 'undefined'.
    fn intoSlice(self: Self) []Soul {
        return self.items.ptr[0..self.capacity];
    }

    pub fn append(self: *Self, soul: Soul) Allocator.Error!void {
        const new_len = self.current_total + 1;
        try self.ensureTotalCapacity(new_len);
        self.items[self.current_total] = soul;
        self.current_total += 1;
    }

    /// Remove a soul at specific index
    pub fn removeAt(self: *Self, idx: usize) !void {
        var newItems = try self.allocator.alloc(Soul, self.capacity);
        var insert_idx: usize = 0;
        for (0..self.current_total) |current_idx| {
            if (current_idx == idx) {
                continue;
            }
            newItems[insert_idx] = self.items[current_idx];
            insert_idx += 1;
        }
        self.allocator.free(self.items);
        self.items = newItems;
        self.current_total -= 1;
    }

    /// Ensure 'new_len' is smaller than the current capacity,
    /// if not, it will increase.
    fn ensureTotalCapacity(self: *Self, new_len: usize) Allocator.Error!void {
        if (self.capacity < new_len) {
            const new_capacity = self.capacity + 5;
            assert(new_capacity > new_len);
            var new_memory = try self.allocator.alloc(Soul, new_capacity);
            @memcpy(new_memory[0..self.items.len], self.items);
            const old_items = self.items;
            self.capacity = new_capacity;
            self.items = new_memory;
            if (old_items.len > 0) {
                self.allocator.free(old_items);
            }
        }
    }
};

test "Append 3 items" {
    const allocator = std.testing.allocator;
    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    const soul1 = try Soul.fromUserInput("Hung", 19);
    const soul2 = try Soul.fromUserInput("Ngoc", 18);
    const soul3 = try Soul.fromUserInput("Zigg", 20);

    try souls.append(soul1);
    try souls.append(soul2);
    try souls.append(soul3);

    const slice = souls.intoSlice();
    try expect(std.mem.eql(u8, slice[0].name[0..4], "Hung"));
    try expect(slice[0].age == 19);
    try expect(std.mem.eql(u8, slice[1].name[0..4], "Ngoc"));
    try expect(slice[1].age == 18);
    try expect(std.mem.eql(u8, slice[2].name[0..4], "Zigg"));
    try expect(slice[2].age == 20);

    try expect(souls.capacity == 5);
    try expect(souls.current_total == 3);
}

test "Remove at" {
    const allocator = std.testing.allocator;
    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    const soul1 = try Soul.fromUserInput("Hung", 19);
    const soul2 = try Soul.fromUserInput("Ngoc", 18);
    const soul3 = try Soul.fromUserInput("Zigg", 20);

    try souls.append(soul1);
    try souls.append(soul2);
    try souls.append(soul3);

    try expect(souls.current_total == 3);
    try souls.removeAt(1);
    try expect(souls.current_total == 2);
    try expect(std.mem.eql(u8, souls.items[1].name[0..4], "Zigg"));
    try expect(souls.items[1].age == 20);

    try souls.append(soul2);
    try souls.removeAt(1);
    try expect(std.mem.eql(u8, souls.items[1].name[0..4], "Ngoc"));
    try expect(souls.items[1].age == 18);
}

test "Error" {
    const allocator = std.testing.allocator;
    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    var buffer_too_long: [34]u8 = [_]u8{0} ** 34;
    @memcpy(buffer_too_long[0.."ThisNameIsWayTooLongToFitIn32Bytes".len], "ThisNameIsWayTooLongToFitIn32Bytes");

    try std.testing.expectError(Soul.Error.NameTooLong, Soul.fromUserInput(&buffer_too_long, 19));
}

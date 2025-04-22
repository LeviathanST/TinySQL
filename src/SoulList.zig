///! The copying of ArrayList
// TODO: Test
const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const assert = std.debug.assert;

const SoulError = error{NameTooLong};

pub const Soul = struct {
    name: [32]u8,
    age: u8,
};
pub const SoulList = struct {
    allocator: Allocator,
    items: []Soul,
    current_total: usize,
    capacity: usize,

    const Self = @This();

    pub fn init(allocator: Allocator) anyerror!Self {
        return Self{
            .allocator = allocator,
            .items = &[0]Soul{},
            .current_total = 0,
            .capacity = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.intoSlice());
    }

    /// Returns a slice of all the souls plus the extra capacity,
    /// whose memory contents are 'undefined'.
    fn intoSlice(self: *Self) []Soul {
        return self.items.ptr[0..self.capacity];
    }

    pub fn append(self: *Self, name: []u8, age: u8) (Allocator.Error || SoulError)!void {
        if (name.len > 32) return SoulError.NameTooLong;
        var validated_name = [_]u8{0} ** 32;
        @memcpy(validated_name[0..name.len], name);
        const soul = Soul{
            .name = validated_name,
            .age = age,
        };
        const new_len = self.current_total + 1;
        try self.ensureTotalCapacity(new_len);
        self.items[self.current_total] = soul;
        self.current_total += 1;
    }

    /// Ensure 'new_len' is smaller than the current capacity,
    /// if not, it will increase.
    fn ensureTotalCapacity(self: *Self, new_len: usize) Allocator.Error!void {
        if (self.capacity < new_len) {
            const new_capacity = self.capacity + 5;
            assert(new_capacity > new_len);
            var new_memory = try self.allocator.alloc(Soul, new_capacity);
            @memcpy(new_memory[0..self.items.len], self.items);
            self.capacity = new_capacity;
            self.items = new_memory;
        }
    }
};

test "Append 3 items" {
    const allocator = std.testing.allocator;
    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    var name_hung: [32]u8 = [_]u8{0} ** 32;
    @memcpy(name_hung[0.."Hung".len], "Hung");
    var name_alice: [32]u8 = [_]u8{0} ** 32;
    @memcpy(name_alice[0.."Alice".len], "Alice");
    var name_bob: [32]u8 = [_]u8{0} ** 32;
    @memcpy(name_bob[0.."Bob".len], "Bob");

    try souls.append(&name_hung, 19);
    try souls.append(&name_alice, 20);
    try souls.append(&name_bob, 21);

    const slice = souls.intoSlice();
    try expect(std.mem.eql(u8, slice[0].name[0..4], "Hung"));
    try expect(slice[0].age == 19);
    try expect(std.mem.eql(u8, slice[1].name[0..5], "Alice"));
    try expect(slice[1].age == 20);
    try expect(std.mem.eql(u8, slice[2].name[0..3], "Bob"));
    try expect(slice[2].age == 21);

    try expect(souls.capacity == 5);
    try expect(souls.current_total == 3);
}

test "Error" {
    const allocator = std.testing.allocator;
    var souls = try SoulList.init(allocator);
    defer souls.deinit();

    var buffer_too_long: [34]u8 = [_]u8{0} ** 34;
    @memcpy(buffer_too_long[0.."ThisNameIsWayTooLongToFitIn32Bytes".len], "ThisNameIsWayTooLongToFitIn32Bytes");

    try std.testing.expectError(SoulError.NameTooLong, souls.append(&buffer_too_long, 200));
}

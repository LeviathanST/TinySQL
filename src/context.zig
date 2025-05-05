const std = @import("std");
const File = std.fs.File;
const Reader = std.io.Reader;
const Writer = std.io.Writer;

stdin: Reader(File, File.ReadError, File.read),
stdout: Writer(File, File.WriteError, File.write),
data_file_path: []const u8,

const Self = @This();

pub fn init(comptime data_file_path: []const u8) Self {
    return .{
        .stdin = std.io.getStdIn().reader(),
        .stdout = std.io.getStdOut().writer(),
        .data_file_path = data_file_path,
    };
}

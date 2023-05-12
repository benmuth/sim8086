const std = @import("std");
const print = @import("std").debug.print;
const code = @import("encoding.zig");

const resource_dir = "/Users/ben/Documents/Programming/perf-aware/resources/part1";

pub fn main() !void {
    var fileName = getFileName() catch {
        print("failed to get file name", .{});
        return;
    };

    var file = openFile(fileName) catch {
        print("failed to open file with file name {s}", .{fileName});
        return;
    };
    defer file.close();

    const fs = try file.stat();

    // print("{d}\n", .{fs.size});

    const size = 100;

    var buf: [size]u8 = undefined;
    _ = try file.read(&buf);

    var data = buf[0..fs.size];

    code.decode(data);
}

fn getFileName() FileError![]const u8 {
    var args = std.process.args();

    // skip the name of this binary
    _ = args.skip();
    var file = args.next();
    if (file) |name| { // payload capture
        return name;
    } else {
        return FileError.NoFileGiven;
    }
}

const FileError = error{NoFileGiven};

fn openFile(fileName: []const u8) !std.fs.File {
    var dir = std.fs.openDirAbsolute(resource_dir, .{ .access_sub_paths = true }) catch |err| {
        print("failed to open dir", .{});
        return err;
    };

    defer dir.close();

    const file = dir.openFile(fileName, .{}) catch |err| {
        print("failed to open file in resource dir\n", .{});
        return err;
    };
    return file;
}

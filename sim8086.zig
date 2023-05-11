const std = @import("std");
const print = @import("std").debug.print;

pub fn main() void {
    var file_name = getFileName() catch |err| {
        if (err == FileError.NoFileGiven) {
            print("no file given", .{});
        }
        return;
    };
    print("{s}\n", .{file_name});
}

fn getFileName() FileError![]const u8 {
    var args = std.process.args();

    // skip the name of the binary
    _ = args.skip();
    var file = args.next();
    if (file) |name| { // payload capture
        return name;
    } else {
        return FileError.NoFileGiven;
    }
}

const FileError = error{NoFileGiven};

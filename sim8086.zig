const std = @import("std");
const print = @import("std").debug.print;

pub fn main() void {
    var args = std.process.args();

    // skip the name of the binary
    _ = args.skip();
    var file = args.next();
    if (file) |name| { // payload capture
        print("{s}\n", .{name});
    } else {
        print("give the file name as an argument\n", .{});
    }
}

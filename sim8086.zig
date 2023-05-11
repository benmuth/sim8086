const std = @import("std");
const print = @import("std").debug.print;

pub fn main() void {
    // std.debug.print("Hello world!\n", .{});
    var args = std.process.args();
    // const arg0 = args.next().?[0];
    while (true) {
        var arg = args.next() orelse break;
        print("{s}\n", .{arg});
    }
}

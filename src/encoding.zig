const std = @import("std");
const print = std.debug.print;

pub fn decode(buf: []u8) void {
    // std.debug.print("Decoding...\n", .{});
    // std.debug.print("buf: {b}\n", .{buf});

    print("bits 16\n", .{});

    var i: usize = 0;
    while (i < buf.len) : (i += 2) {
        var instrBytes = [2]u8{ buf[i], buf[i + 1] };
        var instr = parseInstruction(instrBytes) catch {
            print("ERROR: failed to parse instructions", .{});
            return;
        };
        disasm(instr);
    }
}

const ReadError = error{FailedToParse};

pub fn parseInstruction(bytes: [2]u8) ReadError!instruction {
    const b1 = bytes[0];
    const b2 = bytes[1];
    // print("original bytes: {b}, {b}\n", .{ b1, b2 });
    var ret = instruction{};
    const fields = std.meta.fields(instrFields);
    // const fields = @typeInfo(instruction).Struct.fields;
    inline for (fields) |field| {
        switch (field.value) {
            @enumToInt(instrFields.opcode) => {
                ret.opcode = (b1 & 0b11111100) >> 2;
            },
            @enumToInt(instrFields.d) => {
                ret.d = (b1 & 0b00000010) >> 1;
            },
            @enumToInt(instrFields.w) => {
                ret.w = (b1 & 0b00000001) >> 0;
            },
            @enumToInt(instrFields.mod) => {
                ret.mod = (b2 & 0b11000000) >> 6;
            },
            @enumToInt(instrFields.reg) => {
                ret.reg = (b2 & 0b00111000) >> 3;
            },
            @enumToInt(instrFields.rm) => {
                ret.rm = (b2 & 0b00000111) >> 0;
            },
            else => {
                return ReadError.FailedToParse;
            },
        }
    }

    return ret;
}

pub fn disasm(instr: instruction) void {
    var opcode = "opc";
    switch (@intToEnum(opcodes, instr.opcode)) {
        // opcodes.MOV => print("mov\n", .{}),
        opcodes.MOV => opcode = "mov",
    }

    var regs = [2]u8{ instr.reg, instr.rm };
    if (instr.d == 0) {
        regs[0] = instr.rm;
        regs[1] = instr.reg;
    }
    var regsAsm = [2][]const u8{ "", "" };
    for (regs, 0..) |reg, i| {
        switch (reg) {
            0b000 => {
                if (instr.w == 0) {
                    regsAsm[i] = "al";
                } else {
                    regsAsm[i] = "ax";
                }
            },
            0b001 => {
                if (instr.w == 0) {
                    regsAsm[i] = "cl";
                } else {
                    regsAsm[i] = "cx";
                }
            },
            0b010 => {
                if (instr.w == 0) {
                    regsAsm[i] = "dl";
                } else {
                    regsAsm[i] = "dx";
                }
            },
            0b011 => {
                if (instr.w == 0) {
                    regsAsm[i] = "bl";
                } else {
                    regsAsm[i] = "bx";
                }
            },
            0b100 => {
                if (instr.w == 0) {
                    regsAsm[i] = "ah";
                } else {
                    regsAsm[i] = "sp";
                }
            },
            0b101 => {
                if (instr.w == 0) {
                    regsAsm[i] = "ch";
                } else {
                    regsAsm[i] = "bp";
                }
            },
            0b110 => {
                if (instr.w == 0) {
                    regsAsm[i] = "dh";
                } else {
                    regsAsm[i] = "si";
                }
            },
            0b111 => {
                if (instr.w == 0) {
                    regsAsm[i] = "bh";
                } else {
                    regsAsm[i] = "di";
                }
            },
            else => print("INVALID\n", .{}),
        }
    }
    print("{s} {s}, {s}\n", .{ opcode, regsAsm[0], regsAsm[1] });
}

pub const instrFields = enum(u8) { opcode, d, w, mod, reg, rm };

const instruction = struct {
    opcode: u8 = 0,
    d: u8 = 0,
    w: u8 = 0,
    mod: u8 = 0,
    reg: u8 = 0,
    rm: u8 = 0,

    pub fn printMe(self: *instruction) void {
        const fields = std.meta.fields(@TypeOf(self.*));
        inline for (fields) |field| {
            print("{s}: {b} ", .{ field.name, @field(self.*, field.name) });
        }
        print("\n", .{});
    }
};

const opcodes = enum(u6) { MOV = 0b100010 };

const registers = enum {
    AL,
    CL,
    DL,
    BL,
    AH,
    CH,
    DH,
    BH,
    AX,
    CX,
    DX,
    BX,
    SP,
    BP,
    SI,
    DI,
};

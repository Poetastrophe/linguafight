const std = @import("std");
const Self = @This();
letter: u5 = undefined,
const DanishAlpha = "abcdefghijklmnopqrstuvwxyzæøå";

pub fn utf_encoded_danish_letter_to_integer(char: []const u8) u5 {
    var i: u64 = 0;
    var alphapos: u5 = 0;
    while (i < DanishAlpha.len) : (alphapos += 1) {
        if (DanishAlpha[i] & 0b10000000 == 0) {
            if (DanishAlpha[i] == char[0]) {
                return alphapos;
            }
            i += 1;
        } else {
            if (std.mem.eql(u8, DanishAlpha[i .. i + 2], char)) {
                return alphapos;
            }
            i += 2;
        }
    }
    return std.math.maxInt(u5);
}

pub fn integer_to_utf_8_encoded_danish_letter(letter: u5) []const u8 {
    var i: u64 = 0;
    var alphapos: u5 = 0;
    while (i < DanishAlpha.len and alphapos <= letter) : (alphapos += 1) {
        if (DanishAlpha[i] & 0b10000000 == 0) {
            if (alphapos == letter) {
                return DanishAlpha[i .. i + 1];
            }
            i += 1;
        } else {
            if (alphapos == letter) {
                return DanishAlpha[i .. i + 2];
            }
            i += 2;
        }
    }
    return DanishAlpha[0 .. 0 + 1];
}

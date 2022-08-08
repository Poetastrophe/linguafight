const std = @import("std");
const WordList = @import("./WordList.zig");
const BPermIter = @import("./BinomialPermutations.zig");
const print = std.debug.print;

pub fn main() anyerror!void {
    const bp = BPermIter.BinomialPermutations(4);
    bp.init();
    for(bp.combinations) |perm{
    }
}


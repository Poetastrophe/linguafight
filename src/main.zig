const std = @import("std");
const DanishChar = @import("./DanishChar.zig");
const BPermIter = @import("./BinomialPermutations.zig");
const WordList = @import("./WordList.zig");
const print = std.debug.print;

pub fn main() anyerror!void {
    //var bp = BPermIter.BinomialPermutations(4){};
    //bp.init();
    //for (bp.combinations) |perm| {
    //    std.debug.print("{any}",.{perm});
    //}
    // const hehe = "å";
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    _ = WordList.DanishWordList.init(arena.allocator());
    const char = DanishChar.utf_encoded_danish_letter_to_integer("å");
    // _=hehe;

    std.debug.print("{}\n", .{char});
    std.debug.print("{s}\n", .{DanishChar.integer_to_utf_8_encoded_danish_letter(char)});
}

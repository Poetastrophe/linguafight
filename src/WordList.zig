const std = @import("std");
const DanishChar = @import("DanishChar.zig");
const binarySearch = std.sort.binarySearch;
const Allocator = std.mem.Allocator;
const math = std.math;
const print = std.debug.print;

pub const DanishWordList = struct {
    const Self = @This();
    da_wl: [][]const u5,

    pub fn init(allocator: Allocator) Self {
        const file = std.fs.cwd().openFile("src/third_party/dansk.txt", .{}) catch unreachable;
        defer file.close();
        _ = allocator;

        std.debug.print("byte is:{}\n", .{file.reader().readByte() catch unreachable});
        var testtest: [7][]u5 = undefined;
        return Self{
            .da_wl = testtest[0..],
        };
    }
    // 11000011 10100110
    // 50086

    // 50104 	11000011 10111000

    // 11000011 10100101
    // 50085 	11000011 10100101

    pub fn contains_index(self: *const @This(), key: []const u8) ?usize {
        return binarySearch([]const u8, key, self.da_wl[0..self.da_wl.len], {}, std.mem.lessThan);
    }
    pub fn contains(self: *const @This(), key: []const u8) bool {
        if (self.contains_index(key)) |_| {
            return true;
        } else {
            return false;
        }
    }
};

// test "contains(\"harefod\")" {
//     var wl = DanishWordList{};
//     wl.init();
//     const i = wl.contains_index("harefod");
//     try std.testing.expect(DanishWordList.compareStrings({}, wl.da_wl[i.?], "harefod") == .eq);
// }

// test "extremeties" {
//     var wl = DanishWordList{};
//     wl.init();
//     var start = wl.da_wl[0];
//     var i: u64 = wl.contains_index(start).?;
//     try std.testing.expect(i == 0);
//     var end = wl.da_wl[wl.da_wl.len - 1];
//     i = wl.contains_index(end).?;
//     try std.testing.expect(i == wl.da_wl.len - 1);
// }

const std = @import("std");
const binarySearch = std.sort.binarySearch;
const math = std.math;
const print = std.debug.print;
const da_embedded_wordlist = @embedFile("./../dansk.txt");

// REVIEW: Er en god optimering at loade det ind i et array med fixedwidth
// [N]u8s eller vinder man ikke noget ift. ved at gøre det på den måde  man gør det
// nu
// TODO: Lav det mere generelt så man kan modtage en fil med ord og loade det
// ind, i stedet for at embedde filen og referer til det.
pub const DanishWordList = struct {
    const Self = @This();
    danish_wordlist_raw: [700000][]const u8 = .{undefined} ** 700000,
    da_wl: [][]const u8 = undefined,

    pub fn init(self: *Self) void {
        var iter = std.mem.tokenize(u8, da_embedded_wordlist, ",.\r\n ");
        var i: u64 = 0;
        while (iter.next()) |word| : (i += 1) {
            self.danish_wordlist_raw[i] = word;
        }
        self.da_wl = self.danish_wordlist_raw[0..i];
    }

    fn compareStrings(_: void, a: []const u8, b: []const u8) math.Order {
        for (if (a.len < b.len) a else b) |_, i| {
            if (a[i] < b[i]) {
                return math.Order.lt;
            } else if (a[i] > b[i]) {
                return math.Order.gt;
            }
        }
        if (a.len < b.len) {
            return math.Order.lt;
        }
        if (a.len > b.len) {
            return math.Order.gt;
        }
        return math.Order.eq;
    }
    pub fn contains(self: *const @This(), key: []const u8) ?usize {
        return binarySearch([]const u8, key, self.da_wl[0..self.da_wl.len], {}, compareStrings);
    }
};

test "contains(\"harefod\")" {
    var wl = DanishWordList{};
    wl.init();
    const i = wl.contains("harefod");
    try std.testing.expect(DanishWordList.compareStrings({}, wl.da_wl[i.?], "harefod") == .eq);
}

test "extremeties" {
    var wl = DanishWordList{};
    wl.init();
    var start = wl.da_wl[0];
    var i: u64 = wl.contains(start).?;
    try std.testing.expect(i == 0);
    var end = wl.da_wl[wl.da_wl.len - 1];
    i = wl.contains(end).?;
    try std.testing.expect(i == wl.da_wl.len - 1);
}

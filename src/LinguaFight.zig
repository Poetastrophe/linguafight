const assert = @import("std").debug.assert;
const std = @import("std");
const expect = std.testing.expect;
const cast = std.math.cast;

fn not_implemented() void {
    std.debug.panic("", .{});
}
const Direction = enum {
    horizontal,
    vertical,
};

const Qualifier = union(enum) {
    DW,
    TW,
    DL,
    TL,
};

//BL: Board length (standard 15)
//N: Insertion letter length (standard 7)
pub fn GenericWordFeudBoard(comptime BL: u64, comptime N: u64) type {
    return struct {
        const Self = @This();
        //A tile can contain a letter, and can contain a qualifier, or both, or none
        const Tile = struct {
            l: ?u8,
            q: ?Qualifier,
        };

        const Board = [BL][BL]Tile;
        board: Board = blk: {
            var res: Board = undefined;
            var x = 0;
            while (x < BL) : (x += 1) {
                var y = 0;
                while (y < BL) : (y += 1) {
                    res[x][y] = .{ .l = null, .q = null };
                }
            }
            break :blk res;
        },

        const Insertion = struct {
            letters: [N:0]u8,
            x: u64,
            y: u64,
            dir: Direction,
        };

        const WordTiles = [BL:null]?Tile;

        pub fn init(self: *Self, str: []const u8) void {
            var iter = std.mem.tokenize(u8, str, "\n");
            var tmpy: u64 = 0;
            while (tmpy < BL) : (tmpy += 1) {
                const y = BL - tmpy - 1;
                var x: u64 = 0;
                const cur_line = iter.next().?;
                var cur_line_iter = std.mem.tokenize(u8, cur_line, " ");
                while (x < BL) : (x += 1) {
                    var tmp_cur_elem = cur_line_iter.next().?;
                    var cur_elem = tmp_cur_elem[0];
                    if (cur_elem == '_') {
                        self.board[x][y] = Tile{ .l = null, .q = null };
                    } else if (cur_elem == 'V') {
                        self.board[x][y] = Tile{ .l = null, .q = Qualifier.DW };
                    } else if (cur_elem == 'W') {
                        self.board[x][y] = Tile{ .l = null, .q = Qualifier.TW };
                    } else if (cur_elem == 'I') {
                        self.board[x][y] = Tile{ .l = null, .q = Qualifier.DL };
                    } else if (cur_elem == 'L') {
                        self.board[x][y] = Tile{ .l = null, .q = Qualifier.TL };
                    } else {
                        self.board[x][y] = Tile{ .l = cur_elem, .q = null };
                    }
                }
            }
        }

        pub fn to_string(self: *const Self) [(BL * 2) * BL:0]u8 {
            var res: [(BL * 2) * BL:0]u8 = [_:0]u8{0} ** ((BL * 2) * BL);
            var res_i: u64 = 0;
            var tmpy: u64 = 0;
            while (tmpy < BL) : (tmpy += 1) {
                const y = BL - tmpy - 1;
                var x: u64 = 0;
                while (x < BL) : (x += 1) {
                    if (self.board[x][y].l == null and self.board[x][y].q == null) {
                        res[res_i] = '_';
                        res_i += 1;
                    } else if (self.board[x][y].l) |l| {
                        res[res_i] = l;
                        res_i += 1;
                    } else if (self.board[x][y].q) |q| { //qualifier only
                        switch (q) {
                            Qualifier.DW => res[res_i] = 'V',
                            Qualifier.TW => res[res_i] = 'W',
                            Qualifier.DL => res[res_i] = 'I',
                            Qualifier.TL => res[res_i] = 'L',
                        }
                        res_i += 1;
                    }
                    if (x != BL - 1) {
                        res[res_i] = ' ';
                        res_i += 1;
                    }
                }
                res[res_i] = '\n';
                res_i += 1;
            }
            return res;
        }
        pub fn print(self: *Self) void {
            var tmpy: u64 = 0;
            while (tmpy < BL) : (tmpy += 1) {
                const y = BL - tmpy - 1;
                var x: u64 = 0;
                while (x < BL) : (x += 1) {
                    if (self.board[x][y].l == null and self.board[x][y].q == null) {
                        std.debug.print("_ ", .{});
                    } else if (self.board[x][y].l) |l| {
                        const buf = [_]u8{l};
                        std.debug.print("{s} ", .{buf});
                    } else if (self.board[x][y].q) |q| { //qualifier only
                        switch (q) {
                            Qualifier.DW => std.debug.print("{s} ", .{"V"}),
                            Qualifier.TW => std.debug.print("{s} ", .{"W"}),
                            Qualifier.DL => std.debug.print("{s} ", .{"I"}),
                            Qualifier.TL => std.debug.print("{s} ", .{"L"}),
                        }
                    }
                }
                std.debug.print("\n", .{});
            }
        }

        pub fn clone(self: *Self) [BL][BL]Tile {
            return self.board;
        }

        pub fn insert(self: *Self, insertion: Insertion) void {
            var x: u64 = insertion.x;
            var y: u64 = insertion.y;
            var i_let: i64 = 0;
            if (insertion.dir == Direction.horizontal) {
                while (x < BL) : (x += 1) {
                    if (self.board[x][y].l == null) {
                        self.board[x][y].l = insertion.letters[i_let];
                        i_let += 1;
                    }
                }
            } else {
                var iy = cast(i64, y).?;
                while (iy >= 0) : (iy -= 1) {
                    const uy = cast(u64, iy).?;
                    if (self.board[x][uy].l == null) {
                        self.board[x][uy].l = insertion.letters[i_let];
                        i_let += 1;
                    }
                }
            }
        }

        // There can be at most BL+1 (BL words for each orthogonal word to the
        // direction og insertion, and exactly 1 word for the direction of
        // insertion)
        pub fn getWords(self: *const Self, insertion: Insertion) [BL + 1:null]?WordTiles {
            var x: i64 = insertion.start_x;
            var y: i64 = insertion.start_y;
            var res = [_:null]?WordTiles{null} ** (BL + 1);
            var i_res = 0;
            res[i_res] = extractWord(self, insertion.letters, insertion.start_x, insertion.start_y, insertion.dir);
            i_res += 1;
            var i_let: i64 = 0;
            if (insertion.dir == Direction.horizontal) {
                while (x < BL) : (x += 1) {
                    if (self.board[x][y].l == null) {
                        res[i_res] = extractWord(self, insertion.letters[i_let], x, y, inv(insertion.dir));
                        i_res += 1;
                    }
                }
            } else {
                while (y >= 0) : (y -= 1) {
                    if (self.board[x][y].l == null) {
                        res[i_res] = extractWord(self, insertion.letters[i_let], x, y, inv(insertion.dir));
                        i_res += 1;
                    }
                }
            }
            return res;
        }

        pub fn getString(wt: WordTiles) [BL:0]u8 {
            var res: [BL]u8 = [_]u8{0} ** BL;
            var i_res: u64 = 0;
            for (wt) |elem| {
                if (elem.l) |l| {
                    res[i_res] = l;
                    i_res += 1;
                } else {
                    break;
                }
            }
            return res;
        }

        pub fn letterToPoints(letter: u8) u64 {
            //TODO: Find ud af hvor mange point æøå giver
            //TODO: Det er et problem at æøå ikke umiddelbart ligger tæt med
            //ascii a-z, så kan man ikke lave fancy direkte manipulation, hvad
            //gør man så?
            //                           a  b  c  d  e  f  g  h  i  j   k  l  m  n  o  p  q   r  s  t  u  v  w  x  y  z   æ   ø   å
            const let_to_point = [_]u64{ 1, 4, 4, 2, 1, 4, 3, 4, 1, 10, 5, 1, 3, 1, 1, 4, 10, 1, 1, 1, 2, 4, 4, 8, 4, 10, 7, 11, 13 };
            if ('a' <= letter and letter <= 'z') {
                return let_to_point[letter - 'a'];
            } else {
                //TODO: Is it correct to assume that æ is the first letter in asciiextended?
                return let_to_point[let_to_point.len - 3 + letter - 'æ'];
            }
        }

        pub fn getPoints(word_tiles: WordTiles) u64 {
            var pointsum: u64 = 0;
            var multsum: u64 = 0;
            var i: u64 = 0;
            while (word_tiles[i]) |wt| : (i += 1) {
                var qualifiermult = 1;
                if (wt.t) |t| {
                    if (wt.q) |q| {
                        switch (q) {
                            .TL => {
                                qualifiermult = 3;
                            },
                            .DL => {
                                qualifiermult = 2;
                            },
                            .TW => {
                                multsum += 3;
                            },
                            .DW => {
                                multsum += 2;
                            },
                        }
                    }
                    pointsum += qualifiermult * letterToPoints(t);
                }
            }

            if (multsum == 0) {
                return pointsum;
            } else {
                return multsum * pointsum;
            }
        }

        fn inv(dir: Direction) Direction {
            if (dir == Direction.horizontal) {
                return Direction.vertical;
            } else {
                return Direction.horizontal;
            }
        }

        pub fn extractWord(self: *const Self, letters: []const u8, start_x: i64, start_y: i64, insert_direction: Direction) WordTiles {
            var res: WordTiles = [_:null]Tile{null} * BL;
            var i_res: u64 = 0;
            var i_let: u64 = 0;

            if (insert_direction == Direction.horizontal) {
                var x: i64 = seek_left: {
                    var xp: i64 = if (start_x - 1 > 0) start_x - 1 else start_x;
                    while (self.board[xp][start_y].l != null and xp >= 0) : (xp -= 1) {
                        xp -= 1;
                    }
                    break :seek_left xp;
                };
                while (x < BL and i_let < letters.len) : (x += 1) {
                    if (self.board[x][start_y].l) |l| {
                        res[i_res] = Tile{ .l = l, .q = null };
                        i_res += 1;
                        continue;
                    } else {
                        res[i_res] = Tile{ .l = letters[i_let], .q = self.board[x][start_y].q };
                        i_let += 1;
                        i_res += 1;
                    }
                }
            } else {
                var y: i64 = seek_up: {
                    var yp: i64 = if (start_y + 1 < BL) start_y + 1 else start_y;
                    while (self.board[start_x][yp].l != null and yp < BL) : (yp += 1) {}
                    break :seek_up yp;
                };
                while (y >= 0 and i_let < letters.len) : (y -= 1) {
                    if (self.board[start_x][y].l) |l| {
                        res[i_res] = Tile{ .l = l, .q = null };
                        i_res += 1;
                    } else {
                        res[i_res] = Tile{ .l = letters[i_let], .q = self.board[start_x][y].q };
                        i_let += 1;
                        i_res += 1;
                    }
                }
            }
            return res;
        }

        pub fn isInsertionTooLong(self: *const Self, insertion: Insertion) bool {
            var x: u64 = insertion.x;
            var y: u64 = insertion.y;
            var i_let: i64 = 0;
            if (insertion.dir == Direction.horizontal) {
                while (x < BL) : (x += 1) {
                    if (self.board[x][y].l) |_| {} else {
                        i_let += 1;
                    }
                }
            } else {
                while (y >= 0) : (y -= 1) {
                    if (self.board[x][y].l) |_| {} else {
                        i_let += 1;
                    }
                    if (y == 0) {
                        break;
                    }
                }
            }
            //i_let is the number of letters that can be written while length is the number of letters written
            return sentiLen(insertion.letters) > i_let;
        }

        //TODO make this generic
        pub fn sentiLen(array: [N:0]u8) u64 {
            for (array) |_, i| {
                if (array[i] == 0) {
                    return i;
                }
            }
            unreachable;
        }

        // Here it is assumed that the middle exists and therefore we can just check for adjacent tiles
        pub fn isBoardConnected(self: *const Self, insertion: Insertion) bool {
            // Check if the thing will go through the middle, if the middle
            // is not taken
            if (self.board[BL / 2][BL / 2].l) |_| {} else {
                if (insertion.dir == Direction.horizontal) {
                    if (insertion.y == BL / 2) {
                        return insertion.x <= BL / 2 and BL / 2 <=
                            insertion.x + sentiLen(insertion.letters) - 1;
                    }
                } else {
                    if (insertion.x == BL / 2) {
                        return insertion.y >= BL / 2 and BL / 2 >=
                            insertion.y - sentiLen(insertion.letters) + 1;
                    }
                }
            }

            var iintx = cast(i64, insertion.x).?;
            var iinty = cast(i64, insertion.y).?;
            var i_let: i64 = 0;

            if (insertion.dir == Direction.horizontal) {
                while (iintx < BL and i_let < sentiLen(insertion.letters)) : (iintx += 1) {
                    const x = cast(u64, iintx).?;
                    const y = cast(u64, iinty).?;
                    if (self.board[x][y].l == null) {
                        i_let += 1;
                        if (iintx + 1 < BL and self.board[x + 1][y].l != null) {
                            return true;
                        }
                        if (iintx - 1 >= 0 and self.board[x - 1][y].l != null) {
                            return true;
                        }
                        if (iinty - 1 >= 0 and self.board[x][y - 1].l != null) {
                            return true;
                        }
                        if (iinty + 1 < BL and self.board[x][y + 1].l != null) {
                            return true;
                        }
                    }
                }
            } else {
                while (iinty >= 0 and i_let < sentiLen(insertion.letters)) : (iinty -= 1) {
                    const x = cast(u64, iintx).?;
                    const y = cast(u64, iinty).?;
                    if (self.board[x][y].l == null) {
                        i_let += 1;
                        if (iintx + 1 < BL and self.board[x + 1][y].l != null) {
                            return true;
                        }
                        if (iintx - 1 >= 0 and self.board[x - 1][y].l != null) {
                            return true;
                        }
                        if (iinty - 1 >= 0 and self.board[x][y - 1].l != null) {
                            return true;
                        }
                        if (iinty + 1 < BL and self.board[x][y + 1].l != null) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        const InvalidStateError = error{
            insertionTooLong,
            boardNotConnected,
            //boardContainsInvalidWord, TODO make outside of this
        };
    };
}
test "boardStringToBoard" {
    //DW = V
    //TW = W
    //DL = I
    //TL = L
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ L _ _ _ _
        \\_ _ _ _ I _ _ _ _ _ _ _ _ V _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\_ _ _ _ _ _ l u g t e r _ _ _
        \\_ _ _ _ _ _ _ p _ _ _ u _ _ _
        \\_ _ _ _ _ _ h e j _ _ g _ _ _
        \\_ _ _ _ _ _ _ r a v i e o l i
        \\_ _ _ _ _ _ _ _ _ W _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ V _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ W _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    ;
    var wf = GenericWordFeudBoard(15, 7){};
    wf.init(boardstring);
    std.debug.print("\n", .{});
    wf.print();
}
test "isInsertionTooLong" {
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\a _ _ _ _ _ _ _ _ _ L _ _ _ _
        \\b _ _ _ I _ _ _ _ _ _ _ _ V _
        \\c _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\d _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\e _ _ _ _ _ l u g t e r _ _ _
        \\f _ _ _ _ _ _ p _ _ _ u _ _ _
        \\g _ _ _ _ _ h e j _ _ g _ _ _
        \\h _ _ _ _ _ _ r a v i e o l i
        \\i _ _ _ _ _ _ _ _ W _ _ _ _ _
        \\k _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\l _ _ _ _ _ _ _ _ _ _ _ _ V _
        \\m _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ W _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    ;
    //    0 1 2 3 4 5
    const WfTypes = GenericWordFeudBoard(15, 7);
    var wf = WfTypes{};
    wf.init(boardstring);
    var letters = "va" ++ [_]u8{0} ** 5;
    const insert = WfTypes.Insertion{ .letters = letters.*, .x = 5, .y = 6, .dir = Direction.horizontal };
    try expect(!wf.isInsertionTooLong(insert));
    var letters2 = "vario" ++ [_]u8{0} ** 2;
    const insert2 = WfTypes.Insertion{ .letters = letters2.*, .x = 5, .y = 6, .dir = Direction.horizontal };
    try expect(wf.isInsertionTooLong(insert2));
    var letters3 = "var" ++ [_]u8{0} ** 4;
    const insert3 = WfTypes.Insertion{ .letters = letters3.*, .x = 5, .y = 6, .dir = Direction.horizontal };
    try expect(wf.isInsertionTooLong(insert3));

    var letters4 = "var" ++ [_]u8{0} ** 4;
    const insert4 = WfTypes.Insertion{ .letters = letters4.*, .x = 0, .y = 14, .dir = Direction.vertical };
    try expect(!wf.isInsertionTooLong(insert4));

    var letters5 = "vari" ++ [_]u8{0} ** 3;
    const insert5 = WfTypes.Insertion{ .letters = letters5.*, .x = 0, .y = 14, .dir = Direction.vertical };
    try expect(wf.isInsertionTooLong(insert5));
}

test "isBoardConnected middle" {
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    ;
    const Wf = GenericWordFeudBoard(15, 7);
    var wf = Wf{};
    wf.init(boardstring);
    var letters = "vari" ++ [_]u8{0} ** 3;
    // Horizontal tests
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 0, .y = 14, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 3, .y = 7, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 4, .y = 7, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 4, .y = 6, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }

    // Vertical tests
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 7, .y = 12, .dir = Direction.vertical };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 7, .y = 10, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 6, .y = 10, .dir = Direction.vertical };
        try expect(!wf.isBoardConnected(insert));
    }
}

test "isBoardConnectedRandom" {
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ h _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ v _ _ _ _ _ _ _
        \\_ _ _ _ _ _ h e j s a _ _ _ _
        \\_ _ _ _ _ _ _ r _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ d _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ a _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ g _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    ;
    const Wf = GenericWordFeudBoard(15, 7);
    var wf = Wf{};
    wf.init(boardstring);
    var letters = "vari" ++ [_]u8{0} ** 3;
    //above h test, horizontal
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 4, .y = 10, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 3, .y = 10, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 7, .y = 10, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 8, .y = 10, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    //through d test, horizontal
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 7, .y = 5, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 8, .y = 5, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 9, .y = 5, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 2, .y = 5, .dir = Direction.horizontal };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 3, .y = 5, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 4, .y = 5, .dir = Direction.horizontal };
        try expect(wf.isBoardConnected(insert));
    }
    //Through a test, vertical
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 11, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 10, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 9, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 8, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 7, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 6, .dir = Direction.vertical };
        try expect(wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 10, .y = 5, .dir = Direction.vertical };
        try expect(!wf.isBoardConnected(insert));
    }
    //beside a test, vertical
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 11, .y = 11, .dir = Direction.vertical };
        try expect(!wf.isBoardConnected(insert));
    }
    {
        const insert = Wf.Insertion{ .letters = letters.*, .x = 11, .y = 6, .dir = Direction.vertical };
        try expect(!wf.isBoardConnected(insert));
    }
}

test "to_string" {
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\a _ _ _ _ _ _ _ _ _ L _ _ _ _
        \\b _ _ _ I _ _ _ _ _ _ _ _ V _
        \\c _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\d _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\e _ _ _ _ _ l u g t e r _ _ _
        \\f _ _ _ _ _ _ p _ _ _ u _ _ _
        \\g _ _ _ _ _ h e j _ _ g _ _ _
        \\h _ _ _ _ _ _ r a v i e o l i
        \\i _ _ _ _ _ _ _ _ W _ _ _ _ _
        \\k _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\l _ _ _ _ _ _ _ _ _ _ _ _ V _
        \\m _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ W _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\
    ;
    //    0 1 2 3 4 5
    const WfTypes = GenericWordFeudBoard(15, 7);
    var wf = WfTypes{};
    wf.init(boardstring);
    std.debug.print("To string\n", .{});
    std.debug.print("\n{s}", .{wf.to_string()});
    try expect(std.mem.eql(u8, wf.to_string()[0..450], boardstring[0..450]));
}

test "insert" {
    const boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\a _ _ _ _ _ _ _ _ _ L _ _ _ _
        \\b _ _ _ I _ _ _ _ _ _ _ _ V _
        \\c _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\d _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\e _ _ _ _ _ l u g t e r _ _ _
        \\f _ _ _ _ _ _ p _ _ _ u _ _ _
        \\g _ _ _ _ _ h e j _ _ g _ _ _
        \\h _ _ _ _ _ _ r a v i e o l i
        \\i _ _ _ _ _ _ _ _ W _ _ _ _ _
        \\k _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\l _ _ _ _ _ _ _ _ _ _ _ _ V _
        \\m _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ W _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\
    ;
    const expected_boardstring =
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\a _ _ _ _ _ _ _ _ _ L _ _ _ _
        \\b _ _ _ I _ _ _ _ _ _ _ _ V _
        \\c _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\d _ _ _ _ _ _ s _ _ _ _ _ _ _
        \\e _ _ _ _ _ l u g t e r _ _ _
        \\f _ _ _ _ _ _ p _ _ _ u _ _ _
        \\g _ _ _ _ _ h e j _ _ g _ _ _
        \\h _ _ _ _ _ _ r a v i e o l i
        \\i _ _ _ _ _ _ _ _ W _ b _ _ _
        \\k _ _ _ _ _ _ _ _ _ _ r _ _ _
        \\l _ _ _ _ _ _ _ _ _ _ ø _ V _
        \\m _ _ _ _ _ _ _ _ _ _ d _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ W _ _ _
        \\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        \\
    ;

    const WfTypes = GenericWordFeudBoard(15, 7);
    var wf = WfTypes{};
    wf.init(boardstring);
    var letters = "brød" ++ [_]u8{0} ** 2;
    //above h test, horizontal

    //Vertical
    {
        const insert = WfTypes.Insertion{ .letters = letters.*, .x = 12, .y = 9, .dir = Direction.vertical };
        wf.insert(insert);
        try expect(std.mem.eql(u8, wf.to_string()[0..450], expected_boardstring[0..450]));
    }
}
test "extractWord" {}
test "getWords" {}
test "letterToPoints" {}
test "getPoints" {}

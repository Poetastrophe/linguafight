const PermIter = @import("./PermutationIterator.zig");
const std = @import("std");
const math = std.math;
const Order = std.math.Order;
const emptySentinel = math.maxInt(u8);
const print = std.debug.print;

pub fn BinomialPermutations(comptime N: comptime_int) type {
    return struct {
        const Self = @This();
        combinations: [superFactorial(N)][N]u8 = undefined,

        pub fn init(self: *Self) void {
            var result: [factorial(N) * N][N]u8 = undefined;
            print("\nfacn * n:{}\n", .{factorial(N) * N});
            const emptySentinelArr = [_]u8{emptySentinel} ** N;
            var raw_permutations: [factorial(N)][N]u8 = .{undefined} ** factorial(N);
            for (raw_permutations) |_, i| {
                raw_permutations[i] = emptySentinelArr;
            }

            var iter = PermIter.HeapsAlgorithm(N){};
            var i: u64 = 0;
            while (iter.next()) |unpack| : (i += 1) {
                raw_permutations[i] = unpack;
            }
            print("\nraw_premutations\n{any}", .{raw_permutations});

            var number_of_copys: u64 = 0;
            while (number_of_copys < N) : (number_of_copys += 1) {
                print("\nraw_perm*numberofcopy:{},result.len:{}\n", .{ raw_permutations.len * number_of_copys, result.len });

                std.mem.copy([N]u8, result[number_of_copys * factorial(N) .. factorial(N) * N], raw_permutations[0..factorial(N)]);
                for (raw_permutations) |_, k| {
                    print("\nbefore:{any}\n", .{raw_permutations[k]});
                    raw_permutations[k][N - number_of_copys - 1] = emptySentinel;
                    print("\nafter:{any}\n", .{raw_permutations[k]});
                }
            }

            std.sort.sort([N]u8, result[0..result.len], {}, compareArraysOfSize(N).lessThan);
            i = 0;
            while (i < result.len - 1) : (i += 1) {
                if (std.mem.eql(u8, result[i][0..N], result[i + 1][0..N])) {
                    // std.mem.copy(u8,result[i],emptySentinelArr);
                    result[i] = emptySentinelArr;
                }
            }
            var real_res: [superFactorial(N)][N]u8 = undefined;
            var irr: u64 = 0;
            for (result) |elem| {
                if (!std.mem.eql(u8, elem[0..N], emptySentinelArr[0..N])) {
                    real_res[irr] = elem;
                    irr += 1;
                }
            }
            self.combinations = real_res;
        }
    };
}

fn stripLastDigitAndSort(from: [][]u8) void {
    var k = undefined;
    for (from[0]) |_, i| {
        if (from[0][i] == emptySentinel) {
            k = i - 1;
            break;
        }
    }
    std.debug.assert(k != 0);

    for (from) |_, x| {
        from[x][k] = emptySentinel;
    }
    std.sort.sort([]u8, from, {}, compareSlices);
    var i = 0;
    while (i < from.len - 1) : (i += 1) {
        if (compareSlices({}, from[i][0..from[0].len], from[i + 1][0..from[0].len]) == Order.eq) {
            from[i] = [_]u8{emptySentinel} ** from[0].len;
        }
    }
    std.sort.sort([]u8, from, {}, compareSlices);
}
fn compareArraysOfSize(comptime N: u64) type {
    return struct {
        fn compareArrays(_: void, a: [N]u8, b: [N]u8) Order {
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
        fn lessThan(_: void, a: [N]u8, b: [N]u8) bool {
            return compareArrays({}, a, b) == Order.lt;
        }
    };
}
fn compareSlices(_: void, a: []u8, b: []u8) Order {
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

fn superFactorial(n: u64) u64 {
    var sum: u64 = 0;
    var i: u64 = 1;
    while (i < n + 1) : (i += 1) {
        var prod: u64 = 1;
        var k: u64 = n;
        while (k >= i) : (k -= 1) {
            prod *= k;
        }
        sum += prod;
    }
    return sum;
}

fn factorial(n: u64) u64 {
    var prod: u64 = 1;
    var k: u64 = 1;
    while (k < n + 1) : (k += 1) {
        prod *= k;
    }
    return prod;
}
test "createSmallBinomIter" {
    var bp = BinomialPermutations(4){};
    bp.init();
    print("\nhello:{any}\n", .{bp.combinations});
}

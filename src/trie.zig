const std = @import("std");
const ArrayList = std.ArrayList;
const mem = std.mem;
const Allocator = mem.Allocator;
const AutoHashMap = std.AutoHashMap;

const Trie = struct {
    const Self = @This();
    root: NodeElement,
    allocator: Allocator,

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .root = .{ .children = ArrayList(EdgeToNode).init(allocator) },
        };
    }

    const NodeElement = struct {
        children: ArrayList(EdgeToNode),
    };

    const EdgeToNode = struct { pattern: ArrayList(u8), node: Node };

    const Node = union(enum) {
        element: NodeElement,
        end_of_string: void,
        pub fn report(self: *Node, prefix: []const u8, allocator: Allocator) ArrayList(ArrayList(u8)) {
            var node_stack = ArrayList(Node).init(allocator);
            var arr_of_strs = ArrayList(ArrayList(u8)).init(allocator);
            node_stack.push(self);
            var current_node: Node = undefined;
            while (node_stack.items.len != 0) : (current_node = node_stack.pop()) {
                switch (current_node) {
                    Node.element => |node| {
                        for (node.children) |child| {
                            node_stack.push(child.node);
                        }
                    },
                    Node.end_of_string => {
                        const str_acc = ArrayList(u8).init(allocator);
                        str_acc.appendSlice(prefix);
                        for (node_stack) |node| {
                            str_acc.appendSlice(node.pattern);
                        }
                        arr_of_strs.push(str_acc);
                    },
                }
                return arr_of_strs;
            }
        }

        // TODO: In regards to using u128. Look at practical usecases for dataanalysis, u128 might be too
        // small and we might need to store number of children at each node
        // and attempt to make it arbitrary precision integer in order to give a
        // correct insight into the problem
        // Number of words might be huge, so this can be used before deciding to store the total number of bytes in memory
        pub fn report_check(self: *Node, allocator: Allocator) struct { bytes_count: u128, words_count: u128 } {
            var bytes_count: u128 = 0;
            var words_count: u128 = 0;
            var node_stack = ArrayList(Node).init(allocator);
            node_stack.push(self);
            var current_node: Node = undefined;
            while (node_stack.items.len != 0) : (current_node = node_stack.pop()) {
                switch (current_node) {
                    Node.element => |node| {
                        for (node.children) |child| {
                            bytes_count += child.pattern.len;
                            node_stack.push(child.node);
                        }
                    },
                    Node.end_of_string => words_count += 1,
                }
            }
            return .{ .bytes_count = bytes_count, .words_count = words_count };
        }
    };

    // Returns a list of arrays that have pattern as prefix
    // The list is empty if no word is prefixed by pattern
    // Caller owns the returned list of strings
    // u8 = unsigned integer 8 bit width.
    pub fn search(self: *Self, pattern: []const u8, allocator: Allocator) ArrayList(ArrayList(u8)) {
        var i: u64 = 0;
        var currentNode = Node{ .element = self.root };
        while (i < pattern.len) {
            switch (currentNode) {
                Node.end_of_string =>
                //pattern was not exhausted and no node could be followed
                return ArrayList(ArrayList(u8)).init(allocator),
                Node.element => |node| {
                    // TODO: Optimize with binary search, is it even better?
                    for (node.children) |edge_to_node| {
                        // example pattern: "abcde|fg" edge_to_node.pattern: "ef"
                        if (pattern.len - i >= edge_to_node.pattern.len) {
                            //Remaining query pattern bounded by length of the edge pattern
                            const remaining_pattern = pattern[i .. i + edge_to_node.pattern.len];
                            if (mem.eql(remaining_pattern, edge_to_node.pattern)) {
                                currentNode = edge_to_node.node;
                                i += edge_to_node.pattern.len;
                            }
                        } else if (mem.indexOfDiff(pattern[i..pattern.len], edge_to_node.pattern)) |index| { // Remaining pattern is too small
                            if (index != 0) {
                                i += index;
                                if (pattern.len == i) {
                                    return edge_to_node.node.report(pattern, allocator);
                                }
                            }
                        }
                    }
                    //No node could be followed and pattern was not exhausted
                    return ArrayList(ArrayList(u8)).init(allocator);
                },
            }
        }
        return currentNode.report(pattern, allocator);
    }
};

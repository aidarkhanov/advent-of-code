const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const FILE_NAME = "day1.txt";
const WordToDigit = struct { word: []const u8, digit: i32 };

const WORD_TO_DIGIT = [_]WordToDigit{
    WordToDigit{ .word = "zero", .digit = 0 },
    WordToDigit{ .word = "one", .digit = 1 },
    WordToDigit{ .word = "two", .digit = 2 },
    WordToDigit{ .word = "three", .digit = 3 },
    WordToDigit{ .word = "four", .digit = 4 },
    WordToDigit{ .word = "five", .digit = 5 },
    WordToDigit{ .word = "six", .digit = 6 },
    WordToDigit{ .word = "seven", .digit = 7 },
    WordToDigit{ .word = "eight", .digit = 8 },
    WordToDigit{ .word = "nine", .digit = 9 },
};

fn solution_2(allocator: *Allocator, line: []const u8) !i32 {
    var numbers = ArrayList(i32).init(allocator.*);
    defer numbers.deinit();

    var i: usize = 0;
    while (i < line.len) {
        var matched = false;

        for (WORD_TO_DIGIT) |entry| {
            const word_len = entry.word.len;
            if (i + word_len <= line.len and std.mem.eql(u8, line[i .. i + word_len], entry.word)) {
                numbers.append(entry.digit) catch return error.OutOfMemory;
                matched = true;
                i += word_len - 1;
                break;
            }
        }

        if (!matched) {
            const char = line[i];
            if (char >= '0' and char <= '9') {
                numbers.append(char - '0') catch return error.OutOfMemory;
            }
            i += 1;
        }
    }

    if (numbers.items.len < 1) return error.NoDigitsFound;

    return numbers.items[0] * 10 + numbers.items[numbers.items.len - 1];
}

fn solution_1(line: []const u8) !i32 {
    var first_digit: i32 = undefined;
    var last_digit: i32 = undefined;

    for (line) |char| {
        if (char >= '0' and char <= '9') {
            first_digit = char - '0';
            break;
        }
    }

    var idx = line.len;
    while (idx > 0) : (idx -= 1) {
        const char = line[idx - 1];
        if (char >= '0' and char <= '9') {
            last_digit = char - '0';
            break;
        }
    }

    return first_digit * 10 + last_digit;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile(FILE_NAME, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var sum_1: i32 = 0;
    var sum_2: i32 = 0;
    var tokenizer = std.mem.tokenizeAny(u8, buffer, "\n");
    while (tokenizer.next()) |line| {
        sum_1 += try solution_1(line);
        sum_2 += try solution_2(&allocator, line);
    }

    std.debug.print("{}\n", .{sum_1});
    std.debug.print("{}\n", .{sum_2});
}

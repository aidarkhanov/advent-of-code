package main

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:unicode/utf8"

FILE_NAME :: "3.txt"
SKIP_SYMBOL :: '.'

is_digit :: proc(char: rune) -> bool {
	return char >= '0' && char <= '9' 
}

is_special :: proc(char: rune) -> bool {
	return !is_digit(char) && char != SKIP_SYMBOL 
}

split_strings :: proc(lines: string) -> (result: [dynamic][]rune) {
	it := lines
	for line in strings.split_lines_iterator(&it) {
		append(&result, utf8.string_to_runes(line))
	}
	return result
}

Coords :: struct {
	x, y: int,
}

adj_lookup :: proc(lines: [dynamic][]rune, x, y: int) -> bool {
	directions := [?]Coords{ {-1,  0}, { 1, 0}, {0, -1}, {0, 1},
							 {-1, -1}, {-1, 1}, {1, -1}, {1, 1} }

	for direction in directions {
		new_x, new_y := x + direction.x, y + direction.y

		if new_x >= 0 && new_x < len(lines) && new_y >= 0 && new_y < len(lines) {
			if is_special(lines[new_x][new_y]) {
				return true
			}
		}
	}

	return false
}

solution_1 :: proc(lines: string) -> (sum: int) {
	lines := split_strings(lines)

	for line, x in lines {
		digits: strings.Builder
		contains_special: bool

		for char, y in line {
			switch {
			case is_digit(char):
				if !contains_special && adj_lookup(lines, x, y) {
					contains_special = true
				}

				strings.write_rune(&digits, char)
			case:
				if contains_special {
					sum += strconv.atoi(strings.to_string(digits))
				}

				strings.builder_reset(&digits)
				contains_special = false
			}
		}

		if contains_special {
			sum += strconv.atoi(strings.to_string(digits))
		}
	}

	return
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)
		
		sum := solution_1(string(data))

		fmt.println(sum)
	}
}

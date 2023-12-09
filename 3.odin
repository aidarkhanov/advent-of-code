package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

FILE_NAME :: "3.txt"

Coords :: distinct [2]int
Int_Pair :: distinct [2]int

is_digit :: proc(char: rune) -> bool {
	return char >= '0' && char <= '9' 
}

is_special :: proc(char: rune) -> bool {
	return !is_digit(char) && char != '.' 
}

is_star :: proc(char: rune) -> bool {
	return char == '*'
}

split_strings :: proc(lines: string) -> (result: [dynamic][]rune) {
	it := lines
	for line in strings.split_lines_iterator(&it) {
		append(&result, utf8.string_to_runes(line))
	}
	return result
}

adj_lookup :: proc(
	lines: [dynamic][]rune,
	coords: Coords,
	filter: proc(char: rune) -> bool,
) -> (symbol_coords: Coords, matched: bool) #optional_ok {

	directions := [?]Coords{ {-1,  0}, { 1, 0}, {0, -1}, {0, 1},
							 {-1, -1}, {-1, 1}, {1, -1}, {1, 1} }

	for direction in directions {
		new_x, new_y := coords.x + direction.x, coords.y + direction.y

		if new_x >= 0 && new_x < len(lines) && new_y >= 0 && new_y < len(lines) {
			if filter(lines[new_x][new_y]) {
				return Coords{ new_x, new_y }, true
			}
		}
	}

	return
}

solution_2 :: proc(lines: string) -> (sum: int) {
	lines := split_strings(lines)

	pairs := make(map[Coords]Int_Pair)
	defer delete(pairs)

	for line, x in lines {
		digits: strings.Builder
		star_coords: Coords
		matched_star, ok: bool

		for char, y in line {
			coords := Coords{ x, y }

			if is_digit(char) {
				if !matched_star {
					if star_coords, ok = adj_lookup(lines, coords, is_star); ok {
						matched_star = true
					}
				}

				strings.write_rune(&digits, char)
			}

			// by checking if we are the last column,
			// numbers that are not followed by a dot
			// are not skipped.
			//
			// we could as well append a dot to the
			// end of each line but an additional
			// check is cleaner.
			if !is_digit(char) || y == len(line) - 1 {
				defer {
					strings.builder_reset(&digits)
					matched_star = false
				}

				if matched_star {
					number := strconv.atoi(strings.to_string(digits))

					if star_coords in pairs {
						pairs[star_coords] = Int_Pair{ pairs[star_coords].x, number }

						sum += pairs[star_coords].x * pairs[star_coords].y
					} else {
						pairs[star_coords] = Int_Pair{ number, 0 }
					}
				}
			}
		}
	}

	return
}

solution_1 :: proc(lines: string) -> (sum: int) {
	lines := split_strings(lines)

	for line, x in lines {
		digits: strings.Builder
		matched_special: bool

		for char, y in line {
			coords := Coords{ x, y }

			if is_digit(char) {
				if !matched_special {
					if _, ok := adj_lookup(lines, coords, is_special); ok {
						matched_special = true
					}
				}

				strings.write_rune(&digits, char)
			}

			if !is_digit(char) || y == len(line) - 1 {
				defer {
					strings.builder_reset(&digits)
					matched_special = false
				}

				if matched_special {
					sum += strconv.atoi(strings.to_string(digits))
				}
			}
		}
	}

	return
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)
		
		sum := solution_2(string(data))

		fmt.println(sum)
	}
}

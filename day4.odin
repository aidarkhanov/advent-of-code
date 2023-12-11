package day4

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"

FILE_NAME :: "day4.txt"

Deck :: struct {
	id: int,
	elf: [dynamic]int,
	winning: [dynamic]int,
}

// Card x: 1 2 ... n | 1 2 ... n
parse_line :: proc(line: string) -> (deck: Deck) {
	lines_split := strings.split(line, ":")
	
	id_part, numbers_part := lines_split[0], lines_split[1]
	id_split := strings.split(id_part, " ")
	deck.id = strconv.atoi(id_split[len(id_split) - 1])

	numbers_split := strings.split(numbers_part, "|")
	elf_numbers, winning_numbers := strings.trim_space(numbers_split[0]), strings.trim_space(numbers_split[1])

	for number in strings.split(elf_numbers, " ") {
		if number != "" {
			append(&deck.elf, strconv.atoi(number))
		}
	}

	for number in strings.split(winning_numbers, " ") {
		if number != "" {
			append(&deck.winning, strconv.atoi(number))
		}
	}

	return
}

solution_1 :: proc(lines: string) -> (sum: int) {
	it := lines
	for line in strings.split_lines_iterator(&it) {
		deck := parse_line(line)

		score := 0

		for e in deck.elf {
			for w in deck.winning {
				if e == w {
					if score == 0 {
						score += 1
					} else {
						score *= 2
					}
				}
			}
		}

		sum += score
	}

	return
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		fmt.println(solution_1(string(data)))
	}
}

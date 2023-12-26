package day4

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:testing"

FILE_NAME :: "day4.txt"

Card :: struct {
	elf, winning: [dynamic]int,
}

Cards :: distinct map[int]Card

// Card x: 1 2 ... n | 1 2 ... n
parse_line :: proc(line: string) -> (id: int, card: Card) {
	lines_split := strings.split(line, ":")

	id_part, numbers_part := lines_split[0], lines_split[1]
	id_split := strings.split(id_part, " ")
	id = strconv.atoi(id_split[len(id_split) - 1])

	numbers_split := strings.split(numbers_part, "|")
	elf_numbers, winning_numbers := strings.trim_space(numbers_split[0]), strings.trim_space(numbers_split[1])

	for number in strings.split(elf_numbers, " ") {
		if number != "" {
			append(&card.elf, strconv.atoi(number))
		}
	}

	for number in strings.split(winning_numbers, " ") {
		if number != "" {
			append(&card.winning, strconv.atoi(number))
		}
	}

	return
}

process_input :: proc(lines: string) -> (cards: Cards) {
	it := lines
	for line in strings.split_lines_iterator(&it) {
		id, card := parse_line(line)
		cards[id] = card
	}
	return
}

solution_2 :: proc(cards: ^Cards) -> (sum: int) {
	matches := make([]int, len(cards))
	defer delete(matches)

	copies := make([]int, len(cards))
	defer delete(copies)

	for id, card in cards {
		for e in card.elf {
			for w in card.winning {
				if e == w {
					matches[id - 1] += 1
				}
			}
		}

		copies[id - 1] = 1
	}

	for i := 0; i < len(matches); i += 1 {
		for j := i + 1; j < len(matches) && j <= i + matches[i]; j += 1 {
			copies[j] += copies[i]
		}
	}

	for count in copies {
		sum += count
	}

	return
}

solution_1 :: proc(cards: ^Cards) -> (sum: int) {
	for id, card in cards {
		score := 0

		for e in card.elf {
			for w in card.winning {
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

		cards := process_input(string(data))
		defer delete(cards)

		fmt.println(solution_2(&cards))
	}
}

@test
test_solution_1 :: proc(t: ^testing.T) {
	data := `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11`
	result := 13

	cards := process_input(data)
	defer delete(cards)

	testing.expect(t, solution_1(&cards) == result)
}

@test
test_solution_2 :: proc(t: ^testing.T) {
	data := `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11`
	result := 30

	cards := process_input(data)
	defer delete(cards)

	testing.expect(t, solution_2(&cards) == result)
}

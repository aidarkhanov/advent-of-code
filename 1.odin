package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

FILE_NAME :: "1.txt"
WORD_TO_DIGIT := map[string]int{
	"zero"  = 0, "one"   = 1, "two"   = 2,
	"three" = 3, "four"  = 4, "five"  = 5,
	"six"   = 6, "seven" = 7, "eight" = 8,
	"nine"  = 9,
}

solution_2 :: proc(line: string) -> int {
	numbers: [dynamic]int
	defer delete(numbers)

	for i := 0; i < len(line); {
		matched := false

		for word, number in WORD_TO_DIGIT {
			word_len := len(word)
			if i + word_len <= len(line) && line[i:i + word_len] == word {
				append(&numbers, number)
				i += word_len - 1
				matched = true
				break
			}
		}

		char := line[i]
		if !matched {
			i += 1

			if char >= '0' && char <= '9' {
				append(&numbers, int(char - '0'))
			}
		}
	}

	assert(len(numbers) >= 1, "No digits found in the string")

	first_digit := numbers[0]
	last_digit := numbers[len(numbers) - 1]

	return strconv.atoi(fmt.aprintf("%d%d", first_digit, last_digit))
}

solution_1 :: proc(line: string) -> int {
	first_digit: int
	last_digit: int

	for char in line {
		if char >= '0' && char <= '9' {
			first_digit = int(char - '0')
			break
		}
	}

	#reverse for char in line {
		if char >= '0' && char <= '9' {
			last_digit = int(char - '0')
			break
		}
	}
	
	return strconv.atoi(fmt.aprintf("%d%d", first_digit, last_digit))
}

main :: proc() {
	data, _ := os.read_entire_file(FILE_NAME, context.allocator)
	defer delete(data, context.allocator)

	sum := 0
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		sum += solution_2(line)
	}

	fmt.println(sum)
}

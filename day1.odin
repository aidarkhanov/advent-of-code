package day1

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

FILE_NAME :: "day1.txt"
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
				matched = true
				i += word_len - 1
				break
			}
		}

		if !matched {
			char := line[i]

			if char >= '0' && char <= '9' {
				append(&numbers, int(char - '0'))
			}

			i += 1
		}
	}

	assert(len(numbers) >= 1, "No digits found in the string")

	first_digit, last_digit := numbers[0], numbers[len(numbers) - 1]

	return strconv.atoi(fmt.aprintf("%d%d", first_digit, last_digit))
}

solution_1 :: proc(line: string) -> int {
	first_digit, last_digit: int

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
	defer delete(WORD_TO_DIGIT)

	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		sum := 0
		it := string(data)
		for line in strings.split_lines_iterator(&it) {
			sum += solution_2(line)
		}

		fmt.println(sum)
	}
}

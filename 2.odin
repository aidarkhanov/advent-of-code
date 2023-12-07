package main

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"

FILE_NAME :: "2.txt"
RED :: 12
GREEN :: 13
BLUE :: 14

Cube_Set :: struct {
	red, green, blue: int,
}

// Game [id]: [x] red, [y] green, [z] blue; ...[n]

solution_2 :: proc(line: string) -> (int, bool) {
	line_sep := strings.split(line, ":")

	id_part, sets_part := line_sep[0], line_sep[1]
	
	id := strconv.atoi(strings.split(id_part, " ")[1])

	sets_sep := strings.split(sets_part, ";")
	
	cube_set := Cube_Set{}
	for set_part in sets_sep {
		set := strings.split(set_part, ",")
		
		for cube_part in set {
			cube_sep := strings.split(strings.trim_space(cube_part), " ")
			number, color := strconv.atoi(cube_sep[0]), cube_sep[1]
	
			switch color {
			case "red":
				if cube_set.red < number {
					cube_set.red = number
				}
				break
			case "green":
				if cube_set.green < number {
					cube_set.green = number
				}
				break
			case "blue":
				if cube_set.blue < number {
					cube_set.blue = number
				}
				break
			}
		}
	}

	power := cube_set.red * cube_set.green * cube_set.blue
	return power, true
}

solution_1 :: proc(line: string) -> (int, bool) {
	line_sep := strings.split(line, ":")

	id_part, sets_part := line_sep[0], line_sep[1]
	
	id := strconv.atoi(strings.split(id_part, " ")[1])

	sets_sep := strings.split(sets_part, ";")
	
	for set_part in sets_sep {
		set := strings.split(set_part, ",")
		
		cube_set := Cube_Set{}
		for cube_part in set {
			cube_sep := strings.split(strings.trim_space(cube_part), " ")
			number, color := strconv.atoi(cube_sep[0]), cube_sep[1]
	
			switch color {
			case "red":
				cube_set.red = number
				break
			case "green":
				cube_set.green = number
				break
			case "blue":
				cube_set.blue = number
				break
			}
		}
		
		if cube_set.red > RED || cube_set.green > GREEN || cube_set.blue > BLUE {
			return 0, false
		}
	}

	return id, true
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)
		
		results: [dynamic]int
		defer delete(results)

		it := string(data)
		for line in strings.split_lines_iterator(&it) {
			if result, ok := solution_2(line); ok {
				append(&results, result)
			}
		}

		sum := 0
		for id in results {
			sum += id
		}

		fmt.println(results)
		fmt.println(sum)
	}
}

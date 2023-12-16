package day5

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:testing"

FILE_NAME :: "day5.txt"

Instruction :: struct {
	dst, src, range: int,
}

Instructions :: distinct [dynamic]Instruction

Mapping :: distinct map[string]Instructions

Seeds :: distinct [dynamic]int

parse_lines :: proc(lines: string) -> (seeds: Seeds, mapping: Mapping) {
	it := string(lines)
	in_map := false
	key_map := ""

	for line in strings.split_lines_iterator(&it) {
		if seeds_str := strings.split(line, "seeds:"); len(seeds_str) > 1 {
			seeds_str := seeds_str[1]
			for seed_str in strings.split(strings.trim_space(seeds_str), " ") {
				append(&seeds, strconv.atoi(seed_str))
			}
		}

		if map_str := strings.split(line, "map:"); len(map_str) > 1 || in_map {
			in_map = true

			if len(map_str) == 1 {
				if map_str := strings.split(map_str[0], " "); len(map_str) == 3 {
					dst, src, range := strconv.atoi(map_str[0]), strconv.atoi(map_str[1]), strconv.atoi(map_str[2])
					instructions := mapping[key_map]

					append(&instructions, Instruction { dst, src, range })
					mapping[key_map] = instructions
				} else {
					in_map = false
					key_map = ""
				}

				continue
			}

			if len(map_str) == 2 {
				key_map = strings.trim_space(map_str[0])
				continue
			}

			fmt.eprintln("Error: Unreachable code.")
			os.exit(1)
		}
	}

	return
}

map_number :: proc(num: int, instructions: Instructions) -> int {
	for instruction in instructions {
		dest_start, src_start, length := instruction.dst, instruction.src, instruction.range
		if num >= src_start && num < src_start + length {
			return dest_start + (num - src_start)
		}
	}
	return num
}

find_lowest_location :: proc(seeds: Seeds, mapping: Mapping) -> int {
	if len(seeds) == 0 {
		fmt.eprintln("Error: No seeds provided.")
		return -1
	}

	process_seed_through_mappings :: proc(seed: int, mapping: Mapping) -> int {
		soil := map_number(seed, mapping["seed-to-soil"])
		fertilizer := map_number(soil, mapping["soil-to-fertilizer"])
		water := map_number(fertilizer, mapping["fertilizer-to-water"])
		light := map_number(water, mapping["water-to-light"])
		temperature := map_number(light, mapping["light-to-temperature"])
		humidity := map_number(temperature, mapping["temperature-to-humidity"])
		location := map_number(humidity, mapping["humidity-to-location"])
		return location
	}

	min_location := process_seed_through_mappings(seeds[0], mapping)

	for i := 1; i < len(seeds); i += 1 {
		location := process_seed_through_mappings(seeds[i], mapping)
		if location < min_location {
			min_location = location
		}
	}

	return min_location
}

solution_1 :: proc(lines: string) -> int {
	seeds, mapping := parse_lines(lines)
	
	return find_lowest_location(seeds, mapping)
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		fmt.println(solution_1(string(data)))
	}
}

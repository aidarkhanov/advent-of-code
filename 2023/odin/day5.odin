package day5

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:testing"

FILE_NAME :: "day5.txt"

Instruction :: struct {
	dst, src, range: int,
}

Instructions :: #soa[dynamic]Instruction

Mapping :: distinct map[string]Instructions

Seeds :: distinct [dynamic]int

Range :: struct {
	start, length: int,
}

Ranges :: #soa[dynamic]Range

parse_lines_ranges :: proc(lines: string) -> (ranges: Ranges, mapping: Mapping) {
	in_map: bool
	key_map: string

	it := lines
	for line in strings.split_lines_iterator(&it) {
		if seeds_str := strings.split(line, "seeds:"); len(seeds_str) > 1 {
			seeds_str := seeds_str[1]
			seeds: Seeds
			for seed_str in strings.split(strings.trim_space(seeds_str), " ") {
				append(&seeds, strconv.atoi(seed_str))
			}

			for i := 0; i < len(seeds); i += 2 {
				start, length := seeds[i], seeds[i + 1]
				append_soa(&ranges, Range { start, length })
			}
		}

		if map_str := strings.split(line, "map:"); len(map_str) > 1 || in_map {
			in_map = true

			if len(map_str) == 1 {
				if map_str := strings.split(map_str[0], " "); len(map_str) == 3 {
					dst, src, range := strconv.atoi(map_str[0]), strconv.atoi(map_str[1]), strconv.atoi(map_str[2])
					instructions := mapping[key_map]

					append_soa(&instructions, Instruction { dst, src, range })
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

			unreachable()
		}
	}

	return
}

parse_lines :: proc(lines: string) -> (seeds: Seeds, mapping: Mapping) {
	in_map: bool
	key_map: string

	it := lines
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

					append_soa(&instructions, Instruction { dst, src, range })
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

			unreachable()
		}
	}

	return
}

map_number :: proc(seed: int, instructions: Instructions) -> int {
	for instruction in instructions {
		dst_start, src_start, length := instruction.dst, instruction.src, instruction.range
		if seed >= src_start && seed < src_start + length {
			return dst_start + (seed - src_start)
		}
	}

	return seed
}

find_lowest_location_ranges :: proc(ranges: Ranges, mapping: Mapping) -> int {
	min_location := max(int) 
	for range in ranges {
		for seed in range.start..<(range.start + range.length) {
			soil := map_number(seed, mapping["seed-to-soil"])
			fertilizer := map_number(soil, mapping["soil-to-fertilizer"])
			water := map_number(fertilizer, mapping["fertilizer-to-water"])
			light := map_number(water, mapping["water-to-light"])
			temperature := map_number(light, mapping["light-to-temperature"])
			humidity := map_number(temperature, mapping["temperature-to-humidity"])
			location := map_number(humidity, mapping["humidity-to-location"])

			if location < min_location {
				min_location = location
			}
		}
	}

	return min_location
}

find_lowest_location :: proc(seeds: Seeds, mapping: Mapping) -> int {
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
	defer {
		delete(seeds)
		delete(mapping)
	}

	return find_lowest_location(seeds, mapping)
}

solution_2 :: proc(lines: string) -> int {
	ranges, mapping := parse_lines_ranges(lines)
	defer {
		delete_soa(ranges)
		delete(mapping)
	}

	return find_lowest_location_ranges(ranges, mapping)
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		fmt.println(solution_1(string(data)))
		fmt.println(solution_2(string(data)))
	}
}

@test
test_solution_1 :: proc(t: ^testing.T) {
	data := `seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`
	result := 35

	testing.expect(t, solution_1(data) == result)
}

@test
test_solution_2 :: proc(t: ^testing.T) {
	data := `seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`
	result := 46

	testing.expect(t, solution_2(data) == result)
}

package day6

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

FILE_NAME :: "day6.txt"

Race :: struct {
	time, distance: int,
}

Races :: #soa[dynamic]Race

parse_data :: proc(lines: string) -> (races: Races) {
	filter_empty :: proc(x: []string) -> (res: [dynamic]string) {
		for n in x {
			if n != "" {
				append(&res, n)
			}
		}
		return
	}

	lines := strings.split(lines, "\n")

	times_str, distances_str :=
		filter_empty(
			strings.split(
				strings.split(lines[0], "Time:")[1], " ")),
		filter_empty(
			strings.split(
				strings.split(lines[1], "Distance:")[1], " "))

	for i in 0..<len(times_str) {
		time, distance :=
			strconv.atoi(times_str[i]),
			strconv.atoi(distances_str[i])
		
		append_soa(&races, Race { time, distance })
	}

	return
}

calculate_ways :: proc(race: Race) -> (ways: int) {
	for time in 0..<race.time {
		speed := time
		travel_time := race.time - time
		distance := speed * travel_time
		if distance > race.distance {
			ways += 1
		}
	}
	return
}

solution_1 :: proc(lines: string) -> (total_ways: int = 1) {
	races := parse_data(lines)

	ways: [dynamic]int
	for race in races {
		append(&ways, calculate_ways(race))
	}

	for way in ways {
		total_ways *= way
	}

	return
}

solution_2 :: proc() -> int {
	race := Race { 60808676, 601116315591300 }
	return calculate_ways(race)
}

main :: proc() {
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		fmt.println(solution_1(string(data)))
		fmt.println(solution_2())
	}
}

package day7

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:slice"

FILE_NAME :: "day7.txt"

// Determine type of a hand
// Assign each hand their type
// Sort hands based on their significance + type
// What is significance?
// It is the finding out the types of each card in hand.

Type :: enum { undefined, High_Card, One_Pair, Two_Pair, Three_Of_A_Kind, Full_House, Four_Of_A_Kind, Five_Of_A_Kind }

Card :: struct {
	rank: int,
	label: rune,
}
Cards :: [5]Card

Hand :: struct {
	bid: int,
	type: Type,  /* size_of(enum) == 8 bytes */
	cards: Cards,
}

cards_map: [86]u8 = {
	'A' = 13,
	'K' = 12,
	'Q' = 11,
	'J' = 10,
	'T' = 9,
	'9' = 8,
	'8' = 7,
	'7' = 6,
	'6' = 5,
	'5' = 4,
	'4' = 3,
	'3' = 2,
	'2' = 1,
}

determine_type :: proc(cards: Cards) -> (type: Type) {
	cards_map: map[Card]int
	defer delete(cards_map)

	for card in cards {
		if card in cards_map {
			cards_map[card] += 1
		} else {
			cards_map[card] = 1
		}
	}

	ones, twos, threes: int
	for card, count in cards_map {
		if count == 1 {
			ones += 1
		} else if count == 2 {
			twos += 1
		} else if count == 3 {
			threes += 1
		} else if count == 4 {
			return .Four_Of_A_Kind
		} else if count == 5 {
			return .Five_Of_A_Kind
		}
	}

	if ones == 5 {
		return .High_Card
	} else if threes == 1 && twos == 1 {
		return .Full_House
	} else if threes == 1 {
		return .Three_Of_A_Kind
	} else if twos == 2 {
		return .Two_Pair
	} else if twos == 1 {
		return .One_Pair
	}

	return
}

solution_1 :: proc(lines: string) {
	hands: [dynamic]Hand
	defer delete(hands)

	it := lines
	for line in strings.split_lines_iterator(&it) {
		line := strings.split(line, " ")
		cards_str, bid_str := line[0], line[1] 
		bid := strconv.atoi(bid_str)
		cards: Cards
		for card, i in strings.split(cards_str, "") {
			cards[i] = cards_map[card]
		}
		type := determine_type(cards)
		slice.sort_by(cards[:], proc(a, b: Card) -> bool {
			return int(a) > int(b)
		})
		append(&hands, Hand { bid, cards, type })
	}

	slice.sort_by(hands[:], proc(a, b: Hand) -> bool {
		if int(a.type) != int(b.type) {
			return int(a.type) > int(b.type)
		}
		for i in 0..<len(a.cards) {
			if a.cards[i] != b.cards[i] {
				return a.cards[i] > b.cards[i]
			}
		}
		return false
	})
	fmt.println(hands)

	total := 0
	#reverse for hand, i in hands {
		fmt.printf("%d * %d\n", len(hands) - i, hand.bid)
		total += (len(hands) - i) * hand.bid
	}

	fmt.println(total)
}

main :: proc() {
	
	if data, ok := os.read_entire_file(FILE_NAME); ok {
		defer delete(data)

		solution_1(string(data))
	}
}

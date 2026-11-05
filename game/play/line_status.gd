class_name LineStatus
extends RefCounted
## One clue line's derived status ([SCH-line-status]).
##
## Holds which line it describes ([SCH-line-status] F1/F2) and what the current fills
## say about it ([SCH-line-status] F3 error, F4 satisfied, F5 number_matched).
## [b]CMP-rules[/b] creates one per check and the caller discards it
## ([SCH-line-status] L1-L3): the value is never stored on the attempt
## ([SCH-line-status] I2, [SCH-attempt] I1).

## Row or column of the line this status describes (F1).
var orientation: ClueLine.Orientation

## 0 … size-1 (F2).
var index: int

## The fills contradict this line's clues
## (F3, [code]GS.row-error[/code] / [code]GS.col-error[/code]).
var error: bool = false

## Every clue number matched and no fill island left over — the fills are exactly this
## line's runs (F4, [code]GS.clue-satisfied[/code]).
var satisfied: bool = false

## Per clue number, in clue order: the fill island at that position exists and its
## length equals the number (F5, [code]GS.clue-num-matched[/code], [code]E-clue[/code]
## P4). Empty for an all-empty line, which has no number to match.
var number_matched: Array[bool] = []


func _init(
	line_orientation: ClueLine.Orientation,
	line_index: int,
	in_error: bool,
	is_satisfied: bool,
	matched_numbers: Array[bool] = [],
) -> void:
	assert(line_index >= 0, "Line status index must not be negative: %s" % line_index)
	orientation = line_orientation
	index = line_index
	error = in_error
	satisfied = is_satisfied
	number_matched = matched_numbers


## True when clue number [param number] matches its fill island (F5).
func number_matches(number: int) -> bool:
	return number >= 0 and number < number_matched.size() and number_matched[number]


func equals(other: LineStatus) -> bool:
	return (
		other != null
		and other.orientation == orientation
		and other.index == index
		and other.error == error
		and other.satisfied == satisfied
		and other.number_matched == number_matched
	)


func _to_string() -> String:
	var name := "row" if orientation == ClueLine.Orientation.ROW else "column"
	return (
		"%s %d error=%s satisfied=%s numbers=%s" % [name, index, error, satisfied, number_matched]
	)

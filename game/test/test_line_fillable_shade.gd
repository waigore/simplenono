extends GutTest
## Line-level fillable shade derivation — specs/design/features/line-fillable-shade.md
## R1 and specs/ux/stories/screens/puzzle.md US1.10, US1.11.
##
## [LineFillableShade] is pure: it reads one line's run lengths and the tap, and
## returns the shared cells of the max legal run. These cases pin the reading of R1
## (max length first, then the cells every max-length placement shares) and X1 (no
## arrangement covers the tap), on small lines whose arrangements can be counted by
## hand.

## The approved 10x10 sample's row 4: clue 6 on a 10-wide line.
const SAMPLE_SIZE := 10


func test_a_forced_run_shades_in_full() -> void:
	# A run of 10 on a 10-wide line has one start, so it is forced.
	assert_eq(LineFillableShade.region(10, [10], 0), _cells(0, 9), "a forced run shades in full")
	assert_eq(
		LineFillableShade.region(10, [10], 9),
		_cells(0, 9),
		"the tapped cell is inside the shaded run"
	)


func test_an_empty_line_shades_nothing() -> void:
	assert_eq(LineFillableShade.region(10, [], 4), [] as Array[int], "no run, no shade (X1)")


func test_a_tap_no_arrangement_fills_shades_nothing() -> void:
	# Clue [2, 2] on a width of 5 has one arrangement, runs 0..1 and 3..4, so cell 2
	# is a gap in every arrangement and its tap shades nothing (X1).
	assert_eq(LineFillableShade.region(5, [2, 2], 2), [] as Array[int], "the forced gap")
	assert_eq(LineFillableShade.region(5, [2, 2], 1), _cells(0, 1), "a run cell shades")


func test_outside_the_line_shades_nothing() -> void:
	assert_eq(LineFillableShade.region(10, [4], -1), [] as Array[int], "negative tap")
	assert_eq(LineFillableShade.region(10, [4], 10), [] as Array[int], "past the end")


func test_the_run_containing_the_tap_wins() -> void:
	# Clue [1, 3] on a width of 5 forces runs 0 and 2..4, so each run shades its own
	# cells and the other run is not part of the region.
	assert_eq(LineFillableShade.region(5, [1, 3], 0), _cells(0, 0), "the single cell")
	assert_eq(LineFillableShade.region(5, [1, 3], 4), _cells(2, 4), "the three-run")


func test_shared_cells_of_the_max_length_placements() -> void:
	# Clue 3 on a width of 5 has three placements (0..2, 1..3, 2..4). A tap at cell 2
	# is covered by all three, so the shade spans every cell they share.
	assert_eq(LineFillableShade.region(5, [3], 2), _cells(0, 4), "cell 2 is shared")
	# A tap at cell 0 is covered by placements starting 0 and 1, which share 0..2.
	assert_eq(LineFillableShade.region(5, [3], 0), _cells(0, 2), "two placements cover 0")


func test_sample_row_four_tap_on_the_clue_run() -> void:
	# The approved MC.puzzle sample's row 4 is clue 6 on a 10-wide line. A tap on
	# r4c3 (0-based column 2) is covered by placements starting 0..2; they all fill
	# cells 0..7.
	assert_eq(LineFillableShade.region(SAMPLE_SIZE, [6], 2), _cells(0, 7), "r4c3")


func test_sample_row_four_tap_at_the_line_end_trims_the_shared_cells() -> void:
	# The same clue 6 with a tap on cell 1 is covered by placements starting 0 and 1
	# only, which share cells 0..6: a tap further into the line trims the shade.
	assert_eq(LineFillableShade.region(SAMPLE_SIZE, [6], 1), _cells(0, 6), "r4c2")


func _cells(from: int, to: int) -> Array[int]:
	var cells: Array[int] = []
	for cell in range(from, to + 1):
		cells.append(cell)
	return cells

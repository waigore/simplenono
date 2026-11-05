# Design requirement notes

Raw notes until a design capture run consumes them. Not specs.

- I want a hint system. Hints are mechanisms that the user can enable to make the act of puzzle solving easier; distinct from clues, which are a core part of the nonogram solving process. — target: `specs/design/`
- 1st type of hint is the single line fill hint. when active, any cell that can be filled or crossed via single line logic is filled/crossed — as overlay only, not board marks. — target: `specs/design/`
- 2nd type of hint is the multi line fill hint. similar to single line, except it only fills/crosses if logically implied across multiple rows/columns; limited propagation, one level only; overlay only. these fill hints are done the moment the hint is enabled in settings. — target: `specs/design/`
- to prevent too much cpu cycles being spent on filling out the hints, the cells should be pre-calculated and stored along with the puzzle metadata. this should be done one off for all puzzles, and should also be part of the contract for new puzzles. — target: `specs/design/` / `specs/technical/`
- 3rd type of hint is a line level fillable hint. if active, any time the user taps a tile with fill active, the max legal run containing the tap is shaded in (in a lighter colour), or not if there is no such region. — target: `specs/design/`
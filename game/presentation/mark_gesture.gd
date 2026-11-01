class_name MarkGesture
extends RefCounted
## [b]CMP-shell[/b] R2 / [b]SEQ-mark[/b] S1: resolve one cell's mark from the
## player's gesture and the selected tool (specs/ux/controls.md Mark tools;
## stories [code]US1.6[/code], [code]US1.6b[/code], [code]US1.7[/code], [code]US1.8[/code]).
##
## Every rule is pure: it reads the selected tool and the cell's current mark and
## returns the mark to send as [b]CTR-attempt[/b] O2. Nothing here writes a grid or
## attempt state, and [code]IN.drag-paint[/code] has no resolution rule of its own
## because a drag applied the selected tool without a toggle.


## [code]IN.activate[/code] on a cell: apply the selected tool, and clear when the
## cell already has that mark. Clear sets clear (no-op when already clear).
static func tap(selected: CellMark.Mark, current: CellMark.Mark) -> CellMark.Mark:
	if selected == CellMark.Mark.CLEAR:
		return CellMark.Mark.CLEAR
	if current == selected:
		return CellMark.Mark.CLEAR
	return selected


## [code]IN.mark-complement[/code] on a cell: Fill → Cross, Cross → Fill, Clear →
## Cross, with the same toggle-if-same rule as a primary tap.
static func complement(selected: CellMark.Mark, current: CellMark.Mark) -> CellMark.Mark:
	var target := CellMark.Mark.CROSS
	if selected == CellMark.Mark.CROSS:
		target = CellMark.Mark.FILL
	if current == target:
		return CellMark.Mark.CLEAR
	return target

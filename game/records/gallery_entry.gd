class_name GalleryEntry
extends RefCounted
## One row of [b]CTR-pack[/b] O1: the gallery facts for one puzzle
## (specs/technical/contracts/pack.md; specs/ux/screens/gallery.md R2).
##
## A read-only value assembled by [method Pack.list_entries] from the definition and
## its progress record. It carries [code]GS.ever-completed[/code],
## [code]GS.attempt-status[/code], [code]GS.personal-best[/code], and
## [code]GS.gallery-thumbnail[/code] — whether the tile may show the stored picture —
## so the gallery never reaches the progress record itself ([b]CMP-pack[/b] R2).

## The puzzle id ([SCH-puzzle-def] F1).
var id: String

## The grid size ([SCH-puzzle-def] F2).
var size: int

## [code]GS.ever-completed[/code]: a successful solve happened and reset has not cleared it.
var ever_completed: bool

## [code]GS.attempt-status[/code]: true while the attempt is in progress.
var in_progress: bool

## [code]GS.personal-best[/code] in seconds, or -1 when absent.
var personal_best: int

## [code]GS.gallery-thumbnail[/code]: true when the tile may show the stored
## generated picture ([SCH-progress] F2, [code]PS1.5[/code]).
var thumbnail_visible: bool


func _init(
	entry_id: String,
	entry_size: int,
	entry_ever_completed: bool,
	entry_in_progress: bool,
	entry_personal_best: int,
	entry_thumbnail_visible: bool
) -> void:
	id = entry_id
	size = entry_size
	ever_completed = entry_ever_completed
	in_progress = entry_in_progress
	personal_best = entry_personal_best
	thumbnail_visible = entry_thumbnail_visible


## True when the tile has a personal best to show ([code]copy.best[/code]).
func has_personal_best() -> bool:
	return personal_best >= 0

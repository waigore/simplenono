class_name PackLoadResult
extends RefCounted
## The [b]CTR-pack[/b] O8 return value: the accepted entry count and the rejected entries.
##
## A rejected entry appears in [member rejected] as the raw pack entry, so a caller
## can log it. Rejected entries never become definitions ([SCH-puzzle-def] L3).

## How many entries became definitions. Equal to the pack size after a good load.
var accepted_count: int = 0
## The rejected entries, in pack order. Empty when every entry was accepted.
var rejected: Array[Dictionary] = []


func _init(count: int = 0, rejects: Array = []) -> void:
	accepted_count = count
	for entry: Variant in rejects:
		rejected.append(entry)

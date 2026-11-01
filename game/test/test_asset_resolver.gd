extends GutTest
## [b]CMP-shell[/b] R6 / [code]ACC.A1[/code]-[code]A3[/code]: the one runtime manifest reader
## and the cue → asset-ID map (specs/technical/asset-access.md R2/R3,
## specs/assets/access.md, specs/technical/components/shell.md).
##
## The shipped manifest and catalog are read through the repo path: the resolver itself
## resolves [code]res://[/code] paths from the manifest only, and the catalog cross-check
## is dev-only test data, never a runtime read. The scans prove the single-source rules —
## the five cue-mapped IDs live only in [code]audio_cues.gd[/code], and no literal asset
## path under [code]res://[/code] is baked into game logic.

const AUDIO_CUES_SCRIPT := "presentation/audio_cues.gd"
const UNKNOWN_ID := "01a19666-0000-7000-8000-000000000000"
const ABSENT_MANIFEST := "../assets/absent-manifest.json"


func _cues() -> Array[StringName]:
	return [
		AudioCues.FILL_TICK,
		AudioCues.CROSS_TICK,
		AudioCues.CLEAR_TICK,
		AudioCues.MUSIC_BED,
		AudioCues.SOLVE_STING,
	]


func _asset_id(cue: StringName) -> String:
	return str(AudioCues.ASSET_IDS.get(cue, ""))


## A repo-relative path resolved from the project directory, for the dev-only catalog
## read and the manifest failure case.
func _repo_path(relative: String) -> String:
	return ProjectSettings.globalize_path("res://").path_join(relative)


func _catalog_entry(asset_id: String) -> Variant:
	var path := _repo_path("../assets/catalog/%s.json" % asset_id)
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


## Every [code].gd[/code] file under [code]game/[/code] except the vendored addons.
func _game_scripts() -> Array[String]:
	var files: Array[String] = []
	_collect_scripts(ProjectSettings.globalize_path("res://"), files)
	return files


func _collect_scripts(directory: String, files: Array[String]) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if dir.current_is_dir():
			if entry != "addons" and entry != ".godot":
				_collect_scripts(directory.path_join(entry), files)
		elif entry.ends_with(".gd"):
			files.append(directory.path_join(entry))
		entry = dir.get_next()
	dir.list_dir_end()


func _relative(path: String) -> String:
	return path.replace(ProjectSettings.globalize_path("res://"), "")


# ACC.A1 / ACC.G1-G2: every cue-mapped audio ID resolves through the shipped manifest
func test_every_cue_id_resolves_with_the_shipped_manifest():
	var resolver := AssetResolver.new()

	for cue in _cues():
		var asset_id := _asset_id(cue)
		assert_false(asset_id.is_empty(), "%s maps to an asset id" % cue)
		var resource := resolver.resolve(asset_id)
		assert_not_null(resource, "%s resolves" % cue)
		if resource == null:
			continue
		assert_false(resource.resource_path.is_empty(), "%s loads a real resource" % cue)


# ACC.A2 / drift guard: each cue's ID is approved and its catalog `serves` names the cue
func test_every_cue_id_is_approved_and_serves_its_cue():
	for cue in _cues():
		var entry: Variant = _catalog_entry(_asset_id(cue))
		assert_not_null(entry, "%s has a catalog entry" % cue)
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var fields := entry as Dictionary
		assert_eq(fields.get("state"), "approved", "%s is approved" % cue)
		var serves: Variant = fields.get("serves", [])
		assert_true((serves as Array).has(String(cue)), "%s lists its cue in serves" % cue)


# ACC.A3: an unknown, draft, or deprecated ID is unresolved and loud, never a fallback
func test_unknown_asset_id_fails_loudly():
	var resolver := AssetResolver.new()

	assert_null(resolver.resolve(UNKNOWN_ID), "an unknown id resolves to nothing")
	assert_push_error("unresolved asset id")


# ACC.A3: a missing manifest fails loudly at the app-start read and for every resolve
func test_missing_manifest_fails_loudly():
	var resolver := AssetResolver.new(_repo_path(ABSENT_MANIFEST))
	assert_push_error("not readable")

	assert_null(resolver.resolve(UNKNOWN_ID), "no manifest means no resolve")
	assert_push_error("not loaded")


# Single source: the five cue asset IDs appear only in audio_cues.gd
func test_asset_ids_appear_only_in_the_cue_map():
	var ids: Array[String] = []
	for cue in _cues():
		ids.append(_asset_id(cue))
	var files: Dictionary = {}
	for path in _game_scripts():
		var text := FileAccess.get_file_as_string(path)
		for asset_id in ids:
			if text.contains(asset_id):
				files[_relative(path)] = true

	assert_eq(files.size(), 1, "one file carries the cue IDs")
	assert_true(files.has(AUDIO_CUES_SCRIPT), "that file is the cue map")


# E1: no game file names an asset path; paths come only from the manifest
func test_no_asset_path_literal_is_baked_into_game_logic():
	var needle := "res:/" + "/assets/"
	var files: Array[String] = []
	for path in _game_scripts():
		if FileAccess.get_file_as_string(path).contains(needle):
			files.append(_relative(path))

	assert_eq(files, [], "only the manifest names asset paths")

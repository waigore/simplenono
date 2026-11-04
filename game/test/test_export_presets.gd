extends GutTest
## [b]#544[/b] — specs/view/projection.md [code]A4[/code]: both Android presets capture
## [code]screen/immersive_mode=false[/code] and [code]screen/edge_to_edge=false[/code], so the OS
## status bar and the navigation / home-indicator band stay visible outside the game viewport
## (specs/view/view.md Platform implications, projection.md A3/A2).
##
## The shipped presets file is read through the repo path, as
## [code]test_asset_resolver.gd[/code] reads the manifest, so this is an in-repo data check and
## never a live device call. A third Android preset, a dropped key, or a non-Android preset
## opting in all fail here.

const PRESETS_PATH := "export_presets.cfg"
const ANDROID := "Android"

## The captured chrome keys and the value A3 records for both Android presets.
const CHROME := {
	"screen/immersive_mode": "false",
	"screen/edge_to_edge": "false",
}

## Every section of the presets file as [code]section name → key → value[/code].
var _presets: Dictionary = {}


func before_all() -> void:
	_presets = _read_presets()


## The presets file parsed the way an INI reader splits it: a section header line
## [code][preset.N][/code] or [code][preset.N.options][/code], then [code]key=value[/code] lines.
func _read_presets() -> Dictionary:
	var path := ProjectSettings.globalize_path("res://").path_join(PRESETS_PATH)
	assert_true(FileAccess.file_exists(path), "game/export_presets.cfg is in the repo")
	var sections := {}
	var keys := {}
	for raw in FileAccess.get_file_as_string(path).split("\n"):
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with(";"):
			continue
		if line.begins_with("[") and line.ends_with("]"):
			keys = sections.get_or_add(line.substr(1, line.length() - 2), {})
			continue
		var pair := line.split("=", true, 1)
		if pair.size() == 2:
			keys[pair[0].strip_edges()] = _unquote(pair[1].strip_edges())
	return sections


## A value without the double quotes the presets file writes around strings.
func _unquote(value: String) -> String:
	if value.length() >= 2 and value.begins_with('"') and value.ends_with('"'):
		return value.substr(1, value.length() - 2)
	return value


## The preset sections whose platform is Android, in file order.
func _android_presets() -> Array[String]:
	var presets: Array[String] = []
	for section_name in _presets:
		if section_name.ends_with(".options"):
			continue
		if _presets[section_name].get("platform", "") == ANDROID:
			presets.append(section_name)
	presets.sort()
	return presets


## The [code][preset.N.options][/code] values of one preset section.
func _options(preset: String) -> Dictionary:
	return _presets.get(preset + ".options", {})


# A4: exactly the debug and release Android presets carry the pairing
func test_the_android_presets_are_the_two_shipped_ones() -> void:
	assert_eq(
		_android_presets(),
		["preset.0", "preset.4"],
		"only [preset.0] and [preset.4] export for Android",
	)


# A4 / A3: the OS keeps drawing the status bar and the navigation band, so both presets
# never ask for immersive or edge-to-edge rendering
func test_both_android_presets_keep_the_system_chrome_visible() -> void:
	for preset in _android_presets():
		var options := _options(preset)
		for key in CHROME:
			assert_eq(
				options.get(key, ""),
				CHROME[key],
				"%s carries %s=%s" % [preset, key, CHROME[key]],
			)


# A4: no iOS or desktop preset opts into immersive or edge-to-edge
func test_no_other_preset_opts_into_immersive_or_edge_to_edge() -> void:
	var android := _android_presets()
	for section_name in _presets:
		if not section_name.ends_with(".options"):
			continue
		if section_name.trim_suffix(".options") in android:
			continue
		for key in CHROME:
			assert_false(
				_presets[section_name].has(key),
				"%s carries no %s" % [section_name, key],
			)

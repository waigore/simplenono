class_name AssetResolver
extends RefCounted
## [b]CMP-shell[/b] R6: the one runtime reader of the committed asset manifest
## (specs/technical/asset-access.md R2, specs/assets/access.md [code]ACC.A1[/code]/[code]A2[/code],
## [ADR-0003](specs/adr/decisions/0003-catalog-asset-roots.md)).
##
## The manifest is a generated asset-ID → [code]res://[/code] path list
## ([code]ACC.A2[/code], [code]asset-access[/code] R1). This resolver reads it once at app
## start — the shell constructs it in [code]_ready()[/code] — and [method resolve] returns
## the loaded first path for a catalog asset ID. Code names an asset only by ID: no file
## path is baked into game logic ([code]asset-access[/code] E1), and no other file under
## [code]game/[/code] reads the manifest or names an asset path.
##
## [code]res://[/code] is [code]game/[/code]
## ([ADR-0003](specs/adr/decisions/0003-catalog-asset-roots.md)), so the committed
## manifest two directories up is this resolver's only named path. Packaging it into an
## exported build is later export work; outside the repo tree the resolver fails loudly
## instead of falling back.
##
## An unresolved ID — unknown, draft, or deprecated ([code]ACC.A3[/code]) — and a
## missing or unreadable manifest both fail loudly and return null. Release builds rely
## on the catalog/manifest CI checks that no unresolved ID ships ([code]asset-access[/code] R3);
## this resolver never falls back to a baked file path.

## The committed manifest, resolved from the project directory.
const MANIFEST_PATH := "res://../assets/manifest.json"

var _by_id: Dictionary = {}
var _manifest_path: String
var _loaded := false


## Reads [param manifest_path] once. Tests override the path to prove the loud failure;
## the shell uses the default so the app start read has one source.
func _init(manifest_path: String = MANIFEST_PATH) -> void:
	_manifest_path = manifest_path
	_read_manifest()


## [code]ACC.A1[/code]: the loaded resource for [param asset_id]'s first manifest path, or
## null after a loud failure for an unknown ID or an unavailable manifest
## ([code]ACC.A3[/code], [code]asset-access[/code] R2/R3).
func resolve(asset_id: String) -> Resource:
	if not _loaded:
		_fail("asset manifest is not loaded: %s" % _manifest_path)
		return null
	if not _by_id.has(asset_id):
		_fail("unresolved asset id %s (unknown, draft, or deprecated)" % asset_id)
		return null
	var paths: Variant = _by_id[asset_id]
	if typeof(paths) != TYPE_ARRAY or (paths as Array).is_empty():
		_fail("asset id %s has no manifest path" % asset_id)
		return null
	var path := str((paths as Array)[0])
	if path.is_empty() or not ResourceLoader.exists(path):
		_fail("manifest path for %s is not loadable: %s" % [asset_id, path])
		return null
	var resource := load(path) as Resource
	if resource == null:
		_fail("manifest path for %s did not load a resource: %s" % [asset_id, path])
	return resource


## Reads the manifest once into the ID map. A missing or non-object file leaves the map
## empty, so every later resolve also fails loudly rather than quietly returning null.
func _read_manifest() -> void:
	_by_id = {}
	_loaded = false
	var file := FileAccess.open(_manifest_path, FileAccess.READ)
	if file == null:
		_fail("asset manifest is not readable: %s" % _manifest_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("asset manifest is not a JSON object: %s" % _manifest_path)
		return
	_by_id = parsed as Dictionary
	_loaded = true


func _fail(message: String) -> void:
	push_error("AssetResolver: %s" % message)

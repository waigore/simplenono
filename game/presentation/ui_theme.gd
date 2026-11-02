class_name UiTheme
extends RefCounted
## [code]UIS.T1[/code]/[code]T2[/code]: the one UI type family and its two frame-relative
## sizes, built in code (specs/aesthetics/ui-style.md).
##
## A committed [code].tres[/code] cannot carry a runtime-resolved [FontFile] without an
## [code]ExtResource[/code] asset path ([code]ACC.A1[/code],
## specs/technical/asset-access.md E1,
## [ADR-0003](specs/adr/decisions/0003-catalog-asset-roots.md)) and cannot express a
## frame-relative size, so the shell builds this once at app start from its
## [AssetResolver] and the catalogued font asset ID ([b]CMP-shell[/b] R6), then injects
## it into the four screens.
##
## Absence is expected while no family is catalogued: the builder gates on
## [method AssetResolver.has] before [method AssetResolver.resolve], so an empty or
## unknown ID keeps the engine default face and pushes no error. Figures are tabular
## through the [code]tnum[/code] feature on the theme's default font.

## [code]UIS.T1[/code]: clue numbers are half the adjacent cell side.
const CLUE_CELL_RATIO := 0.5

## [code]UIS.T1[/code]'s readability floor.
const CLUE_MIN_SIZE := 7

## [code]UIS.T2[/code]: chrome labels and the personal-best time are 1/40 of the frame.
const CHROME_FRAME_RATIO := 1.0 / 40.0

## [code]UIS.T2[/code]'s floor, so a degenerate frame still draws.
const CHROME_MIN_SIZE := 1

## The OpenType feature that selects tabular figures ([code]fonts.S3[/code]).
const TABULAR_FEATURE := "tnum"

var _asset_id := ""
var _font: Font
var _variation: FontVariation
var _theme := Theme.new()


## Resolves [param asset_id] through [param resolver] without failing on an expected
## absence. A resolved [Font] becomes the theme's one family; anything else keeps the
## engine default.
func _init(resolver: AssetResolver, asset_id: String) -> void:
	_asset_id = asset_id
	if resolver == null or asset_id.is_empty() or not resolver.has(asset_id):
		return
	var resolved := resolver.resolve(asset_id)
	if not resolved is Font:
		return
	_font = resolved as Font
	_variation = FontVariation.new()
	_variation.base_font = _font
	_variation.opentype_features = {TABULAR_FEATURE: 1}
	_theme.default_font = _variation


## [code]UIS.T1[/code]'s size for a cell whose side is [param cell_side].
static func t1_size(cell_side: float) -> int:
	return maxi(CLUE_MIN_SIZE, int(cell_side * CLUE_CELL_RATIO))


## [code]UIS.T2[/code]'s size for a frame [param frame_height] high.
static func t2_size(frame_height: float) -> int:
	return maxi(CHROME_MIN_SIZE, int(roundf(frame_height * CHROME_FRAME_RATIO)))


## The catalogued asset ID this theme was built for.
func asset_id() -> String:
	return _asset_id


## True when a catalogued family resolved and the theme carries it.
func has_font() -> bool:
	return _font != null


## The resolved family, or null while the build ships no catalogued face.
func font() -> Font:
	return _font


## The theme's [FontVariation]: the resolved family with tabular figures, or null with
## no catalogued face.
func variation() -> FontVariation:
	return _variation


## The theme the screens adopt. It sets only the default font, so a screen keeps its own
## per-role sizes ([method t1_size], [method t2_size]).
func theme() -> Theme:
	return _theme

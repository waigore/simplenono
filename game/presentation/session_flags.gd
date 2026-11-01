class_name SessionFlags
extends RefCounted
## [b]SCH-preferences[/b] F1/F2: the two session-only preferences [b]CMP-shell[/b] R5
## owns (specs/technical/schemata/preferences.md).
##
## Haptics default on and music mute defaults off ([code]F1[/code]/[code]F2[/code]).
## The values live for the app session only: no [code]user://[/code] write
## ([code]L1[/code]-[code]L3[/code], ADR-0002). The shell creates them at app start
## ([code]L1[/code]) and #95's settings screen updates this one source of truth
## ([code]L2[/code]); [signal changed] tells the feedback that already reads them.

## A flag changed. The bed follows F2 without the settings screen knowing which
## component plays it.
signal changed

## [code]SCH-preferences[/code] F1: haptics default on.
const DEFAULT_HAPTICS_ENABLED := true

## [code]SCH-preferences[/code] F2: music mute default off.
const DEFAULT_MUTE_BGM := false

var _haptics_enabled := DEFAULT_HAPTICS_ENABLED
var _mute_bgm := DEFAULT_MUTE_BGM


## [code]SCH-preferences[/code] F1.
func haptics_enabled() -> bool:
	return _haptics_enabled


## [code]SCH-preferences[/code] L2: a settings toggle.
func set_haptics_enabled(enabled: bool) -> void:
	if _haptics_enabled == enabled:
		return
	_haptics_enabled = enabled
	changed.emit()


## [code]SCH-preferences[/code] F2.
func mute_bgm() -> bool:
	return _mute_bgm


## [code]SCH-preferences[/code] L2: a settings toggle.
func set_mute_bgm(muted: bool) -> void:
	if _mute_bgm == muted:
		return
	_mute_bgm = muted
	changed.emit()

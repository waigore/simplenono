#!/usr/bin/env bash
# Export game/ as release builds for Windows, macOS, Linux, and Android.
#
# Issue #499 / ADR-0008: before each export this copies the committed asset
# manifest to res://release/asset_manifest.json, the one in-build path the
# release presets include. The copy is generated, never committed, and ignored
# by git (build/release/). It is written into game/ so a dev run reads it too.
#
# iOS is out of scope: it needs a macOS runner and the owner's Apple identity.
# docs/build-export.md documents those steps.
#
# Optional environment:
#   RELEASE_PRESETS        space-separated subset of Windows macOS Linux "Android Release"
#   GODOT                  Godot binary (default: godot on PATH)
#   ANDROID_VERSION_CODE   integer versionCode for Android Release (default 1)
#   ANDROID_VERSION_NAME   versionName for Android Release (default: unset)
#
# Android Release requires:
#   JAVA_HOME
#   ANDROID_SDK_ROOT
#   GODOT_ANDROID_KEYSTORE_RELEASE_PATH
#   GODOT_ANDROID_KEYSTORE_RELEASE_USER
#   GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
#
# Usage: export_release.sh [build/release]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="$ROOT/game"
PRESET="$PROJECT/export_presets.cfg"
MANIFEST="$ROOT/assets/manifest.json"
INBUILD_DIR="$PROJECT/release"
INBUILD="$INBUILD_DIR/asset_manifest.json"
OUT_ROOT="${1:-$ROOT/build/release}"
GODOT="${GODOT:-godot}"
ALL_PRESETS=("Windows" "macOS" "Linux" "Android Release")
TEMPLATE_ROOT="${GODOT_TEMPLATE_ROOT:-}"

fail() {
	echo "error: $*" >&2
	[[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::error::$*"
	exit 1
}

[[ -f "$PRESET" ]] || fail "missing $PRESET"
[[ -f "$MANIFEST" ]] || fail "missing $MANIFEST; run .github/scripts/asset_manifest.py --write"
command -v "$GODOT" >/dev/null 2>&1 || fail "godot is not on PATH (or set GODOT)"
"$GODOT" --version >/dev/null 2>&1 || fail "$GODOT --version failed"

# The installed template the empty custom_template paths pick up (ADR-0001).
version="$("$GODOT" --version | sed -n 's/^\([0-9][0-9.]*\)\.stable.*/\1.stable/p' | head -n1)"
[[ -n "$version" ]] || fail "cannot read the Godot version from '$GODOT --version'"
if [[ -z "$TEMPLATE_ROOT" ]]; then
	case "$(uname -s)" in
	Darwin) TEMPLATE_ROOT="$HOME/Library/Application Support/Godot/export_templates" ;;
	*) TEMPLATE_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates" ;;
	esac
fi
TEMPLATE_DIR="$TEMPLATE_ROOT/$version"
[[ -d "$TEMPLATE_DIR" ]] || fail "no export templates at $TEMPLATE_DIR; install the $version templates (docs/build-export.md)"

# The empty custom_template paths make Godot use these installed files (ADR-0001).
template_for() {
	case "$1" in
	Windows) echo "windows_release_x86_64.exe" ;;
	macOS) echo "macos.zip" ;;
	Linux) echo "linux_release.x86_64" ;;
	"Android Release") echo "android_release.apk" ;;
	*) echo "" ;;
	esac
}

presets=("${ALL_PRESETS[@]}")
if [[ -n "${RELEASE_PRESETS:-}" ]]; then
	read -r -a presets <<<"$RELEASE_PRESETS"
fi

# Every preset named must exist in the one preset file, and Android Release needs
# its SDK, JDK, and keystore before anything is built.
for name in "${presets[@]}"; do
	grep -q "^name=\"${name}\"$" "$PRESET" ||
		fail "preset '$name' is not in $PRESET (expected: ${ALL_PRESETS[*]})"
	template="$(template_for "$name")"
	[[ -f "$TEMPLATE_DIR/$template" ]] ||
		fail "preset '$name' needs $TEMPLATE_DIR/$template; install the $version templates"
done
for name in "${presets[@]}"; do
	[[ "$name" == "Android Release" ]] || continue
	[[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME}/bin/java" ]] || fail "JAVA_HOME must contain bin/java"
	[[ -n "${ANDROID_SDK_ROOT:-}" && -x "${ANDROID_SDK_ROOT}/platform-tools/adb" ]] ||
		fail "ANDROID_SDK_ROOT must contain platform-tools/adb"
	[[ -d "${ANDROID_SDK_ROOT}/build-tools" ]] || fail "ANDROID_SDK_ROOT is missing build-tools"
	[[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" && -f "$GODOT_ANDROID_KEYSTORE_RELEASE_PATH" ]] ||
		fail "GODOT_ANDROID_KEYSTORE_RELEASE_PATH is unset or missing"
	[[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-}" ]] || fail "GODOT_ANDROID_KEYSTORE_RELEASE_USER is required"
	[[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:-}" ]] || fail "GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD is required"
done

# ADR-0008: the copy is the committed manifest's bytes, the only build output.
mkdir -p "$INBUILD_DIR"
cp "$MANIFEST" "$INBUILD"

code="${ANDROID_VERSION_CODE:-1}"
name="${ANDROID_VERSION_NAME:-}"
[[ "$code" =~ ^[1-9][0-9]*$ ]] || fail "ANDROID_VERSION_CODE must be a positive integer, got '$code'"
[[ ${#name} -le 12 ]] || name="${name:0:12}"

backup="$(mktemp)"
cp "$PRESET" "$backup"
cleanup() {
	local status=$?
	cp "$backup" "$PRESET"
	rm -f "$backup"
	rm -f "$INBUILD"
	rmdir "$INBUILD_DIR" 2>/dev/null || true
	exit "$status"
}
trap cleanup EXIT

# Android version fields live in the preset; rewrite them only when supplied, and
# restore the file on exit (the cleanup trap above).
if [[ "${presets[*]}" == *"Android Release"* ]]; then
	sed -i.bak "s|^version/code=.*|version/code=${code}|" "$PRESET"
	sed -i.bak "s|^version/name=.*|version/name=\"${name}\"|" "$PRESET"
	rm -f "$PRESET.bak"
	grep -q "^version/code=${code}$" "$PRESET" || fail "preset is missing version/code"
fi

echo "Exporting release builds to $OUT_ROOT (presets: ${presets[*]}; templates $version)"
"$GODOT" --headless --path "$PROJECT" --import

for preset in "${presets[@]}"; do
	dest="$OUT_ROOT/$preset"
	mkdir -p "$dest"
	case "$preset" in
	Windows) out="$dest/simplenono.exe" ;;
	macOS) out="$dest/simplenono.zip" ;;
	Linux) out="$dest/simplenono.x86_64" ;;
	"Android Release") out="$dest/simplenono-release.apk" ;;
	*) fail "no output path for preset '$preset'" ;;
	esac
	echo "--- $preset -> $out"
	"$GODOT" --headless --path "$PROJECT" --export-release "$preset" "$out" ||
		fail "preset '$preset' failed to export; see the log above"
	[[ -e "$out" ]] || fail "preset '$preset' wrote nothing to $out"
	bytes="$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out")"
	[[ "$bytes" -gt 1000 ]] || fail "preset '$preset' wrote only ${bytes} bytes to $out"
	echo "Wrote $out (${bytes} bytes)"
done

echo "Release exports complete in $OUT_ROOT"

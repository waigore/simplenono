# Release exports

How a release build of `game/` is produced for the five definition platforms
([`definition.md`](../specs/definition/definition.md)). The Android **debug** APK is a
different path: [`android-debug.md`](android-debug.md).

## Presets

`game/export_presets.cfg` holds one debug preset, `Android`, and five release presets
exactly named `Windows`, `macOS`, `Linux`, `Android Release`, and `iOS`
([ADR-0008](../specs/adr/decisions/0008-release-asset-manifest.md)). Every preset leaves
`custom_template/debug` and `custom_template/release` empty, so Godot uses whatever
template is installed for its own version ([ADR-0001](../specs/adr/decisions/0001-godot-gdscript.md)):
an engine bump needs no preset edit.

Each release preset includes two build outputs: `release/asset_manifest.json` — the
export script's copy of the committed `assets/manifest.json` — and
`release/build_info.json`, the main menu's build stamp. An export packs only `res://`,
so without the copies no asset ID resolves and the stamp has no values.

## Build stamp

`CTR-build-info` ([`build-info.md`](../specs/technical/contracts/build-info.md)) gives
the main menu its product version and short git SHA. Before exporting, the script:

- reads the product version from `game/project.godot` `config/version`;
- reads the short SHA from the checked-out commit (`git rev-parse --short=7 HEAD`);
- writes both to `game/release/build_info.json`, which the release presets pack;
- writes the same version into the presets' `application/version` (macOS, iOS) and
  Android `version/name` for platform metadata, restoring the preset file on exit.

The export fails when either value is missing or the SHA is not 7–12 lowercase hex, so
a shipped build never shows an empty stamp. A dev run has no `build_info.json` and
falls back to `config/version` plus a fixed 7-hex placeholder.

## Templates

Install the export templates for the Godot version you run, into:

- Linux (and CI): `~/.local/share/godot/export_templates/<version>.stable/`
- macOS: `~/Library/Application Support/Godot/export_templates/<version>.stable/`

The version CI exports with is the pin in `.github/workflows/unit-tests.yml`:
**4.7.2** today, so the folder is `4.7.2.stable`. `GODOT_TEMPLATE_ROOT` overrides the
location.

## Export

```sh
.github/scripts/export_release.sh          # all four; iOS is documented only
RELEASE_PRESETS=Linux .github/scripts/export_release.sh
```

Outputs land in `build/release/<preset>/` (git-ignored):

| Preset | Output |
|--------|--------|
| `Windows` | `build/release/Windows/simplenono.exe` |
| `macOS` | `build/release/macOS/simplenono.zip` |
| `Linux` | `build/release/Linux/simplenono.x86_64` |
| `Android Release` | `build/release/Android Release/simplenono-release.apk` |

The script fails loudly when a preset, a template, the JDK, the Android SDK, or the
release keystore is missing, and it writes nothing outside `build/release/` except the
temporary `game/release/asset_manifest.json` copy, which it removes on exit.

## Android release inputs

| Variable | Meaning |
|----------|---------|
| `JAVA_HOME` | JDK root (`bin/java` present) |
| `ANDROID_SDK_ROOT` | SDK root (`platform-tools/adb`, `build-tools`) |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` | Release keystore file |
| `GODOT_ANDROID_KEYSTORE_RELEASE_USER` | Key alias |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` | Key password |

Where the keystore and its credentials come from is a product-owner decision. The
release package is `com.simplenono.game` and declares no internet permission, so the
install plays offline; the debug APK keeps `com.simplenono.debug`.

## Release asset check

```sh
python3 .github/scripts/check_release_assets.py
```

Static, offline, no export: every manifest-listed path under `game/assets/` has a file
or `.import` sidecar, every shipped ID is in the manifest, every listed catalog entry
is approved, no shipped `.gd` file reads `res://../`, and any in-build copy matches the
manifest. Exit 1 on any finding.

## iOS — blocked on product owner

iOS export needs a macOS runner plus Apple identity, so `export_release.sh` does not
drive it. The `iOS` preset is ready for the values:

| Input | Value |
|-------|-------|
| Apple Team ID (`application/app_store_team_id`) | PO |
| Bundle identifier (`application/bundle_identifier`) | PO |
| Provisioning profile (`codesign/provisioning_profile`) | PO |
| Signing certificate and password | PO |

Once those exist, export with `godot --headless --path game --export-release iOS <out.ipa>`
on a macOS host and hand the build to Xcode for signing and upload.

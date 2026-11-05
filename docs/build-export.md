# Release exports

Release builds of `game/` for the five definition platforms
([`definition.md`](../specs/definition/definition.md)); the Android **debug** APK is
separate ([`android-debug.md`](android-debug.md)).

## Presets

`game/export_presets.cfg` holds one debug preset, `Android`, and five release
presets: `Windows`, `macOS`, `Linux`, `Android Release`, `iOS`
([ADR-0008](../specs/adr/decisions/0008-release-asset-manifest.md)). Every preset leaves
`custom_template/*` empty, so Godot uses the installed template for its version
([ADR-0001](../specs/adr/decisions/0001-godot-gdscript.md)); an engine bump needs no
preset edit.

Each release preset packs `release/asset_manifest.json` (a copy of
`assets/manifest.json`) and `release/build_info.json`, the build stamp. An export packs
only `res://`, so without the copies no asset ID resolves and the stamp is empty.

## Build stamp

`CTR-build-info` ([`build-info.md`](../specs/technical/contracts/build-info.md)) gives
the menu its product version and short git SHA. Before exporting, the script:

- reads the product version from `game/project.godot` `config/version`;
- reads the short SHA from the commit (`git rev-parse --short=7 HEAD`);
- writes both to `game/release/build_info.json`, which the presets pack;
- writes the same version into the presets' `application/version` (macOS, iOS) and
  Android `version/name`, restoring the file after.

The export fails when either value is missing or the SHA is not 7–12 lowercase hex, so a
shipped build never shows an empty stamp. A dev run falls back to `config/version` plus a fixed
7-hex placeholder.

## Templates

Install templates for your Godot version:

- Linux (and CI): `~/.local/share/godot/export_templates/<version>.stable/`
- macOS: `~/Library/Application Support/Godot/export_templates/<version>.stable/`

CI pins the version in `.github/workflows/unit-tests.yml` (**4.7.2** today, so
`4.7.2.stable`). `GODOT_TEMPLATE_ROOT` overrides the location.

## Export

```sh
.github/scripts/export_release.sh          # all four; iOS is documented only
RELEASE_PRESETS=Linux .github/scripts/export_release.sh
```

Outputs land in `build/release/<preset>/`:

| Preset | Output |
|--------|--------|
| `Windows` | `build/release/Windows/simplenono.exe` |
| `macOS` | `build/release/macOS/simplenono.zip` |
| `Linux` | `build/release/Linux/simplenono.x86_64` |
| `Android Release` | `build/release/Android Release/simplenono-release.apk` |

The script fails loudly when a preset, template, JDK, Android SDK, or keystore is
missing. It writes nothing outside `build/release/` except the temporary
`game/release/asset_manifest.json` copy, removed on exit.

## Android release inputs

| Variable | Meaning |
|----------|---------|
| `JAVA_HOME` | JDK root (`bin/java` present) |
| `ANDROID_SDK_ROOT` | SDK root (`platform-tools/adb`, `build-tools`) |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` | Release keystore file |
| `GODOT_ANDROID_KEYSTORE_RELEASE_USER` | Key alias |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` | Key password |

Keystore and credentials are a product-owner decision. The release package is
`com.simplenono.game` with no internet permission, so it plays offline; the debug APK
keeps `com.simplenono.debug`.

## Release asset check

```sh
python3 .github/scripts/check_release_assets.py
```

Static, offline: every manifest path under `game/assets/` has a file or
`.import` sidecar, every shipped ID is in the manifest, every catalog entry is approved,
no shipped `.gd` reads `res://../`, and any in-build copy matches the manifest.

## iOS — blocked on product owner

iOS export needs a macOS runner plus Apple identity, so `export_release.sh` skips it.
The `iOS` preset awaits:

| Input | Value |
|-------|-------|
| Apple Team ID (`application/app_store_team_id`) | PO |
| Bundle identifier (`application/bundle_identifier`) | PO |
| Provisioning profile (`codesign/provisioning_profile`) | PO |
| Signing certificate and password | PO |

Then export with `godot --headless --path game --export-release iOS <out.ipa>` on macOS
and hand the build to Xcode for signing and upload.

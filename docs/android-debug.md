# Android debug APK

Debug APKs are produced only by GitHub Actions, never by a local Godot export unless the user explicitly asks for a local build.

## Trigger

Workflow: [`.github/workflows/android-debug.yml`](../.github/workflows/android-debug.yml).

It runs on `pull_request` (`opened` / `synchronize` / `reopened`) into the long-lived **`android-debug`** branch (same-repo heads only). A push to that branch alone does not build.

The job exports preset `Android` from `game/` via [`.github/scripts/export_android_debug.sh`](../.github/scripts/export_android_debug.sh) (CI-only: requires `ANDROID_EXPORT_CI=1`; rewrites Godot editor settings). Before export the script copies `assets/manifest.json` to `game/release/asset_manifest.json` ([ADR-0008](../specs/adr/decisions/0008-release-asset-manifest.md)); the preset's `include_filter` packs that file so puzzle pictures resolve on device. Package `com.simplenono.debug`, arm64, signed with `game/export/android/debug.keystore`.

## Publish

On success the workflow creates or updates a **prerelease** tagged `android-debug/<head-sha>` with asset `simplenono-<12-char-sha>-debug.apk`.

Install over a previous build: `adb install -r <apk>`.

## Agent procedure

1. Run `ensure-project-setup` if it has not passed this session; continue only on Pass.
2. Prefer current `main` as the APK contents. Open a same-repo PR **into** `android-debug`.
3. If `main` → `android-debug` conflicts, branch from `origin/android-debug` (`chore/android-debug-sync`), merge `origin/main`, resolve conflicts **in favor of `main`**, push, and open (or retarget) the PR from that branch. Never force-push `android-debug`.
4. Fill every PR template section ([`docs/pull-requests.md`](pull-requests.md)); Issue / Authority / Evidence may be `N/A` with a reason when this is only an APK request.
5. Wait for the **Android debug** check to succeed. Report the release URL and the `.apk` download URL. Do not stop at the PR URL alone.
6. Leave auto-merge alone unless the user asks; merging updates `android-debug` for the next sync.

## Out of scope

- Local JDK / Android SDK / Godot template install for this path
- Release (non-debug) signing or Play Store uploads
- Editing the workflow or keystore unless the user asked to change the pipeline

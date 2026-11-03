# Playtest run — issue #499 (graphical acceptance)

- **Issue:** #499 Release export presets and asset manifest packaging for the five supported platforms (`type:task`, `priority:normal`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@eb6627f` (PR [#500](https://github.com/waigore/simplenono/pull/500) squash), Godot 4.7.2.stable, session `issue-499-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (900×1200),
  Metal Forward+ on macOS arm64, fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical>

## Scope

PR #500 is `MERGED` at `6d7286d`; `main` carries it as `eb6627f`, and `git diff eb6627f HEAD -- game/` is empty, so this
tree plays exactly the delivered code ([wiki `logs/checks.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical)).

The deliverable is build tooling plus the resolver's release read: five release presets, `export_release.sh`,
`check_release_assets.py`, and [ADR-0008](../../../../../specs/adr/decisions/0008-release-asset-manifest.md). It
changes no screen, rule, or asset. The playable reach is therefore the asset read the shipped UI performs, plus the
flows that read pictures:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `ACC.G3` (pictures catalogued and drawn) | The one player-visible consequence of the manifest work: a picture the UI asks for must resolve |
| `ACC.A1`–`A3` (one reader, loud failure) | `asset_resolver.gd` changed; its read choice and its loud-failure rule are what the ADR adds |
| `PTU-play-puzzle` P1 (`J-play-puzzle`) | Gallery → open → solve → result → gallery is where pictures are drawn |
| `PTU-leave-resume` S1–S3 (`J-leave-resume`) | Open, mark, Leave, reopen — pictures and tiles must survive it |

Out of scope, with reason:

- `PTU-settings`, `PTU-gallery-reset`, `PTU-mark-input`, `PTD-*` — no settings, reset, or mark rule is in the change.
  A mark was still made (`02`) to exercise the read on the puzzle screen.
- `PTU-leave-resume` S4/S5 (pause, quit, relaunch, restore) — no persistence or relaunch path changed.
- Android and iOS release *packages* — see [Notes](#notes).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `ACC.A1` one reader, a shipped path | **pass** | `manifest_path=res://../assets/manifest.json` (dev read), one of the two allowed paths |
| `ACC.G3` picture-ID resolution | **pass** | 400/400 picture IDs the pack names resolve through the resolver |
| `ACC.A3` unknown ID | **pass** | logs `unresolved asset id …` and returns null |
| `ACC.G3` gallery lists the pack | **pass** | 200 entries, 200 tiles |
| `PTU-play-puzzle` P1 | **pass** | a real tap filled a clear cell; the solve reached the result |
| `PTU-leave-resume` S1–S3 | **pass** | Leave closed the attempt; the tile read In progress; C1 reopened |
| `ACC.G3` stored picture drawn | **pass** | result reveal (`04`) and the completed gallery tile (`05`) draw it |

Capture: **25 `capture: PASS`, 0 `capture: FAIL`**, final line `capture: RESULT pass (5 shots, 0 checks failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| wiki `screenshots/01-gallery-app-start.png` | `ACC.G3` | Gallery at app start on a fresh save: 200 tiles, `Completed 0 / 200` |
| wiki `screenshots/02-puzzle-open-picture.png` | `PTU-leave-resume` S1 | `pack-004` open after one real tap filled a clear cell |
| wiki `screenshots/03-gallery-after-leave.png` | `PTU-leave-resume` S2 | Back on the gallery, `#004` In progress, with its Reset control |
| wiki `screenshots/04-result-picture.png` | `ACC.G3`, `PTU-play-puzzle` P1 | `pack-003` solved: the stored picture resolved through the manifest and drawn |
| wiki `screenshots/05-gallery-after-back.png` | `ACC.G3`, `PTU-play-puzzle` P1 | Gallery after Back: `#003` Done, its tile drawing the catalogued picture |

## Release-build evidence (same tree, same session)

The deliverable's own claims are build claims, so this run also records them. They are not playtest protocols; they are
the evidence the acceptance criteria name.

| Log | What it proves |
|-----|----------------|
| [wiki `logs/release-read.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | With the dev manifest absent (exported conditions), the resolver reads `res://release/asset_manifest.json`; 406/406 manifest entries resolve; an unknown ID stays loud |
| [wiki `logs/export.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | One `export_release.sh` run wrote `Linux/`, `Windows/`, and `macOS/`; the macOS PCK contains `release/asset_manifest.json`; the exported release starts and exits clean; `game/release/` is removed on exit |
| [wiki `logs/checks.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | `check_release_assets.py` 0 errors on this tree, exit 1 with a picture removed, 0 again after restore; its 16 tests pass; spec lint 0 errors; `build/release/` is ignored |
| [wiki `logs/h2-no-seams.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | `paint` without `--debug-seams` exits 2 and writes no run folder |
| [wiki `logs/gut.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | GUT 328/328, override tests unmodified |
| [wiki `logs/state-pack-003.json`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) | `DBG.2` state dump after the run |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_499.gd`](probe/probe_accept_499.gd) |
| Capture console (25 PASS, final RESULT) | [wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-499-2026-11-04-accept-graphical) |
| Screenshots (5, graphical run of this build) | same wiki page |

## Quality evaluator

`deterministic`: **cited, not re-run.** Verification wrote a passing record at this issue's deliverable commit —
[`../../../../quality/evidence/issue-499/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-499/2026-11-04-verify/manifest.md).
It measures `game/` at `6d7286d`, which is identical to `eb6627f` (`git diff 6d7286d eb6627f -- game/` empty), so the
record covers this tree. `time-to-playable` 263.7 ms ≤ 3 s → pass; no row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is `None`, so there is no judge record to read and nothing to write.

## Notes

- **No Android release package was built.** AC6's Android leg needs the PO release keystore
  (`GODOT_ANDROID_KEYSTORE_RELEASE_PATH` / `_USER` / `_PASSWORD`) and the Android SDK, neither of which exists on this
  host. The preset's `permissions/internet=false` and `package/unique_name=com.simplenono.game` are static facts, not a
  played Android build.
- **No iOS package**: the issue puts iOS export out of scope (Apple identity is PO-blocked).
- The Linux binary was exported but cannot execute on macOS arm64; the macOS export is the one that ran.
- The export ran with templates installed into a scratch template root, and the playtest used an isolated `HOME`, so the
  run reproduces and no local dev save was touched.

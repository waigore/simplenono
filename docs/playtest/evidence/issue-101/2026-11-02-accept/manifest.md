# Acceptance run — issue #101 (accept)

- **Issue:** #101 Shell scene stub: CMP-shell is the first screen and holds a hardcoded puzzle ID (`type:task`, parent #91)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `007140d` — merge of PR [#136](https://github.com/waigore/simplenono/pull/136), tree identical to the verified head `ea50de5`. No `TEL.3` session id exists; this deliverable emits no telemetry.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical launch capture plus headless runs at the deliverable commit
- **Under acceptance:** the `CMP-shell` stub from PR #136 (`game/presentation/shell.{tscn,gd}`, `game/project.godot`, `game/main.tscn` removed, `game/test/test_shell_stub.gd`)

## Scope

The deliverable is game code and changes the app's first screen, so the playtest gate is engaged. Coverage selection ([`procedures.md`](../../../../../specs/playtest/procedures.md) steps 2–3) maps #101 to **no design story and no UX journey**, so the intersection is empty: no protocol is required and no protocol screenshot rule applies. The capture below is AC evidence, not a protocol pass. Mapping detail: [`notes.md`](notes.md).

The #101 code has since been replaced on `main` by #112 (`f05441c`) and #169 (`3f402fe`). Acceptance is judged at `007140d`, re-run in a clean worktree.

## Results

| Item | Outcome | Note |
|------|---------|------|
| Playtest protocols | **not applicable** | Mapped design/UX set is empty |
| AC 1 — launch opens `CMP-shell` first | **pass** | `main_scene` is the shell stub; `game/main.tscn` absent; app and editor exits 0 |
| AC 2 — hardcoded puzzle ID held and displayed | **pass** | `STUB_PUZZLE_ID := "pack-000"` (shipped id); label visible; no `CTR-attempt`/`CTR-pack`, grid, clues, marks, or navigation |
| AC 3 — only the shell stub screen exists | **pass** | One non-addon `.tscn`; no gallery/result/settings scene, route helper, or manifest resolve |
| AC 4 — #112/#110 work absent | **pass** | No puzzle target scene, shell → puzzle dispatch, open sequence, or journey wiring |
| Quality axes | **N/A** | No Applies axis can move ([`quality.md`](quality.md)); `rubrics.md` defines no `llm-judge` axis |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Quality-record rationale | [`quality.md`](quality.md) | present |
| Graphical capture probe | [`probe/capture_shell.gd`](probe/capture_shell.gd) | present |
| Headless app / editor launch | [`logs/run.log`](logs/run.log), [`logs/editor.log`](logs/editor.log) | exit 0 |
| GUT suite | [`logs/gut.log`](logs/gut.log) | 96/96, 28 620 asserts, exit 0 |
| AC file/scene checks | [`logs/criteria.log`](logs/criteria.log), [`logs/criteria2.log`](logs/criteria2.log) | present |
| `pack-000` in shipped pack | [`logs/pack.log`](logs/pack.log) | 200 ids, found |
| Graphical launch capture | [`logs/graphical.log`](logs/graphical.log) | label `pack-000` visible |
| Screenshot — stub as first screen | [`screenshots/shell-stub.png`](screenshots/shell-stub.png) | present |

## Outcome

**Accept.**

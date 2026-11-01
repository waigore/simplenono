# Acceptance run — issue #91

- **Issue:** #91 Bootstrap: Godot project & test scaffold (`type:epic`, Wave 1)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build:** `main@9c8f2b4`, clean detached worktree
- **Coverage:** `full` — headless only; no playtest protocol applies (see Scope)

## Scope

Epic acceptance of the bootstrap outcome: a runnable Godot project opening to the
shell, with GUT wired to `Unit tests` / `Coverage`. In-scope leaves are accepted:
#99 (PR #115), #100 (GUT scaffold, PR #124 carrier), #101 (PR #136), #163
(PR #169, #185). The epic's own artifact is the headless smoke run (PR #189).
This run changes no playable behavior, so `specs/playtest/evidence.md` requires no
protocol and no folder for CI/tooling; the shell stub's graphical evidence is
#101's ([record](../../issue-101/)).

## Results

| Criterion | Outcome | Evidence |
|-----------|---------|----------|
| Runnable project opens to the shell scene | pass | `game/project.godot` `run/main_scene="res://presentation/shell.tscn"`; smoke log |
| GUT scaffold wired to `Unit tests` / `Coverage` | pass | `unit-tests.yml` import → GUT → smoke, Coverage `needs: [unit-tests]`; suite log |
| Skeleton and `game/` layout (#99) | pass | `game/{presentation,play,records,test,addons,assets,data}` |
| CI pin with an unpinned project; Coverage notice | pass | `GODOT_VERSION: "4.7.2"`; `config/features=4.7`; conventions tables |
| Shell stub substrate (#101) | pass | `shell.gd`/`shell.tscn`; #101 accepted |
| Headless smoke run pass condition (#189) | pass | `.github/scripts/smoke_run.sh`, `docs/coding-conventions/smoke-run.md` |
| Out-of-scope work not claimed | pass | epic adds no gameplay, persistence, screen, or asset change |

## Checks

- Import then GUT: 14 scripts / 170 tests / 170 passing / 29 362 asserts, exit 0
  ([log](logs/gut-suite.log)).
- Smoke: clean startup, no script or engine errors, exit 0 ([log](logs/smoke.log)).
- `gdformat --check game` 68 unchanged; `gdlint` clean ([log](logs/lint.log)).
- `spec_lint.py` 0 errors, 1 pre-existing glossary warning
  ([log](logs/spec-lint.log)).

## Quality evaluators

No Applies deterministic axis can move for the epic-level artifact (CI script,
conventions docs, layout): no `deterministic` record for #91 exists and none is
owed. Child records cover their own deliverables; #101's latest passes
`crash-free` and `runtime-signals`. `specs/definition/quality/rubrics.md` declares
no domain axes, so no `llm-judge` axis applies.

## Verdict

Accept. Every in-scope bootstrap outcome holds on the merged tree.

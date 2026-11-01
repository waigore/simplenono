# Playtest run — issue #112 (graphical acceptance)

- **Issue:** #112 Journey: open a puzzle directly (shell → puzzle open leg) (`type:task`, parent #93)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@5e5fe85`, Godot 4.7.2.stable, session `issue-112-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (Metal, 900×1200)
- **Level:** UX (`J-play-puzzle` S1 open leg)

## Scope

`J-play-puzzle` S1 (open leg) is #112's ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)).
The deliverable shipped in PR [#155](https://github.com/waigore/simplenono/pull/155) (`f05441c`).
Since then `shell.gd` gained seams (#169), audio (#196), gallery (#199), and settings (#202);
`open_puzzle` still guards unknown ids, runs `CTR-attempt` O1, presents, and swaps. This run judges
that current code.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-play-puzzle` S1 — open by id | **pass** | 200/200 accepted ids open, each with its own attempt |
| `J-play-puzzle` S1 — shell → puzzle screen | **pass** | S6 shows `UI-puzzle`, hides `UI-gallery`, presents the live attempt |
| `J-play-puzzle` S1 — free order | **pass** | reverse pack order, full pack sweep |
| `SEQ-open` S1–S6 through O1 | **pass** | fresh attempt, S2 beat, blocked marks, `0:00`, S6 swap |
| `SEQ-open` B1 / `CTR-attempt` G3 — unknown id | **pass** | gallery and open-puzzle cases: screen, attempt, id, marks, elapsed unchanged |
| `PTU-play-puzzle` S1–S2 | **pass (open leg)** | gallery start, `DBG.3` open, Ready beat |
| `PTU-play-puzzle` S3–S4 / P1–P2 | **not runnable** | solve leaves for `UI-result` (epic #95) |
| `J-play-puzzle` S2/S3 | **not runnable** | solve → result → back is #95; grid interaction is #110/#111 |
| `response-delay` / `transition-latency` | **waiting** | no `deterministic` record for this issue |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-start.png) | `UI-gallery` boots; nothing open; 200 tiles |
| [`01`](screenshots/01-unknown-id-gallery-stays.png) | `SEQ-open` B1: an unknown id leaves the gallery and opens no attempt |
| [`02`](screenshots/02-open-s2-get-set-ready.png) | `pack-000` opened: puzzle shown, gallery hidden, Ready beat, blocked marks, `0:00` |
| [`03`](screenshots/03-open-s1-ready.png) | Ready: marks allowed, tools enabled, elapsed still `0:00` |
| [`04`](screenshots/04-free-order-open.png) | Free order re-opened `pack-000` after the reverse-order and 200-id sweeps |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Probe (removed after the run) | [`probe/probe_capture_112.gd`](probe/probe_capture_112.gd) |
| Capture — 69 checks, 0 failures, 5 shots | [`logs/capture-console.log`](logs/capture-console.log) |
| Suite — 17 scripts, 198/198, 29 510 asserts, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |
| Falsification — `open_puzzle` ignores the id, exit 1 | [`logs/falsify-open-id.log`](logs/falsify-open-id.log) |
| `SIT.3` state dump | [`logs/state-pack-000.json`](logs/state-pack-000.json) |

## Quality evaluator

Deterministic: **waiting**. `response-delay` and `transition-latency` can move here, and
[`docs/quality/evidence/`](../../../../quality/evidence/README.md) holds no `issue-112` record for
the commit. Acceptance may not run `deterministic` mode; #204 owns the gap. `llm-judge`: N/A — no
domain axes are declared.

## Reproduce

Copy the probe to `game/probe_capture_112.gd`, then run it graphically (not `--headless`), with
`RUN` set to this folder:

```
godot --path game -s res://probe_capture_112.gd -- --debug-seams \
    --session-id=issue-112-capture --story-ids=J-play-puzzle \
    --shot-dir="$RUN/screenshots" --dump-dir="$RUN"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

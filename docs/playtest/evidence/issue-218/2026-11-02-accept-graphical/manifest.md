# Playtest run — issue #218 (graphical acceptance)

- **Issue:** #218 Result screen ends on a blank S1 Default when a picture is missing (`type:defect`)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@8cfb263`, Godot 4.7.2.stable, graphical 900×1400 on macOS (Metal 4.0, Apple M5)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — the screenshots are from this same build and this same run, not attached from elsewhere

## Scope

The deliverable changes the win reveal's layer chain and the `S1 Default` state it ends on. Intersecting the
`full` coverage set with the design/UX IDs that surface can affect gives one protocol plus the result screen's
own stories:

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) | Cites `UI-result`, `NAV`, `ACT-player`, `J-play-puzzle` — the only way to reach the reveal is a solve, and the result→gallery leg is the screen's exit |
| `UI-result` US1.1–US1.5 | The judged state itself: the two-stage morph, `S1 Default`, Back availability, and the missing-picture fallback |

No design protocol is in scope. This defect changes no game rule: `END.W1` still fires and `PRG` still records
the solve exactly as `PTD-solve-and-pb` expects, and that protocol's own PB assertions are not moved by the
reveal's paint chain. `leave-resume`, `gallery-reset`, and `mark-input` belong to other issues.

## Build under test

The deliverable is the squash merge `dafd469` (PR #223). `main` has since advanced only by `8cfb263`, which adds
the verification evidence folder — `git diff --stat dafd469 8cfb263` touches documentation only — so the product
tree under test is the verified one, and the deterministic record below covers it.

## Outcome

**Pass.** `PTU-play-puzzle` passed every step and both pass rows; `UI-result` US1.1–US1.5 all held, including the
case this defect was filed for. `S1 Default` now shows the solved fills at full opacity with `Back to gallery`
below, and no frame between `S2` and `S1` was empty across the whole chain.

| Detail | Path |
|--------|------|
| Every reproduced result row | [`results.md`](results.md) |
| What was driven, and non-blocking marks | [`notes.md`](notes.md) |
| The seven screenshots | [`screenshots.md`](screenshots.md) |
| Probe run log, 28 checks | [`logs/probe-graphical.log`](logs/probe-graphical.log) |

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_218.gd`](probe/probe_accept_218.gd) |
| Graphical probe run, 28 checks + 7 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Screenshots | [`screenshots/`](screenshots/) |

## Quality evaluator

| Mode | Path | Result |
|------|------|--------|
| `deterministic` (verify-time, cited not re-run) | [`issue-218/2026-11-02-verify`](../../../../quality/evidence/issue-218/2026-11-02-verify/manifest.md), deliverable commit `dafd469` | `frame-time`, `hitch-bound`, `transition-latency`, `crash-free` all **pass**; no row `fail` or `blocked` |
| `llm-judge` | — | **N/A** — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) defines no `llm-judge` axis; every Applies axis is `deterministic` |

The deterministic record is cited, not edited, and its mode stays `deterministic`.

## Reproduce

Copy the probe to `game/probe_accept_218.gd`, then:

```
godot --headless --path game --import
godot --path game -s res://probe_accept_218.gd -- --shot-dir=<run>/screenshots
```

Remove `game/probe_accept_218.gd` afterwards; it is not product code.

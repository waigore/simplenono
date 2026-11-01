# Playtest run — issue #94 (graphical acceptance)

- **Issue:** #94 Gallery & pack progression (`type:epic`, Wave 2 — Complete play journey)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@6f7264f`, Godot 4.7.2.stable, graphical on macOS (Metal 4.0, Apple M5)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — the screenshots are from this same build and run

## Scope

The epic's deliverables change playable behavior: the gallery screen, the pack serve/clear
path (`CTR-pack` O1/O2/O7), and the gallery-side legs of the reset sequence. The intersection
of the `full` coverage set with those deliverables is two rows:

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) | Cites `J-gallery-reset`, `UI-gallery`, `EX` — the reset journey as observed on the gallery |
| `UI-gallery` (`specs/ux/stories/screens/gallery.md` US1.1–US1.6b) | `UI-gallery` is the story row #94 owns; checked directly in the same run |

No design protocol is in scope: this epic adds no game rules. `J-gallery-reset.US1.1`'s
confirm path needs `EX.confirm` and `SEQ reset` S2/S3, which are epic #96's (still open, in
`pending-clarification`) and absent from this build — see [`failure.md`](failure.md).

## Outcome

`UI-gallery` US1.1, US1.2, US1.3, US1.4 (rendering half), US1.6 and US1.6b **pass**.
`PTU-gallery-reset` `S1` (the C2 trigger), `P1`'s never-wipe half and `B1` pass; its `S2`/`S3`
and `P2` **cannot be driven** because no confirm surface exists in this build. Under
[`procedures.md`](../../../../../specs/playtest/procedures.md) that is **Waiting** — the
protocol is not satisfied, and it is not an interface fail because the surface is another
epic's, not a defect in this one. Acceptance is **not** reached; the issue stays
`status:pending-acceptance`.

| Detail | Path |
|--------|------|
| Every reproduced row | [`results.md`](results.md) |
| What was driven, and non-blocking marks | [`notes.md`](notes.md) |
| Why `PTU-gallery-reset` cannot finish | [`failure.md`](failure.md) |
| The five screenshots | [`screenshots.md`](screenshots.md) |

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_94.gd`](probe/probe_accept_94.gd) |
| Graphical probe, 41 checks + 5 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Screenshots | [`screenshots/`](screenshots/) |
| Seeded test document | `user://probe-accept-94/progress.cfg` (test path only; `HOME` was isolated, so the product `user://progress.cfg` was never read or written) |

## Quality evaluator

| Mode | Path | Result |
|------|------|--------|
| `deterministic` (verify-time, cited not re-run) | [`issue-94/2026-11-02-verify-2`](../../../../quality/evidence/issue-94/2026-11-02-verify-2/manifest.md), deliverable commit `fe8c109` | `frame-time`, `time-to-playable`, `transition-latency`, `response-delay`, `crash-free`, `save-survives`, `failed-write` all **pass**; no row `fail` or `blocked` |
| `llm-judge` | — | **N/A** — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) defines no `llm-judge` axis; every Applies axis is `deterministic` |

`main` advanced past `fe8c109` by `d295a62` (the record folder itself) and `6f7264f` (result
reveal). Neither changes the gallery screen, the shell routes the gallery uses, or `O1`/`O2`/
`O7`; `6f7264f`'s only `records` change is the additive `pack_finished()`, which **adds no
caller** for the read path the record covers. The record therefore still covers #94's
deliverable. It is cited, not edited, and its mode stays `deterministic`.

## Reproduce

Copy the probe to `game/probe_accept_94.gd`, then with an isolated `HOME`:

```
HOME="$(mktemp -d)" godot --path game -s res://probe_accept_94.gd -- --shot-dir="$RUN/screenshots"
```

Remove `game/probe_accept_94.gd` afterwards; it is not product code. The probe seeds its own
progress document under `user://probe-accept-94/`, so isolating `HOME` is a second belt on the
same guarantee (the product `user://progress.cfg` is never the file the shell reads).

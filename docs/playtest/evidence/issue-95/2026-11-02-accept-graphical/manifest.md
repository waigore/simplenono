# Playtest run — issue #95 (graphical acceptance)

- **Issue:** #95 Result, settings & navigation (`type:epic`, Wave 2 — Complete play journey)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@a0e6e3a`, Godot 4.7.2.stable, graphical 900×1400 on macOS (Metal 4.0, Apple M5)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — the screenshots are from this same build and run, not attached from elsewhere

## Scope

The epic's playable outcome is the result reveal, the slam preferences, and the screen flow that
reaches and leaves them. The intersection of the `full` coverage set with those deliverables is two
UX protocols:

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) | Cites `UI-result`, `NAV`, `ACT-player`, `J-play-puzzle` — the reveal and its two legs |
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) | Cites `J-settings`, `UI-settings` — the settings surface and its legs |

No design protocol is in scope: this epic adds no game rules, and `END.W1` itself is #97. `leave-resume`,
`gallery-reset` and `mark-input` belong to #96, #94 and #111.

`PTU-settings` passed **all** checks. `PTU-play-puzzle` passed `P1` and failed `P2`'s judged state: the
result screen's Default stage renders blank because this build ships no pictures.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 → `UI-gallery.C3` | **pass** | the gallery's `Settings` button opens `UI-settings` (`NAV.T2`) |
| `PTU-settings` S2 → `UI-settings.C1`/`C2` | **pass** | each toggle flips its `SCH-preferences` flag and the label (`On`/`Off`) |
| `PTU-settings` S3 → `UI-settings.C3` | **pass** | Back returns to `UI-gallery`; reopening shows the changed values still set |
| `PTU-settings` P1 / P2 | **pass** | gallery → settings → Back → gallery works; Haptics stayed `Off` and Mute music stayed `On` across reopen |
| `PTU-settings` F1 / F2 | **no fail** | neither fail condition occurred |
| `UI-settings` US1.1 / US1.2 / US1.3 | **pass** | defaults `Haptics On` / `Mute music Off`; C1 → `Off`; C2 → `On` |
| `PTU-play-puzzle` S1 → gallery tile C1 | **pass** | the tile opens `UI-puzzle` for `pack-000` (`NAV.T1`) |
| `PTU-play-puzzle` S2 → get-set-ready | **pass** | the beat blocks marks, then marks are allowed |
| `PTU-play-puzzle` S3 → last fill | **pass** | a partial grid stays on `UI-puzzle` (US1.4b); the last fill opens `UI-result` (`NAV.T4`) |
| `PTU-play-puzzle` S4 → `UI-result.C1` | **pass** | Back returns to `UI-gallery` (`NAV.T5`) |
| `PTU-play-puzzle` P1 | **pass** | gallery → puzzle → result → gallery completes with no stuck screen; the morph spent 560.8 ms over 69 real frames (2 × 300 ms) |
| `PTU-play-puzzle` P2 | **FAIL** | see below: the result's judged Default state is blank, and the gallery shows the solved puzzle `Done` |
| `UI-result` US1.1 | **pass** | the morph runs on open and no control is offered during it |
| `UI-result` US1.2 | **FAIL** | `S1 Default` shows **no picture at all** — the reveal ends on empty paper |
| `UI-result` US1.5b | **pass** | C1 is unavailable while morphing |
| `NAV` US1.1 / US1.4 / US1.5 / T1 / T4 / T5 | **pass** | as the `PTU-play-puzzle` rows above |
| `NAV` US1.2 / US1.6 / T2 / T6 | **pass** | as the `PTU-settings` rows above |

### The failure

`PTU-play-puzzle`'s evidence line says *"Screenshot gallery after return (judged ever-completed tile)"*,
and that part passes — `#000` reads `Done`, `Best 0:00`, `Completed 1 / 200` in
[`p11`](screenshots/p11-gallery-after-result-back.png). The judging also covers the result screen the
step drives, and there the game fails its own spec.

| Spec claim | What the build shows |
|------------|----------------------|
| `UI-result` R1: "Fills morphing into the stored pixel picture, then that picture into the stored generated picture", *Visible when: Always* | Reaching `S1` paints nothing: the slot chain ends with no picture, so the layer draws nothing |
| `UI-result` S1: "Actor sees: Generated picture; R2" | Actor sees blank paper and only R2 ([`p10`](screenshots/p10-result-default.png)) |
| Approved `MC.result-mobile` / `MC.result-desktop`, `S1 Default` | the mockup's default state shows a rendered picture |
| `PER.R5` / `MOT.E1` / `MOT.E2` win reveal | the win resolves to an empty screen — no reveal payoff |

The last frame of the morph is a grid, and one frame later the screen is empty. This is not "pictures not
delivered yet"; it is the screen discarding the only content it has.

### Root cause

`Shell._picture_for()` returns `null` when the id is absent from the manifest, `ResultMorphSlot.show_picture(null)`
paints nothing, and `_apply_frames()` at `S1` sets `_picture` to 1.0 while `_fills` and `_pixel` go to 0.0 — so
every visible layer is empty. The build ships five audio entries and no picture pairs, and `pack-000`'s two
ids are absent from `assets/manifest.json` ([`logs/pictures-absent.log`](logs/pictures-absent.log)).

The three layers are correct; only the `S1` fallback is wrong. `ResultReveal` is documented as staying
"paper" without pictures, but a *blank* paper is the opposite of the approved mockup.

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`p0`](screenshots/p0-settings-default.png) | `UI-settings` on open: Haptics `On`, Mute music `Off` (US1.1) |
| [`p1`](screenshots/p1-settings-before-toggle.png) | the same defaults immediately before `S2` |
| [`p2`](screenshots/p2-settings-after-toggle.png) | after C1 and C2: Haptics `Off`, Mute music `On` |
| [`p3`](screenshots/p3-gallery-after-settings-back.png) | Back on `C3` returned to `UI-gallery` |
| [`p4`](screenshots/p4-settings-reopened-stuck.png) | settings reopened: Haptics `Off`, Mute music `On` — the values stuck |
| [`p5`](screenshots/p5-gallery-before-play.png) | `#000` reads `Not started` before play |
| [`p6`](screenshots/p6-puzzle-get-set-ready.png) | `UI-puzzle` during the get-set-ready beat |
| [`p7`](screenshots/p7-puzzle-marks-allowed.png) | marks allowed after ready |
| [`p8`](screenshots/p8-puzzle-one-fill-left.png) | mid-solve grid; still on `UI-puzzle` |
| [`p9`](screenshots/p9-result-morph-start.png) | `UI-result` mid-morph: the solved fills, no chrome |
| [`p10`](screenshots/p10-result-default.png) | **`S1 Default` — blank; the judged failure** |
| [`p11`](screenshots/p11-gallery-after-result-back.png) | after C1: `#000` `Done`, `Completed 1 / 200` |

## Paths

| Artifact | Path |
|----------|------|
| Notes and falsification | [`notes.md`](notes.md), [`falsification.md`](falsification.md) |
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_95.gd`](probe/probe_accept_95.gd) |
| Graphical probe, 36 checks + 12 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Picture ids vs shipped manifest | [`logs/pictures-absent.log`](logs/pictures-absent.log) |
| Suite 218/218 on this build | [`logs/suite.log`](logs/suite.log) |

## Quality evaluator

| Mode | Path | Result |
|------|------|--------|
| `deterministic` (verify-time, cited not re-run) | [`issue-95/2026-11-02-verify-reveal-clock`](../../../../quality/evidence/issue-95/2026-11-02-verify-reveal-clock/manifest.md), deliverable commit `a9f8558` | `frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free` all **pass**; no row `fail` or `blocked` |
| `llm-judge` | — | **N/A** — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) defines no `llm-judge` axis; every Applies axis is `deterministic` |

The deterministic record covers `a9f8558`, and `main` advanced only by `a0e6e3a`, which adds the
verification evidence folder itself — so the record covers this deliverable. The record is cited, not
edited, and its mode stays `deterministic`.

## Reproduce

Copy the probe to `game/probe_accept_95.gd`, then:

```
godot --headless --path game --import
godot --path game -s res://probe_accept_95.gd -- --shot-dir="$RUN/screenshots"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

Remove `game/probe_accept_95.gd` afterwards; it is not product code.

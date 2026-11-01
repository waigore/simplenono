# Verification rationale — issue #94

## Why verification fails

Two material findings, one of them a deterministic-record blocker:

1. **`frame-time` is blocked (`no-invariant`).** The target is "≤ 16.7 ms frame time during grid
   paint **and navigation**". This epic adds the screen that navigation lands on, and
   `Shell._show_gallery()` calls `GalleryScreen.refresh()` → `_rebuild()`, which builds or re-`setup`s
   all 200 `GalleryTile` nodes (each a `PanelContainer` with a button, a thumb, three labels, and a
   reset row) synchronously in the frame that returns to the gallery. The only frame sample in the
   harness is `paint`'s grid-paint window, which never draws the gallery; `navigate` claims I7/I9 and
   starts no `sample_start` window, so `navigate-samples.ndjson` is empty. The outcome can move with
   this deliverable and nothing observes it.

   [`workflow-deterministic-record.md`](../../../../docs/issues/workflow-deterministic-record.md) is
   explicit: a **blocked** row, or a harness that prevents the run, is a verification **Fail** — never
   a Pass with a note — and returns the issue to implementation with a named blocker. The blocker is:
   give the navigation window a sample window (for example `sample_start` before `home`,
   `sample_stop` after `result-gallery`, and around the gallery's refresh) and re-run; the existing
   `paint` row then covers grid paint and the new window covers navigation.

2. **R2 tile layout drifts from both approved mockups.** `MC.gallery-mobile` and
   `MC.gallery-desktop` were approved on 2026-11-02 and give the tile picture a square region
   (`.puzzle-tile .thumb { aspect-ratio: 1 }`). The build gives `GalleryThumb` an 88 px minimum band
   inside a variable-width open button and draws stored pictures with `draw_texture_rect(…, false)`
   — stretched into a non-square box. The capture in `shots/` shows the band at both widths. A
   stretched solution picture is both a layout drift and a behaviour consequence once #98 ships the
   pictures, so this is a material interface gap, not mockup polish. No separate defect is filed:
   #94 returns to implementation and carries the fix itself.

## Why the other axes were selected or skipped

- `time-to-playable` (I6) — the epic delivers the cold-launch target itself (the gallery), so the
  app-start row is its own outcome, not context: 253.3 ms, pass.
- `transition-latency` (I7) — the gallery→puzzle and leave→gallery legs are this epic's; the
  navigate run measures all four legs product-acknowledged at 290.3 ms, pass.
- `response-delay` (I8) — C1/C3 acknowledgements belong to this screen; 7.3 ms, pass.
- `crash-free` (I9) — the reset flow now runs through the gallery C2 trigger the shell consumes;
  no failed flow across four protocols, pass.
- `save-survives` / `failed-write` (I4) — this epic adds the only `user://progress.cfg` writer and
  the atomic replace; observed through the GUT checks, pass. The process-restart leg is I10.
- `hitch-bound` — its target is grid paint only, unchanged here.
- `resume-after-failure` (I10) — mark/elapsed commit is #96; #94 reads through `O1` and cannot move it.
- `runtime-signals` (I11) — no signal source added or removed.

## Boundary facts (not fail causes)

- `EX.confirm`, `SEQ reset` S2–S4, and `CTR-pack` O5/O6 remain #96's by the epic's single-owner
  table; this deliverable raises C2 and hands the intent to the shell, and re-reads `O1`/`O2` after a
  reset. `UI-gallery` US1.6 ("EX.confirm appears") and `J-gallery-reset` US1.1 therefore close
  jointly with #96; `US1.2`/B2 and the gallery-side legs are wholly this epic's.
- The epic has no leaf tasks; it was verified against its own element table and the shipped tests.

## Hygiene, not fail causes

- The harness's I6 observation string still reads "interactive shell home (gallery stand-in until
  #94)" (`game/test/integration/supervisor.gd:675`) and the README repeats it, although
  `home_ready` now asserts `Shell.GALLERY_VIEW` with `%Gallery` visible. The pass is correct; the
  label is stale and should be updated with the sampling change above.
- `specs/playtest/story-rows.md` points `UI-gallery` at #94 with no note, while US1.6 depends on
  #96's `EX.confirm`; the `J-gallery-reset` row already carries the joint-closure note. A one-line
  note on the `UI-gallery` row would keep the traceability honest; it is not material on its own.

## What passed

- O1/O2/O7 and the progress document: 200 entries in pack order, lazy reads that invent nothing,
  50-of-200 = 0.25, clear + file replacement on reset, unknown id writes nothing, failed write keeps
  the previous file, row-major mark round-trip.
- `UI-gallery` R1–R3, C1–C3, S1: completion copy and bar, three tile states plus replay, PB only when
  set, thumbnail only when ever-completed, C2 allowedness from the `O1` read, 2/4 columns.
- Shell gallery route and reset leg: boot to gallery, free-order open, leave refresh, C2 reaches the
  shell without a confirm or a write, refused C2 changes nothing, S5 re-read.
- `review-code` Pass (four suggestions); lint, format, spec lint, GUT 218/218, and all six PR checks
  green.

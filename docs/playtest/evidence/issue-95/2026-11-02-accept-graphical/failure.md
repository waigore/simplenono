# The failure — issue #95 `PTU-play-puzzle` P2

The one judged state that failed; the passing rows are in [`results.md`](results.md).

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

## Root cause

`Shell._picture_for()` returns `null` when the id is absent from the manifest, `ResultMorphSlot.show_picture(null)`
paints nothing, and `_apply_frames()` at `S1` sets `_picture` to 1.0 while `_fills` and `_pixel` go to 0.0 — so
every visible layer is empty. The build ships five audio entries and no picture pairs, and `pack-000`'s two
ids are absent from `assets/manifest.json` ([`logs/pictures-absent.log`](logs/pictures-absent.log)).

The three layers are correct; only the `S1` fallback is wrong. `ResultReveal` is documented as staying
"paper" without pictures, but a *blank* paper is the opposite of the approved mockup.

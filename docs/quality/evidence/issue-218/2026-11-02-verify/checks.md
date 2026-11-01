# Independent checks — issue #218

**Deliverable:** PR #223 (`6f7264f`, squash `dafd469`) against the issue's Expected behavior, fix surface, and test list.

## Deliverables checked

| Issue demand | Evidence |
|--------------|----------|
| S1 ends on the solved fills for `(fills, null, null)` | `test_us1_5_missing_pictures_end_on_the_solved_fills` asserts the fills slot is visible and drawable, the picture slot at 0. |
| S1 ends on the pixel picture for `(fills, pixel, null)` | `test_us1_5_missing_generated_picture_ends_on_the_pixel_picture` asserts the pixel slot is visible and drawable, the picture slot at 0. |
| No empty frame between S2 and S1 | `test_us1_5_no_frame_between_stages_is_empty` samples 0/150/299/300/301/450/599/600 ms for all three pairs and requires opacity > 0 with real content. |
| Each remaining stage runs `CFG.MORPH_STAGE_MS` | `test_us1_5_remaining_stages_keep_cfg_morph_stage_ms` checks the 299/300 and 599/600 ms boundaries. |
| Whole-chain fix, not S1-only | `_choose_targets()` picks both targets in `start()`; `_apply_frames()` fades or holds between them, so S2/S3 cannot empty. |
| Spec change carried | `result.md` R1/S1 gain the fallback and S3 the hold; stories align US1.1/US1.2 and add US1.5 with coverage. |
| Blank-paper class doc replaced | `result.gd` now documents the fallback instead of intentional blank paper (#98). |

## Commands and results

- Result-screen suite: 11/11, 576 asserts — `logs/result-screen-tests.log`.
- Full GUT suite: 227/227, 30,198 asserts — `logs/gut-suite.log`.
- Reveal probe, 10 ms samples through 600 ms, four picture pairs — `logs/reveal-probe.log`: terminal `fills` for both
  absent, `pixel` for pixel-only, `picture` for picture-only and both present; `empty_samples=[]` for every pair; all
  reach `S1`.
- `asset_catalog.py` → 0 errors — `logs/asset-catalog.log`.
- PR #223 checks: PR hygiene, Code lint, Unit tests, Coverage, Integration harness, Spec lint — all pass.
- Spec lint on this deliverable tree → 0 errors, 1 pre-existing glossary warning — `logs/spec-lint-clean.log`.

## UI and spec comparison

- Layout, palette, and copy are unchanged; the three reveal layers and the C1 row keep their boxes, so the approved
  `MC.result-mobile` / `MC.result-desktop` `default` still describe the screen. With no shipped picture the terminal is
  fills instead of the mockup's picture, which is the fallback R1/S1 now specifies.
- `specs/playtest/story-rows.md` keeps `UI-result` at `none` with its wave-expansion reason; defects are not story
  owners, so no row change is required.

## Advisories (non-material)

- `result_morph_slot.gd:50-53`: `has_content()` is called only by tests, while its doc says `ResultReveal` uses it. The
  behavior is correct; the comment overstates the call site.
- The picture-present/pixel-absent pair is handled (terminal picture, no empty sample) by fading fills into the picture
  during S2 and holding through S3. US1.1's new wording says "holding the fills while it is absent", so that pair
  differs in which stage performs the fade. It is not one of the issue's listed cases or a shipped pair.
- Class docs in `result.gd` / `result_reveal.gd` still say "US1.1-US1.4"; those lines predate this PR and US1.5 is in
  the story file. No functional effect.

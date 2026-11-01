# Independent checks — issue #95, `dafd469`

Run by `issue-workflow-verify-agent` (parallel id 1) on 2026-11-02, Godot 4.7.2 headless on macOS, at
`main` `8cfb263` (`dafd469` plus the #218 evidence folder). The product tree is identical to the epic's
deliverable commit `dafd4696d0670fad88feba310290b3cbfbb717af` (PR #223); the evidence folder below was
the only untracked path while the runs executed.

## Scope of this pass

The previous verification (`a9f8558`, folder `2026-11-02-verify-reveal-clock`) passed the epic and
acceptance then failed it on defect #218: the result reveal ended on blank paper when a stored picture
was missing. #218's fix is PR #223 (`dafd469`). This pass re-checks the epic's outcome against that
repaired build, so the diff since the last verified epic commit over the epic's files is exactly:

```text
game/presentation/result.gd              8 +--
game/presentation/result_morph_slot.gd   8 ++-
game/presentation/result_reveal.gd      46 +++++----
game/test/test_result_screen.gd         94 +++++++++++++----
specs/ux/screens/result.md               8 +--
specs/ux/stories/screens/result.md      20 ++++--
```

Settings (`settings.gd`, `shell.gd`), the `NAV` legs, and their suites are unchanged since `a9f8558`.

## Unit tests

```sh
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

`227/227` passing across 19 scripts, 30 198 asserts, 9.71 s — the implementor's count, reproduced
([`logs/gut-suite.log`](logs/gut-suite.log)). `Coverage` is green on PR #223.

## Lint, format, specs, catalog

```sh
gdformat --check game   # 80 files would be left unchanged
gdlint game             # Success: no problems found
python3 .github/scripts/spec_lint.py   # 0 errors, 1 pre-existing glossary warning
python3 .github/scripts/asset_catalog.py  # 0 errors
```

Logs: [`logs/gdformat.log`](logs/gdformat.log), [`logs/gdlint.log`](logs/gdlint.log),
[`logs/spec-lint.log`](logs/spec-lint.log), [`logs/asset-catalog.log`](logs/asset-catalog.log).

## Integration harness

Five protocols, one run folder:

```sh
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-95/2026-11-02-verify-reveal-fallback
```

`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset` — all `outcome=pass`
([`integration/results.md`](integration/results.md)). `navigate` sampled 250 frames across the solve
and the reveal (gallery window 77, reveal 173); `paint` sampled 203.

## Probes

The missing-picture fallback (the #218 repair) and the prior pass's clock finding are recorded in
[`fallback-probe.md`](fallback-probe.md): no frame between `S2` and `S1` is empty, and the single-clock
proof still holds at this commit.

## Mockup gate

`MC.result-mobile`, `MC.result-desktop`, `MC.settings-mobile`, `MC.settings-desktop` are all `approved`
(`specs/ux/mockups/catalog.md`, rows unchanged in this pass). The reveal's layout, palette, and stage
behavior are unchanged; only the terminal layer when a stored picture is absent follows the spec's new
R1/S1 clause. Graphical acceptance of the result default remains the acceptance step.

## Story rows

`UI-result`, `UI-settings`, `J-settings`, `NAV`, `ACT-player` remain `none` in
`specs/playtest/story-rows.md` with a durable reason naming this open epic — valid while #95 owns
delivery.

## Non-blocking notes

- `game/presentation/result.gd:3` still says `stories US1.1-US1.4`; US1.5 now covers the fallback.
  Doc-only; reported as a `[CONT]` suggestion in [`review-code.md`](review-code.md).
- `game/test/integration/relaunch.gd:156` still describes the launch target as a "gallery stand-in".
  Text-only, and that flow belongs to #96 (`kill-relaunch`/I10 is not selected here).

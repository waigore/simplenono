# Independent checks — issue #95, `40a05f6`

Run by `issue-workflow-verify-agent` (parallel id 1) on 2026-11-02, Godot 4.7.2 headless on macOS, at
`40a05f6786b4849f34d8b8a2dd139a5bf4c3b991` — the tree-identical branch commit of `main`'s
`a9f8558591dd6fe8bc8f4e70d653f9a326577d3e` (PR #216), with a clean tree apart from this evidence folder.

## Unit tests

```sh
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

`218/218` passing across 19 scripts, 29 985 asserts, 8.42 s — the implementor's count, reproduced.

## Lint and format

```sh
gdformat --check game   # 80 files would be left unchanged
gdlint game             # Success: no problems found
```

## Integration harness

Five protocols, one run folder (this directory):

```sh
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-95/2026-11-02-verify-reveal-clock
```

`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset` — all `outcome=pass`; `results.md` regenerated after
each. `navigate` sampled 173 frames across the solve and the reveal; `paint` sampled 203.

## Reveal clock (the repaired material defect)

Probe: the new real-frame test was run unmodified against the parent commit `94e6c55` in a temporary worktree,
then at `40a05f6` with a one-line `print` added to the test and the shell's `_process` (temporary worktree,
deleted afterwards; no product code in this tree changed). Run at a fixed frame delta so the measurement does
not depend on the headless runner's variable delta:

```sh
godot --headless --path game --fixed-fps 60 -s addons/gut/gut_cmdln.gd \
    -gtest=res://test/test_result_navigation.gd -gexit
```

| Commit | Clock time to `S1` | Frames | Verdict |
|--------|--------------------|--------|---------|
| `94e6c55` (before the fix) | **316.7 ms** | 19 | one stage's worth — two clocks |
| `40a05f6` (this deliverable) | **600.0 ms** | 36 | `2 x CFG.MORPH_STAGE_MS` (2 x 300 ms) |

Same two tests at `94e6c55` with the new test file copied in: `7/9` pass, and the two real-frame tests fail —

- `test_one_clock_plays_both_stages_on_real_frames`: `198.1` expected `> 450.0` (unfixed-fps run).
- `test_a_paused_attempt_freezes_the_morph`: stage `S3` expected `S2`, progress `0.353` expected `0.0`.

At `40a05f6`: `9/9` pass. The regression tests therefore fail on the old code and pass on this one.

## Pause freeze

`test_a_paused_attempt_freezes_the_morph` pauses the attempt after the solve and waits a full stage across real
frames: the reveal stays at `S2` with `progress() == 0.0` at `40a05f6`, and advanced to `S3` / `0.353` at
`94e6c55`.

## CI on the linked PRs

```sh
gh pr checks 216   # Code lint, Unit tests, Coverage, Integration harness, Spec lint, PR hygiene — all pass
```

PR #202 and PR #208 carry the same green set.

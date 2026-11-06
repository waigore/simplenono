# Playtest run — issue #700 (`self-test` seam run folder)

- **Issue:** #700 Integration harness: puzzle→result transition times the solve driver instead of the page transition (`type:task`, `priority:normal`)
- **Run id:** `2026-11-06-accept-1`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@e646158` (`game/` equals the deliverable `e032fc4`: the only `game/` changes since are #702's morph length and #713's comment/bound edits). Session `harness-1793976518`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, headless, fresh `user://` (`XDG_DATA_HOME` in a temp dir), one `--import` before the run.
- **Coverage mode:** `critical-only` — AC 5's seam proof only
- **Wiki page:** none. This is the `self-test` fixture protocol (no S1–S5 seam, no shell, no screen), so the protocol requires no screenshots and the quality run folder rule (`run_protocol.gd` rejects `self-test` under `docs/quality/`) puts it here as AC 5's in-repo path.

## Command

```sh
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --protocol=self-test --run-dir=docs/playtest/evidence/issue-700/2026-11-06-accept-1
```

Exit `0`. `integration/results.md` row: `self-test` → `pass`.

## Results — AC 5

| AC 5 clause | Observation | Outcome |
|-------------|-------------|---------|
| `flow` step `ok: true` | `steps[3]` `flow` `ok: true` | pass |
| `flows.self-test.fixture_frames > 0` | `2` | pass |
| `fixture:ack` `duration_ms ≥ 1` | `6.866 ms` | pass |
| `fixture:ack` smaller than its action's frame span | action span = sampled p95 frame period `6.667 ms` (`samples/self-test-samples.ndjson`, 46 frames); `6.866 ms` is the acknowledgement frame crossed after the action, one drawing turn | pass |
| `fixture:frame` under `1.5 ×` the sampled frame period | `6.761 ms`; ratio `1.014` against p95 `6.667 ms` (bound `1.5`) | pass |

Both legs are > 0 and no forced frame of padding appears. The `self-test` step list
also carries the pre-existing `ticked`, `painted`, `measured`, `sampled` rows, all
`ok: true`.

## Paths

| Artifact | Path |
|----------|------|
| Raw result | [`integration/results/self-test.json`](integration/results/self-test.json) |
| Summary | [`integration/results.md`](integration/results.md) |
| Frame samples | [`integration/samples/self-test-samples.ndjson`](integration/samples/self-test-samples.ndjson) |
| Hitch samples | [`integration/samples/self-test-hitches.ndjson`](integration/samples/self-test-hitches.ndjson) |
| Harness log | `integration/logs/` (gitignored, local only) |
| Notes | [`notes.md`](notes.md) |

## Quality evaluator

`deterministic`: reuse — [`docs/quality/evidence/issue-700/2026-11-06-verify-1/manifest.md`](../../../../quality/evidence/issue-700/2026-11-06-verify-1/manifest.md)
covers `e032fc4`: `transition-latency` **pass** (I7 `puzzle-result` 3.182 ms, longest 63.8 ms), `frame-time` **pass**, `hitch-bound` **pass**. Reuse holds while `game/` matches the recorded commit ([`workflow-deterministic-record.md`](../../../../issues/workflow-deterministic-record.md)); the moves since are #702/#713, cited in the acceptance comment. No new record written.

`llm-judge`: **N/A** — every axis in [`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is `deterministic`.

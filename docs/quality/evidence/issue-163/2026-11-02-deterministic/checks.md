# Checks — issue #163

## `runtime-signals` (I11)

I11 conjoins three signal families. All three are present on `fdcb298`, observed on a
debug build with S4:

1. **Severity-tagged error/crash logs.**
   - `integration/logs/severity-probe.log` is the real engine callback: a temporary
     probe (not committed) installed `SeverityLog` and called `push_warning` /
     `push_error`. It wrote:
     `SEV level=warn event=engine … message=seam-probe-warning (core/variant/variant_utility.cpp:1033)`
     and the matching `level=error` line, each carrying session, build, and story.
   - The same log opened with `SEV level=info event=session-start` and closed with
     `event=session-end`, the clean-run marker; a log without the end marker is the
     crash or kill signal a playtest reads.
   - GUT cannot carry this: a deliberate `push_error` fails a GUT test by design, so
     `test_s4_engine_errors_and_warnings_are_severity_tagged` drives `_log_error`
     directly and the transcript above proves the engine wiring.
2. **Frame/hitch timing samples.** The `paint` run wrote
   `integration/samples/paint-samples.ndjson` (203 frames) and an empty
   `paint-hitches.ndjson`; the producer is #166's sampler, not this issue.
3. **Story-ID telemetry events.** `integration/logs/harness-1793561456-paint.log`
   holds 405 `TEL` lines with `TEL.1`–`TEL.5`; the graphical repeat
   (`graphical-harness-1793561535-paint.log`) holds the same 405. The harness does not
   run under a story id, so `TEL.4` reads `-` there ("not applicable"). A direct open
   under `--story-ids` wrote `TEL event=open … story=L-solve.PS1.1 outcome=pass` in
   `integration/logs/story-ids-probe.log`.

## `review-code` — PR #169 and PR #185: **Pass**

No must-fix. `SRP`: seams, telemetry, severity sink, snapshot, and the CLI entry are
separate files; `DebugSeams` alone decides when an event fires, and the sinks never
reach into an attempt. `DIP`: `StateSnapshot` reads `Attempt` / `Pack` /
`ProgressRecord`, not screen internals. `ISP`: the one added signal
(`mark_applied`) is a narrow fact. `OCP`: `Attempt.pause()` / `resume()` mirror the
existing `advance()`, and `ProgressRules.holds()` is the read the S2 boundary needs
instead of a branch inside `record()`. `CONV` green via CI and locally. `CONT`: new
files follow the `class_name` / doc-comment pattern of their neighbours.
`SeverityLog._log_error` overrides only the error callback, so `print` output is not
duplicated (confirmed by line counts in the run logs).

## Independent checks on `fdcb298`

| Check | Result |
|-------|--------|
| GUT | `11 scripts / 142 tests / 142 passing / 29229 asserts`, exit 0 |
| Format / lint | `gdformat --check game` 58 files unchanged; `gdlint game` Success |
| PR checks | #169 and #185: Code lint, Unit tests, Coverage, Spec lint, PR hygiene, Integration harness all SUCCESS |
| Flag off | headless boot exit 0, zero `TEL` / `SEV` lines |
| Flag on | boot writes `session-start` / `session-end` |
| S5 CLI | `logs/state-pack-042.json` written (exit 0); unknown id exit 1; flag off exit 2; missing argument exit 2 |

## Assets and mockups

- `review-asset`: N/A — no cataloged asset changed.
- Mockup gate: N/A — the seams are playtest tools behind the debug flag
  (`tools.md`), not a formalized player screen; the issue states this and no `MC.*`
  row is in scope.

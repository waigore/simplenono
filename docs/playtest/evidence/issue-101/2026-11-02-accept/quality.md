# Quality-record rationale — issue #101

No deterministic record is cited because no Applies axis is in play at `007140d`:

| Axis | Why it cannot move |
|------|--------------------|
| `frame-time`, `hitch-bound` | No paint surface; the stub sets one label |
| `time-to-playable` | Bar is cold launch to the interactive gallery; #94 owns the gallery |
| `transition-latency`, `response-delay` | No navigation, settings toggle, or Back |
| `crash-free`, `resume-after-failure` | No open/solve/reset/back flow and no attempt or persisted marks |
| `runtime-signals` | No S4 sink or seam in the deliverable (#163 added it later) |
| `save-survives`, `failed-write` | No persistence |

Verification reached the same selection (`2026-11-01T19:41`). `rubrics.md` defines no `llm-judge` axis (baseline axes are all deterministic; domain axes: none), so acceptance runs no judge.

## Existing `issue-101` records that are not cited

- `docs/quality/evidence/issue-101/2026-11-01T154755Z/` selected three axes this stub cannot move and marked them `blocked`; verification identified that selection as the error. Verify's correction supplies the N/A determination used here.
- `docs/quality/evidence/issue-101/2026-11-02T192940Z/` measures today's `main` after #112/#169 replaced `shell.gd`. Its deliverable commit `fdcb298` is not #101's code, so it is not a record for this deliverable.

A record with a `fail` or `blocked` row is an acceptance Fail; neither record is for an Applies axis of this commit, so neither triggers that rule.

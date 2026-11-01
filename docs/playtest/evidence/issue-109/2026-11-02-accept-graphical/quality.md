# Quality evaluator — issue #109 acceptance run

**Mode:** acceptance. Deterministic mode is not run here; verify owns it.

## Deterministic: no axis selected

`crash-free` (I9) is the only Applies axis whose flows include solving. Its evaluator is the
integration harness, not a leaf unit run, and the harness already scored it on a build that contains
this deliverable:

- [#166 acceptance](../../../../quality/evidence/issue-166/2026-11-02-acceptance/assessment.md),
  `main@66c6363` — `paint`, `navigate`, `ui-ack`, and `solve-reset` all pass I9 `crash-free` with the
  flows open, solve, reset, and back.
- `#109`'s solve edge merged at `22654c9`, before that build, so the harness's solve flow includes
  this code.

The leaf adds no harness, timing, session, or save surface of its own, so it cannot move any other
Applies axis. The other Applies axes belong elsewhere: `frame-time` / `hitch-bound` / `time-to-playable`
need sampling and launch (#166), `transition-latency` and `response-delay` are navigation (#112,
#94/#95), `resume-after-failure` and save durability are #96, and `runtime-signals` is #163's.

Supporting observation, not a substitute: the capture session ran open → blocked and paused taps →
three solves → three reopens with `session-start` / `session-end` and **zero** severity `error` or
`warning` lines ([`logs/capture-console.log`](logs/capture-console.log)).

## llm-judge: N/A

No domain axes are declared ([`rubrics.md`](../../../../../specs/definition/quality/rubrics.md)), so
no qualitative axis can move and no judge record applies.

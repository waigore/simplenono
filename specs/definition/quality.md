# Quality Expectations

Authoring rules: [`.agents/specs/rules/quality.md`](../../.agents/specs/rules/quality.md).

Characteristics in this table are the source of truth. Each row cites one axis reached from [`quality/rubrics.md`](quality/rubrics.md). That axis states the outcome and the evaluator. The target on an Applies row is the bar for its axis.

## Categories

| Category | Applicability | Target | Platforms | Axis |
|----------|---------------|--------|-----------|------|
| Performance | Applies | ≤16.7 ms frame time (~60 fps) during grid paint and navigation | all supported | `frame-time` |
| Performance | Applies | No hitch longer than 100 ms during grid paint on mid-range phones | all supported | `hitch-bound` |
| Load time / latency | Applies | Cold launch to interactive gallery ≤ 3 s on mid-range phones | all supported | `time-to-playable` |
| Load time / latency | Applies | Gallery↔puzzle, puzzle→result, and result→gallery ≤ 500 ms | all supported | `transition-latency` |
| Load time / latency | Applies | Non-paint UI (open puzzle, settings toggle, Back) acknowledges ≤ 500 ms | all supported | `response-delay` |
| Reliability | Applies | No crash across open, solve, reset, and back flows | all supported | `crash-free` |
| Reliability | Applies | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | all supported | `resume-after-failure` |
| Observability | Applies | Local severity-tagged error/crash logs; frame/hitch timing samples; playtest telemetry events keyed to story IDs | all supported | `runtime-signals` |
| Save durability | Applies | Committed progress (ever-completed, PB, marks, elapsed, attempt) survives quit, crash, and upgrade within the same major save schema ([ADR-0002](../adr/decisions/0002-user-data-dir.md)) | all supported | `save-survives` |
| Save durability | Applies | A failed progress write leaves the previous commit loadable | all supported | `failed-write` |
| Accessibility | N/A — personal/simple product; no store a11y mandate ([`definition.md`](definition.md) Market) | — | — | `distinguishable-channels` |
| Accessibility | N/A — same reason | — | — | `adjustable-timing` |
| Accessibility | N/A — same reason | — | — | `text-audio-scale` |
| Localization | N/A — English-only UI ([`experience.md`](../design/experience.md)) | — | — | `shipped-locales` |
| Localization | N/A — same reason | — | — | `translated-content` |
| Localization | N/A — same reason | — | — | `text-growth` |

## Rubrics

[`quality/rubrics.md`](quality/rubrics.md).

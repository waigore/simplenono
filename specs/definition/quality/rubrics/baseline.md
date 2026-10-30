# Baseline rubric axes

Authoring rules: [`.agents/specs/rules/quality.md`](../../../../.agents/specs/rules/quality.md).

These axes are fixed. The bar is the matching target in [`../../quality.md`](../../quality.md). Scale and pass level are — because every evaluator here is deterministic. Evidence is what the check observes.

| Axis | Characteristic | Outcome | Evaluator | Evidence | Scale | Pass level |
|------|----------------|---------|-----------|----------|-------|------------|
| `frame-time` | Performance | Frame time during play stays within the target | deterministic | Frame-time samples during play | — | — |
| `hitch-bound` | Performance | Hitch length stays within the target | deterministic | Hitch lengths during play | — | — |
| `time-to-playable` | Load time / latency | Time from launch until playable stays within the target | deterministic | Launch-to-playable timing | — | — |
| `transition-latency` | Load time / latency | Stage or mode transitions stay within the target | deterministic | Transition timings | — | — |
| `response-delay` | Load time / latency | Response delay outside the frame budget stays within the target | deterministic | Input-to-response samples outside the frame | — | — |
| `crash-free` | Reliability | Play stays crash-free for the target session length | deterministic | A session of the target length | — | — |
| `resume-after-failure` | Reliability | After a failure, play resumes at the target point | deterministic | A failure followed by resume | — | — |
| `runtime-signals` | Observability | The target signals are present at the target fidelity | deterministic | Presence of the stated signals | — | — |
| `save-survives` | Save durability | A committed save survives quit, crash, and upgrade in the target version range | deterministic | Quit, crash, and upgrade of a committed save | — | — |
| `failed-write` | Save durability | A failed write leaves the previous commit intact | deterministic | A failed write followed by load | — | — |
| `distinguishable-channels` | Accessibility | Each target channel has its stated alternative | deterministic | Each stated channel and its alternative | — | — |
| `adjustable-timing` | Accessibility | Stated timing or assist controls change the target parameter | deterministic | Each stated control across its range | — | — |
| `text-audio-scale` | Accessibility | Text and audio scale across the target range | deterministic | Text and audio at the stated bounds | — | — |
| `shipped-locales` | Localization | The target locales are present in the build | deterministic | Locales in the build | — | — |
| `translated-content` | Localization | Target player-facing content is translated for each shipped locale | deterministic | Stated content per shipped locale | — | — |
| `text-growth` | Localization | Translated text stays within the target growth bound | deterministic | Translated length against the source | — | — |

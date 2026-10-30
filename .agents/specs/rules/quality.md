# Authoring rules: quality

Read this before editing `specs/definition/quality.md`, `specs/definition/quality/rubrics.md`, or a category split out of either. Do not copy these rules into the spec.

Also read [definition.md](definition.md). Stay consistent with `specs/vision.md` and with the platforms and constraints in the definition.

Record observable outcomes. Architecture, engines, data formats, and APIs belong in their own specs.

Replace every `<!-- fill in -->`.

## Categories

Each category is **Applies** or **N/A — reason**. An N/A reason cites the vision or the supported platforms. At prototype spec depth, a category other than performance may cite spec depth instead, per [depth.md](depth.md). An Applies row has a measurable target, the platforms it covers, and exactly one axis id listed in the rubric files linked from `specs/definition/quality/rubrics.md`. Those platforms match the definition's supported-platforms table. An N/A row uses "—" for target and platforms. The axis id stays, and that axis is not scored. Add a row when one category has more than one axis. Rows for the same category do not contradict each other, the constraints, or the vision. A target set or limited by an architecture decision cites its ID in the target, such as `(ADR-0003)`.

These seven categories are always present. They are the baseline. A genre outcome that none of their axes measure is a new category row, then one new axis. A vision quality is not a category and not an axis.

- **Performance**: frame time during play, and a separate bound on hitch length.
- **Load time / latency**: time until playable, stage or mode transitions, and response delay outside the frame budget.
- **Reliability**: crash-free play for a stated length, and where play resumes after a failure.
- **Observability**: which runtime signals are visible (logs, errors or crashes, timing or profiling, and optional telemetry), at a stated fidelity. The target scales from local severity-tagged logs to remote telemetry and detailed timing. Tools, formats, and sinks belong in ADRs.
- **Save durability**: committed progress survives quit, crash, and upgrades in a stated version range. A failed write leaves the previous commit intact.
- **Accessibility**: who can perceive and operate play. Distinguishable channels, adjustable timing or assists, text and audio scale.
- **Localization**: which locales ship, which player-facing content is translated, and a bound on text growth.

## Rubrics

`quality.md` sections are Categories and Rubrics. The Rubrics section links `specs/definition/quality/rubrics.md`. Domain characteristics are extra rows in Categories, not a separate section.

`rubrics.md` sections are Baseline axes, Domain axes, and Judge record. Baseline axes may live in `specs/definition/quality/rubrics/baseline.md`, linked from that section. `quality.md` is the source of truth for characteristics. Each axis evaluates one outcome of one characteristic. Applicable axes are reported separately. The product passes only when every applicable axis meets its bar. There is no combined score. The target on the characteristic row is the bar.

Baseline axis ids are fixed. Do not rename, remove, or change their evaluator. Set only Applies or N/A, the target, and the platforms.

| Axis | Characteristic |
|------|----------------|
| `frame-time`, `hitch-bound` | Performance |
| `time-to-playable`, `transition-latency`, `response-delay` | Load time / latency |
| `crash-free`, `resume-after-failure` | Reliability |
| `runtime-signals` | Observability |
| `save-survives`, `failed-write` | Save durability |
| `distinguishable-channels`, `adjustable-timing`, `text-audio-scale` | Accessibility |
| `shipped-locales`, `translated-content`, `text-growth` | Localization |

A domain axis uses a new kebab-case id that is not in that table. Add one only when no existing axis would already fail on the same outcome.

The evaluator is `deterministic` or `llm-judge`. Use `deterministic` when a threshold or an invariant can decide pass or fail. Use `llm-judge` only when it cannot. A deterministic row uses "—" for scale and pass level. An `llm-judge` row records an ordinal scale of at least two levels, the minimum passing level, and the evidence the judge may see (build observations, screenshots, logs, or telemetry). The outcome is the criterion. The judge does not add criteria.

A deterministic axis is the verification obligation for that outcome. When `specs/technical/verification.md` exists, one invariant cites each automatable deterministic axis id. An `llm-judge` result binds acceptance. `run-quality-evaluators` executes the selected axes: `deterministic` during verification, `llm-judge` during acceptance. Verification fails when an in-scope deterministic axis has no citing invariant. Acceptance cites the deterministic evidence record and does not run those checks again. When the rubric is the thing that is wrong, acceptance returns for clarification. The result is not waived while the axis stays as written. Playtest proves design and UX stories. It does not score these axes.

## Where an Applies category is carried out

Performance, load time, reliability, and observability stay in this file and the rubric file.

- Accessibility and localization: state the player-facing consequences in `specs/design/experience.md`.
- A rule-changing assist or timing option: a row in `specs/design/configuration.md`.
- Save durability: what is committed, when it becomes permanent, and where play resumes, in `specs/design/progression.md`.
- How the interface presents accessibility, localization, and save failure: `specs/ux/ux.md` and the UX rules that cover those topics.
- Motion comfort and non-audio equivalents of positional sound: `specs/view/perception.md` and `specs/view/audio.md`.

## Splitting

If `quality.md` passes 500 words, move the longest category to `specs/definition/quality/<category>.md`. Leave a one-line summary and a link in the table, and add the new file to `specs/README.md`. If `rubrics.md` passes 500 words, move domain axes for one characteristic to `specs/definition/quality/rubrics/<characteristic>.md` the same way. Baseline axes stay together in `rubrics/baseline.md` when they do not fit in `rubrics.md`.

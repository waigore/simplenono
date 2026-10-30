# Applicability graph

Edges for [`audit-spec-applicability`](../SKILL.md). From [`.agents/specs/rules/`](../../../specs/rules/) — especially [quality.md](../../../specs/rules/quality.md), hub `traceability.md` rules, and [adr/decision.md](../../../specs/rules/adr/decision.md). Update when those rules change.

**Claim sites:** `specs/definition/quality.md` (and splits); design/view/UX/ADR/technical `traceability.md` topic tables; ADR **Quality expectations**; optional technical hub lines.

## Quality categories

| Category | Upstream ground | Downstream when Applies | When N/A |
|----------|-----------------|-------------------------|----------|
| Performance | Vision / platforms / definition constraints | Stays in `quality.md`. Targets may cite design loops/stages/modes. ADR Affects + Validation when an ADR limits the target | Reason cites vision or platforms; ADR row `N/A in quality.md` |
| Load time / latency | Same | Same as Performance | Same |
| Reliability | Same | Same as Performance | Same |
| Observability | Same; fidelity may scale | Stays in `quality.md`. Tools/sinks in ADRs. Optional `technical/verification.md` when warranted | Same |
| Save durability | Definition scope / progression that persists | `design/progression.md` (what/when/resume, **M1**); UX save-failure Applies; technical `persistence` only if hub-indexed | Same reason on progression / UX save-failure; no filled durability target |
| Accessibility | Vision / audience / platforms | `design/experience.md`; assists → `design/configuration.md`; UX accessibility presentation; `view/perception.md` comfort; `view/audio.md` non-audio equivalents when audio Applies; aesthetics accessible color and type (`PAL.K`, `UIS.T`); assets accessible variants when a color rule or comfort option needs one | Same reason on experience, UX presentation, perception comfort, aesthetics accessible color and type; motion comfort N/A unless accessibility Applies and a camera moves alone |
| Localization | Vision / market / platforms | `design/experience.md` Localization; UX localization copy Applies; aesthetics script coverage; assets localized assets | Same reason on experience, UX localization copy, aesthetics script coverage, and assets localized assets |

Performance, load time, reliability, and observability need no design/UX file beyond `quality.md`.

Every characteristic row cites exactly one axis in `specs/definition/quality/rubrics.md`. An N/A row's axis is not a downstream carry-out. When `specs/technical/verification.md` exists, each automatable deterministic axis is cited by an invariant there.

## Hub topic follow-ons

| Hub | Follow-on |
|-----|-----------|
| View | Motion comfort ← accessibility Applies **and** camera moves alone. Haptics N/A if no haptic platform. Diagrams Applies if camera or projection Applies. Spatial/audio/physics N/A without world space / positional sound / simulated motion |
| Aesthetics | Sound style N/A only if experience gives sound no role and no platform plays sound. Motion style N/A only if nothing animates. Accessible color and type, script coverage follow quality. Sheets Applies unless spec depth requires none |
| UX | Accessibility presentation, localization copy, save-failure follow quality |
| Assets | Each kind row ← view dimensionality and rendered space, aesthetics medium, design and UX. Source types ← definition constraints. Sound assets ← aesthetics sound style. Localized assets and accessible variants follow quality. Asset access and load groups ← any Applies kind |
| Technical | Optional globals Applies iff hub indexes the file. Diagrams Applies if any technical topic Applies. Persistence should agree with save durability when that Applies. Asset access and loading follows the assets topic of the same name |
| Design | Topic N/A cites genre/platform profile or definition. Sub-games "None" ⇒ topic N/A, no files |
| ADR Stack | Area N/A grounded in definition or design profile |

## ADR Quality expectations

Per Accepted ADR in `specs/adr/decisions/`:

- Quality **Applies** → `Affects` or `No effect`. `Affects` cites the target; Validation covers it or cites that row's rubric axis.
- Quality **N/A** → `N/A in quality.md`.
- Mismatch either way → `ADR mismatch`.

## Audit order (whole set)

1. `quality.md` (definition/vision/platforms first).
2. Design → view → aesthetics → UX → assets topic tables.
3. Accepted ADR Quality rows.
4. Technical topics and optional globals vs hub index.

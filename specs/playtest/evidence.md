# Playtest evidence

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

## Root and layout

- **In-repo root**: [`docs/playtest/evidence/`](../../docs/playtest/evidence/)
- **Run folder**: `issue-<n>/<run-id>/` with `manifest.md` and `notes.md` only
- **Wiki media**: screenshots and logs on the repo wiki — layout and write path in [`docs/playtest/wiki-evidence.md`](../../docs/playtest/wiki-evidence.md)
- **Skip**: when [`playtest.md`](playtest.md) says playtesting is not required, no folder is required

## Required artifacts

| Artifact | Requirement |
|----------|-------------|
| Story IDs | Every design/UX story (or protocol) in the run's scope |
| Pass / fail | One outcome per story or protocol |
| Screenshots | On the wiki; see below |
| Notes | `notes.md` in the run folder |
| Logs | On the wiki; session excerpt for the judged window |
| `manifest.md` | Index of the above, including the wiki page URL |

## Manifest (`manifest.md`)

| Field | Content |
|-------|---------|
| Issue | GitHub issue number |
| Build / session id | Matches `TEL.3` where possible |
| Coverage mode | `full` or `critical-only` from the hub |
| Results | Table: story or protocol ID → pass / fail |
| Paths | Path to `notes.md`; **wiki page URL** for screenshots and logs. A headless run marks screenshots as waiting on a graphical run |

## Screenshots, logs, notes

- **Screenshots**: Required before acceptance unless the protocol says none. ≥1 image per **failed** protocol; for each **pass**, ≥1 image of the judged state. Images come from a **graphical run** that re-runs the protocols on the same build the judgement used. Store them on the wiki; cite the wiki page URL in `manifest.md`.
- **Headless run**: May judge and record pass/fail, notes, and logs with no display. Mark screenshots waiting in `manifest.md`. That omission is not a protocol fail and does not file a defect. The issue stays `status:pending-acceptance`.
- **Logs**: On the wiki, covering the judged window so `TEL.1`–`TEL.5` can be correlated.
- **Notes**: `notes.md` in-repo — what was judged, blockers, and non-blocking marks only when the protocol allows.

## Retention

Keep the in-repo run folder and the wiki page (with media) until the accept outcome for that issue is recorded. Do not delete either before then.

## Cite from acceptance

`accept-project-issue` cites the run folder (`manifest.md`) and the **wiki page URL** when playtesting was required. It records acceptance only after graphical-run screenshots for the same build are on that wiki page for every protocol that requires them. A protocol that says none may be accepted from the headless run alone. A game or interface fail still blocks acceptance and may file a defect without those screenshots. Procedures: [`procedures.md`](procedures.md).

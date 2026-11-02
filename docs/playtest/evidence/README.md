# Playtest evidence

In-repo evidence from AI-agent playtesting. Schema and requirements: [`specs/playtest/evidence.md`](../../../specs/playtest/evidence.md). Gate and scope: [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md).

## Layout

`issue-<n>/<run-id>/` with at least:

- `manifest.md` — issue, build/session id, coverage mode, results table, paths
- `notes.md`
- `screenshots/` — after a graphical run of the same build; a headless-only folder may omit it when `manifest.md` marks screenshots as waiting
- `logs/`

Markdown under `issue-*` is outside the 500-word cap. This README stays inside it.

## When required

Only when acceptance deliverables change playable behavior. Spec-only and docs-only issues do not need a folder here.

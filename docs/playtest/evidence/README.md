# Playtest evidence

In-repo index from AI-agent playtesting. Schema: [`specs/playtest/evidence.md`](../../../specs/playtest/evidence.md). Gate: [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md). Wiki media: [`wiki-evidence.md`](../wiki-evidence.md).

## Layout

`issue-<n>/<run-id>/` with:

- `manifest.md` — issue, build/session id, coverage mode, results table, wiki page URL, path to `notes.md`
- `notes.md`

Screenshots and logs are **not** stored here. Push them to the repo wiki and cite the wiki page URL. Do not commit `screenshots/` or `logs/` under this tree (gitignored).

Markdown under `issue-*` is outside the 500-word cap. This README stays inside it.

## When required

Only when acceptance deliverables change playable behavior. Spec-only and docs-only issues do not need a folder here.

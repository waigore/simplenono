# Authoring rules: playtest evidence

Read this before editing `specs/playtest/evidence.md` or a file split from it. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md), [tools.md](tools.md), and [procedures.md](procedures.md). Keep [`docs/playtest/evidence/README.md`](../../../../docs/playtest/evidence/README.md) and [`docs/playtest/wiki-evidence.md`](../../../../docs/playtest/wiki-evidence.md) consistent with this schema (process layout, not a second product spec).

What a required AI-agent playtest run must leave so `accept-project-issue` can cite it. No engine, log-sink, or image-format product names.

## Root and layout

- In-repo root: `docs/playtest/evidence/`.
- One folder per issue/run: `issue-<n>/<run-id>/` (run-id is a date or opaque id) with only `manifest.md` and `notes.md`.
- Screenshots and logs live on the **repo wiki** (not in git). Page, media paths, and write steps: [`docs/playtest/wiki-evidence.md`](../../../../docs/playtest/wiki-evidence.md).
- When the hub gate says playtesting is not required, no evidence folder is required.

## Required artifacts

Each required run includes: story IDs covered; pass/fail per story or protocol; notes (in-repo); logs and screenshots (wiki) when required. Name the files the agent must write.

## Manifest

Require `manifest.md` in the run folder. It lists: issue number, build or session id, coverage mode, a table of story (or protocol) ID → pass/fail, path to `notes.md`, and the **wiki page URL** for screenshots and logs. A headless run marks screenshots as waiting on a graphical run. Do not require JSON unless the project later adds it via ADR.

## Screenshots, logs, notes

- **Screenshots**: at least one image per failed protocol; for a pass, at least one image showing the judged state unless the protocol says none. Images come from a graphical run that re-runs the protocols on the same build the judgement used. Store them on the wiki under that run's media tree; cite the wiki page URL from the manifest.
- **Headless run**: may judge and record pass/fail, notes, and logs with no display. It may omit screenshots. That omission is not a protocol fail, does not file a defect, and leaves the issue on `status:pending-acceptance` until the graphical screenshots exist on the wiki. A game or interface fail may still file a defect without screenshots.
- **Logs**: session excerpt covering the judged window so `TEL.*` fields can be correlated; stored on the wiki; wiki page URL listed in the manifest.
- **Notes**: `notes.md` in-repo — what was judged; blockers; non-blocking marks only when the protocol allows.

## Retention

Keep the in-repo run folder and the wiki page (with media) at least until the accept outcome for that issue is recorded. Do not delete or empty either before that.

## Splitting

If the file passes 500 words, move the manifest field list to `evidence-manifest.md`. Leave a summary and a link, and update `playtest.md`.

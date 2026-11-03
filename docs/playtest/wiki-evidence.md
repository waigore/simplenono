# Playtest wiki evidence

Screenshots and logs for AI-agent playtests live on the **repo wiki**. The git tree keeps only `manifest.md` and `notes.md` under [`evidence/`](evidence/). Schema: [`specs/playtest/evidence.md`](../../specs/playtest/evidence.md).

## Page and media layout

| Item | Value |
|------|--------|
| Page title / slug | `Playtest-issue-<n>-<run-id>` |
| Page URL | `https://github.com/<owner>/<repo>/wiki/Playtest-issue-<n>-<run-id>` |
| Screenshots | wiki git: `playtest/issue-<n>/<run-id>/screenshots/` |
| Logs | wiki git: `playtest/issue-<n>/<run-id>/logs/` |

Wiki page body: issue number, build/session id, coverage mode, results table (or pointer to in-repo `manifest.md`), and relative links to media files.

## Write path (forward)

1. Ensure the wiki is enabled (Settings → Features → Wikis, or create the first page). Clone: `git clone https://github.com/<owner>/<repo>.wiki.git`.
2. Create or update the page markdown and media dirs for this run. Commit and push the wiki repo.
3. In-repo: write `docs/playtest/evidence/issue-<n>/<run-id>/{manifest.md,notes.md}`. Manifest **Paths** = wiki page URL + path to `notes.md`. Do not commit `screenshots/` or `logs/` under `docs/` (gitignored).
4. Cite the in-repo run folder and the wiki page URL from PRs and `accept-project-issue`.

Headless runs may push logs and mark screenshots waiting in the manifest until a graphical re-run of the same build fills the wiki media.

## Retention

Keep the in-repo folder and the wiki page (with media) at least until the accept outcome for that issue is recorded.

## Migrate existing in-repo media

For each `docs/playtest/evidence/issue-*/<run-id>/` that still has `screenshots/` or `logs/`:

1. Enable the wiki if needed; clone `<repo>.wiki.git`.
2. Copy those dirs into `playtest/issue-<n>/<run-id>/` in the wiki tree; create the wiki page; push.
3. Set manifest Paths to the wiki page URL; delete in-repo `screenshots/` and `logs/`.
4. Confirm `.gitignore` ignores those paths; open one focused PR.

Do not rewrite git history unless the user separately asks (`git filter-repo`). Past blobs stay until then.

Skill: [`migrate-playtest-evidence-to-wiki`](../../.agents/skills/migrate-playtest-evidence-to-wiki/SKILL.md).

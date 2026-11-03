---
name: migrate-playtest-evidence-to-wiki
description: |-
  Move in-repo playtest screenshots and logs to the GitHub wiki, rewrite
  manifests to cite the wiki page URL, delete local media dirs, confirm
  gitignore, and open a focused PR. Use when a child repo still stores
  playtest media under docs/playtest/evidence/, or when the user asks to
  migrate playtest evidence off git.

  Examples:
    - user: "Migrate playtest evidence to the wiki" → wiki push, manifest rewrite, PR
    - user: "Move screenshots out of docs/playtest/evidence" → same
    - user: "What would migration change?" → inventory only, no PR
---

# Migrate playtest evidence to wiki

Thin skill. Contract: [`docs/playtest/wiki-evidence.md`](../../../docs/playtest/wiki-evidence.md) (Migrate section). Forward layout and cite rules live there. Do not invent a parallel schema.

## Steps

1. **Read** the contract (page naming, media paths, retention, migrate steps).
2. **Inventory**: list `docs/playtest/evidence/issue-*/<run-id>/` folders that still contain `screenshots/` or `logs/`. If none, report nothing to migrate and stop (still confirm gitignore matches the contract).
3. **Wiki**: ensure Wikis are enabled; clone `<owner>/<repo>.wiki.git`. Fail clearly if auth or wiki create fails.
4. **Migrate each run**: copy media into `playtest/issue-<n>/<run-id>/` in the wiki tree; create or update page `Playtest-issue-<n>-<run-id>`; push the wiki. Rewrite that run's `manifest.md` Paths to the wiki page URL (keep `notes.md`). Delete in-repo `screenshots/` and `logs/` for that run.
5. **Gitignore**: confirm `docs/playtest/evidence/**/screenshots/` and `docs/playtest/evidence/**/logs/` are ignored; add them if missing.
6. **PR**: unless the user asked inventory-only, open one focused PR with the manifest edits, deletions, and gitignore. Do not rewrite git history (`filter-repo`) unless the user separately asks.
7. **Report**: runs migrated, wiki page URLs, PR URL (or inventory-only result).

## Rules

- **Explicit only**: do not call this from acceptance or other skills as a gate.
- Quality evidence under `docs/quality/evidence/` is out of scope.
- Do not move `manifest.md` or `notes.md` to the wiki.
- Do not force-push the main repo or wiki.

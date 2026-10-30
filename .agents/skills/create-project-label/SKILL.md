---
name: create-project-label
description: |-
  Add a repository label to .github/project-labels.yml and docs/labels.md, then sync it to GitHub by default.
  Use when defining a new issue label for categorization or agent orchestration.
  Use proactively when the user asks to add a label, create type:/status: labels, or extend the project label catalog.

  Examples:
  - user: "Add a type:spike label for research work" → add to config + docs, sync to GitHub
  - user: "Create a priority:high label, don't sync yet" → update files only (--no-sync)
  - user: "Register label status:blocked with color aa0000" → upsert by name, sync
  - user: "Add project label for defects we already have typed" → clarify name/description/color, then apply
---

# Create project label

Add or update a declarative repository label used for issue categorization and agent orchestration.

## Inputs

Collect before editing (ask if missing):

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | Exact GitHub label name (e.g. `type:spike`). Identity key. |
| `description` | yes | Short, self-documenting text (shown in GitHub UI). |
| `color` | yes | 6-digit hex **without** `#` (e.g. `0E8A16`). |
| `--no-sync` | no | If set, only update local files; skip GitHub sync. |

Default: **sync to GitHub** after local edits.

## Steps

1. **Read** [`.github/project-labels.yml`](../../../.github/project-labels.yml) and [`docs/labels.md`](../../../docs/labels.md).
2. **Upsert config** in `.github/project-labels.yml` by `name`:
   - If the name exists, replace its `color` and `description`.
   - Otherwise append a new list entry:

     ```yaml
     - name: <name>
       color: "<color>"
       description: "<description>"
     ```

3. **Update docs** in `docs/labels.md` catalog table so it matches the config (same name, color, description). Keep the rest of that file intact.
4. **Sync** unless the user asked for `--no-sync` / "don't sync":
   - Prefer: `bash .github/scripts/sync-labels.sh` from the repo root (requires `gh` and `yq`).
   - Fallback if the script cannot run: `gh label create "<name>" --color "<color>" --description "<description>"` or `gh label edit` if the label already exists.
5. **Report** what changed (created vs updated vs local-only) and remind that pushing the YAML to `main` also triggers Actions sync.

## Rules

- Do **not** delete labels from GitHub or remove unrelated entries from the config.
- Do **not** invent names/colors without user confirmation when ambiguous.
- Keep descriptions concise and actionable for agents and humans.
- After adding orchestration-relevant labels, mention the AGENTS.md Labels section if agents should know about the new label in the short catalog (update that table when the label is a core `type:` used in everyday workflow).

## Related

- Sync workflow: `.github/workflows/sync-labels.yml`
- Full docs: `docs/labels.md`

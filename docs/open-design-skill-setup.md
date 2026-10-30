# Open Design skill setup

Ensure the [Open Design skill](https://github.com/sugarforever/open-design-skill) wrapper and the [Open Design](https://github.com/nexu-io/open-design) content repo are installed under a well-known home directory, then optionally wire the skill into Cursor / OpenCode / Grok as **user-local** skills. Invoke only when the user asks (`ensure-open-design-skill-setup`); other skills do not require it.

This doc is the contract for local outcomes. Project binding for mockups stays in `specs/ux/presentation.md` (no root `.open-design.json`).

## Well-known paths

| Role | Path | Source |
|------|------|--------|
| Skill wrapper | `~/.open-design-skill/skill` | `https://github.com/sugarforever/open-design-skill.git` |
| Content repo | `~/.open-design-skill/repo` | `https://github.com/nexu-io/open-design.git` |

If `OPEN_DESIGN_ROOT` is set, that path is the content root instead of `~/.open-design-skill/repo`. Do not unset or overwrite the env var; clone or pull at the resolved path.

Skill directory name for agent wiring: `open-design` (matches the wrapper's `name` frontmatter).

## Prerequisites

- `git` on PATH
- Network access for clone/pull

## Install / update

1. Ensure `~/.open-design-skill/` exists.
2. **Skill wrapper**: if `skill/` is missing or not a git checkout of the source above, `git clone` into that path. If it is already a checkout, `git pull` (fast-forward preferred; on conflict, report and leave Fail for that item).
3. **Content repo**: same for the resolved content root (`OPEN_DESIGN_ROOT` or `repo/`).
4. Do not put credentials in the repository. Do not add project symlinks or project skill facades for Open Design.

## Optional user-local wiring

After home installs succeed, **ask the user** whether to wire user-local skills for Cursor, OpenCode, and/or Grok. Default if they decline: skip wiring; home install alone may still Pass.

When wiring is accepted, create or refresh a **symlink** (not a copy) from each chosen agent path to `~/.open-design-skill/skill`:

| Agent | User-local skill path |
|-------|------------------------|
| Cursor | `~/.cursor/skills/open-design` |
| OpenCode | `~/.config/opencode/skills/open-design` |
| Grok | `~/.grok/skills/open-design` |

If `$XDG_CONFIG_HOME` is set, OpenCode uses `$XDG_CONFIG_HOME/opencode/skills/open-design` instead.

**Never** create or update project paths (`.cursor/skills/`, `.opencode/skill/`, `.grok/skills/` in the repo) for this skill.

If a target path exists and is not a symlink to the home skill, ask before replacing; do not delete without confirmation.

## Verify

| Item | Check |
|------|--------|
| Skill wrapper | Directory is a git checkout; `SKILL.md` present; `scripts/` present; remote matches sugarforever source (or report drift) |
| Content repo | Resolved root exists; looks like Open Design (e.g. `design-systems/` or equivalent top-level layout the skill expects) |
| Update | `git pull` completed without leaving a dirty conflict for that checkout |
| Wiring (only if user accepted) | Each chosen path is a symlink resolving to `~/.open-design-skill/skill` |

## Pass / Fail

- **Pass**: skill wrapper and content root both verify; wiring verifies for every agent the user accepted (skipped agents do not fail the run).
- **Fail**: either home checkout missing/broken/conflicted, verify failed, or accepted wiring incomplete. Report what remains.

## Related

- Skill: `ensure-open-design-skill-setup`
- UX binding: [`.agents/specs/rules/ux/presentation.md`](../.agents/specs/rules/ux/presentation.md)
- Not this skill: [`dev-env-setup.md`](dev-env-setup.md), [`github-repo-setup.md`](github-repo-setup.md), [`mcp.md`](mcp.md)

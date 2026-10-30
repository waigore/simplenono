# AGENTS.md

Agent entrypoint for this repo. Keep this file short; put detail in `docs/`, `specs/`, and `.agents/`.

## Project

- **Purpose**: Simple nonogram (picross) puzzle game — local pack, free-order play, calm clinical grid
- **Language / engine**: Godot (version / GDScript vs C# TBD in Engine ADR) — see `specs/definition/definition.md`
- **Frameworks / tools**: GitHub Actions CI (Spec lint, PR hygiene, Code lint, Unit tests, Coverage); game tooling TBD after Engine ADR

## Quick start commands

- **Setup**: TBD — after Engine ADR / `ensure-dev-env-setup`
- **Run**: TBD — Godot editor / exported build
- **Test**: TBD — after unit-test CI setup
- **Build / export**: TBD — desktop + mobile Godot export presets

## Labels

Issue labels for categorization and agent orchestration. Source of truth: `.github/project-labels.yml`. Details: [`docs/labels.md`](docs/labels.md).

| Label | Meaning |
|-------|---------|
| `type:epic` | Broad orchestration epic |
| `type:task` | Concrete unit of agent work |
| `type:defect` | In-game or interface bug (not specs/docs/planning) |
| `status:*` | Workflow state (see [`docs/issues/workflow.md`](docs/issues/workflow.md)) |
| `priority:*` | Handling order: critical → high → normal (default; see [`docs/labels.md`](docs/labels.md)) |
| `no-automerge` | PR label: opt out of automatic squash-merge (user-requested only) |

Synced by `.github/workflows/sync-labels.yml` (push to `main` when label config changes, or `workflow_dispatch`). Add labels with the `create-project-label` skill.

## Issues

Epic / Task / Defect forms live in `.github/ISSUE_TEMPLATE/`. Agents create issues with the matching `create-project-*` skill (sub-issues + native blocked-by). Contract: [`docs/issues/`](docs/issues/). Status workflow: [`docs/issues/workflow.md`](docs/issues/workflow.md).

## Skills

Canonical skills and catalog: [`.agents/`](.agents/) ([README](.agents/README.md)). Authoring and native facades: [`docs/skills.md`](docs/skills.md). MCP setup (add / enable / test; no credentials in-repo): `setup-project-mcp` — [`docs/mcp.md`](docs/mcp.md).

Open Design (user-local, not in this repo): install/verify with `ensure-open-design-skill-setup` — wrapper `~/.open-design-skill/skill`, content `~/.open-design-skill/repo` (or `OPEN_DESIGN_ROOT`); optional symlinks under `~/.cursor/skills/open-design`, `~/.config/opencode/skills/open-design`, `~/.grok/skills/open-design`. Contract: [`docs/open-design-skill-setup.md`](docs/open-design-skill-setup.md).

## Key files and directories

- `AGENTS.md` — this file (agent orientation)
- [`.agents/`](.agents/) — ([README](.agents/README.md))
- [`.cursor/`](.cursor/) — ([README](.cursor/README.md))
- [`.opencode/`](.opencode/) — ([README](.opencode/README.md))
- [`.grok/`](.grok/) — ([README](.grok/README.md))
- [`.github/`](.github/) — ([README](.github/README.md))
- [`docs/`](docs/) — ([README](docs/README.md))
- [`specs/`](specs/) — ([README](specs/README.md))
- [`pocs/`](pocs/) — proofs of concept, kept apart from main code ([README](pocs/README.md)); product demo mode is main-tree + [`specs/design/demo.md`](specs/design/demo.md)
- [`agent-orc/`](agent-orc/) — skill-agent orchestrator daemon ([README](agent-orc/README.md)); config under [`.orc/`](.orc/)
- <!-- fill in: top-level dirs (e.g. src/, assets/, tests/) + their README.md -->

## Rules to live by

**Before any work, read [`.agents/rules.md`](.agents/rules.md)**: secondary rules for spec authoring, depth, and review; ADRs; playtesting; aesthetics and assets; technical design; concise docs; demo mode; and PoCs (specify first; explore on request).

- **Template setup and updates**: in a new repo from this template, run `ensure-project-setup` before any other work or PR ([`docs/github-repo-setup.md`](docs/github-repo-setup.md)). Pull upstream template changes with `sync-upstream-template`; never merge upstream by hand.
- **High-level requirements first**: before a downstream spec is captured, `capture-requirements` sets the blocking fields (pitch, essential qualities, scope, player objectives, platforms, engine, spec depth, and a performance target). Other placeholders may stay. Detail you have not picked yet waits in [`docs/requirements/`](docs/requirements/README.md) (notes, not specs). You choose the next spec file. A PoC is only when you ask to explore.
- **Small PRs only**: `main` is protected; changes land via PR only. When a change is done, branch (`<type>/<issue#>-<slug>`), push, and open a PR using the template; link issues with `Refs #n`, never `Closes`. Keep PRs focused and testable, under ~30 files; split if larger. PRs auto-merge on green; use draft while incomplete; apply `no-automerge` only if the user asks. Contract: [`docs/pull-requests.md`](docs/pull-requests.md).
- **Spec first**: main-tree code implements only what is in `specs/`. Specify that with `capture-requirements` before a PoC, unless you ask to explore a named uncertainty under `pocs/` ([`docs/pocs.md`](docs/pocs.md)). Undecided aspects are marked `TBD — <question>` in any spec ([rule](.agents/specs/rules/README.md#undecided-aspects-tbd)) and are not coded; resolve them with `audit-spec-tbd`.
- **SOLID code**: follow [`docs/solid.md`](docs/solid.md) (template-owned, all projects) and [`docs/coding-conventions.md`](docs/coding-conventions.md) (project-owned; extends SOLID, never contradicts it). Review with `review-code` (also run from `verify-project-issue` when a PR has code changes).

---

**Maintaining this file:** When forking or starting a project from this template, fill in every `<!-- fill in -->` with real project details once the specs they come from exist (purpose from the vision, engine from the definition). Keep "Rules to live by" at five rules; add any other rule to [`.agents/rules.md`](.agents/rules.md). Keep each section to a few lines; link out to `docs/`, `specs/`, or `.agents/` for anything longer.

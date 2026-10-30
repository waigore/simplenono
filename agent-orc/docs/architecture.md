# agent-orc architecture

## Layers

1. **CLI** (`cli.py`): argparse, config load, multi-select, asyncio entry.
2. **Supervisor** (`supervisor.py`): one asyncio task per parallel slot; stagger, gate, optional issue claim, pull, worktree, run, cooldown.
3. **Gate** (`gate.py`): optional subprocess; exit 0 to proceed.
4. **Assignment** (`assignment.py`): `{parallel_id}` / `{issue}` in the prompt, and the in-memory issue map.
5. **Worktree** (`worktree.py`): create/delete isolated checkouts; pull on orchestrator root.
6. **Crew bridge** (`crew/`): CrewAI Agent/Task/Crew + `ProviderCliTool`; default path invokes the tool directly (no LLM) so CLI cost is the agent run itself. Optional `use_crew_kickoff` for future LLM-driven use.
7. **Providers** (`providers/`): render configured argv templates.
8. **Messaging** (`messaging.py`): no-op `publish` / `subscribe` for later agent-to-agent hooks.
9. **Shutdown** (`shutdown.py`): SIGINT confirm, kill process groups, purge worktrees.
10. **github_gh** (`github_gh.py`): thin `gh` wrapper for e2e (not used by the daemon loop).

## Parallelism

Selected agents run concurrently. Each agent starts `parallel_run` loops (default **1**). Loops are staggered. Within one loop: at most one agent process. Gate misses never start a worktree or CLI.

When `parallel_run` is greater than 1 and `issues.command` is set, a loop claims the first free issue in the command's list order after the gate passes (shipped workflow agents list by priority, then type — defect, task, epic — then earlier wave, then number). One in-memory map covers the whole daemon, so an issue has at most one owner. The map is not saved. A claim miss uses the same backoff as a gate miss and does not count toward `-n`. Ownership is released when that run ends, including failure. A new process starts with an empty map.

`{parallel_id}` (stable slot number, from 1) and `{issue}` (`none` when unassigned) are filled in that run's prompt. Without `issues.command`, extra slots still run, with ids only. Cooldown and gate backoff apply separately to each slot.

## Extensibility

- New provider: add template under `providers:` in config (and optional module stub).
- New skill agent: add under `agents:` with prompt and optional gate.
- Future bus: replace no-ops in `messaging.py`; supervisor already publishes `skill.start` / `skill.end`.

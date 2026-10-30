# agent-orc config

## Files

| Path | Role |
|------|------|
| [`.orc/config.yaml`](../../.orc/config.yaml) | Template defaults (do not edit in child projects) |
| `.orc/config.local.yaml` | Child-owned deep-merge override (gitignored) |
| [`.orc/config.local.example.yaml`](../../.orc/config.local.example.yaml) | Example local overrides |

Load order: `config.yaml`, then deep-merge `config.local.yaml` if present. Nested maps merge; leaves in local win. After merge, every string leaf is expanded for environment placeholders (see below).

## Environment substitution

Any string leaf in the merged config may use `${VAR}` or `${VAR:-default}` (no bare `$VAR`). Expansion runs once after deep-merge, before parsing.

- Unset `${VAR}` with no `:-` default → config load fails with `ConfigError` naming the variable.
- `${VAR:-default}` uses `default` when the variable is unset.
- Literals need no environment variables.
- Provider tokens `{prompt}`, `{workdir}`, `{skill}` and agent prompt tokens `{parallel_id}`, `{issue}` are filled when a run starts. Env expansion leaves them unchanged.

Primary use case: provider `--model` strings (and other argv/path/prompt values) from the environment via `.orc/config.local.yaml`. Keep secrets and machine-specific values in the environment or local config, not in template `config.yaml`. See [`.orc/config.local.example.yaml`](../../.orc/config.local.example.yaml).

## Orchestrator keys

- `cooldown_seconds` (default **10**): pause after a real agent run. `0` skips the pause.
- `gate_backoff_initial_seconds` (optional): first gate-miss delay. Later misses double it. When the merged config omits it, it equals the merged `cooldown_seconds`. `0` stays `0` on every miss, so the cap does not apply and the gate runs again immediately.
- `gate_backoff_max_seconds` (default **60**): cap for that doubling.
- `stagger_seconds` (default **5**): delay between slot starts.
- `worktrees_dir` / `logs_dir`: relative to repo root.
- `pull_before_run` / `default_branch`: `git pull` before each worktree.

## Providers

Named command templates with `{prompt}`, `{workdir}`, `{skill}`. The orchestrator also sets process `cwd` to the worktree.

Shipped defaults (see [`.orc/config.yaml`](../../.orc/config.yaml)):

| Provider | Binary | Headless + workdir |
|----------|--------|--------------------|
| cursor | `cursor-agent` (not bare `agent` — that may be Grok) | `-p --force --trust --workspace {workdir} {prompt}` |
| grok | `grok` | `-p {prompt} --cwd {workdir} --always-approve` |
| opencode | `opencode` | `run --auto {prompt}` (workdir via process cwd; no `--dir` on local v2.x) |
| opencode-qwen38-max | `opencode` | `run --auto --model opencode-go/qwen3.8-max {prompt}` ([OpenCode Go](https://opencode.ai/docs/go/)) |
| opencode-deepseek-v41-flash | `opencode` | `run --auto --model opencode-go/deepseek-v4.1-flash {prompt}` |

Default agent→provider: planner → `opencode-qwen38-max`; refine → `grok`; verify → `opencode-deepseek-v41-flash`; others → `cursor`.

## Agents

Each entry: `skill`, `provider`, `enabled`, `prompt`, optional `gate.command`, optional `parallel_run`, optional `issues.command`, and optional timing. Each timing key falls back to the orchestrator value on its own:

| Key | Fallback |
|-----|----------|
| `cooldown_seconds` | `orchestrator.cooldown_seconds` |
| `gate_backoff_initial_seconds` | `orchestrator.gate_backoff_initial_seconds` |
| `gate_backoff_max_seconds` | `orchestrator.gate_backoff_max_seconds` |

Values are numbers `>= 0`. Setting one key does not change the others. The template omits `gate_backoff_initial_seconds` so a local `cooldown_seconds` override still moves the gate start with it. Set the initial key to keep them apart.

Shipped `project-planner-agent` sets `cooldown_seconds: 3600` (one hour after each run, success or failure). It has no gate, so gate backoff does not run. Other agents leave cooldown unset and use 10 seconds.

**Gate:** exit code **0** = pass (run agent); non-zero = miss. Omit `gate` → always pass. Stdout ignored.

**parallel_run:** integer **>= 1**. Omitted means **1** (one loop, no issue claim). Above 1, that many slots run. Each slot keeps its own cooldown and gate backoff. `-n` counts per slot.

**issues.command:** optional. Prints a JSON array of objects with `number`, the same shape as `gh issue list --json number`. Used only when `parallel_run` > 1. After the gate passes, the slot claims the **first free number in that list order** that no slot in this process owns (list order is the priority order). No free number is a claim miss: same backoff as a gate miss, no worktree, and it does not count toward `-n`. The map lives in memory for this process only. The prompt placeholders `{parallel_id}` and `{issue}` are always filled (`issue` is `none` when nothing was claimed). Shipped workflow agents (review, refine, implement, verify, accept) call [`.orc/scripts/list-status-issues.sh`](../../.orc/scripts/list-status-issues.sh) so candidates are ordered `priority:critical` → `priority:high` → normal/unlabeled, then defect → task → epic, then earlier `Wave N` milestone (no `Wave N` title after numbered waves), then by number; set `parallel_run` in `config.local.yaml` to turn claims on. Planner and babysit ship no issue list, so extra slots get ids only. That list is only a parallel lock. Agents discovering with `Assigned issue: none` still judge per [`docs/issues/workflow-dispatch.md`](../../docs/issues/workflow-dispatch.md) and may prefer an unblocker or foundational issue over type or wave.

Shipped workflow gates (open issues that include the status label):

```yaml
gate:
  command:
    - sh
    - -c
    - test "$(gh issue list --state open --label status:pending-review --limit 1 --json number)" != "[]"
```

`project-planner-agent` has no gate (always eligible).

`babysit-pr-agent` gates with [`.agents/skills/babysit-pr-agent/scripts/gate.sh`](../../.agents/skills/babysit-pr-agent/scripts/gate.sh) (exit 0 when a same-repo open PR is conflicted, behind, or failing checks, or when more than three have queued/in-progress checks). Provider: `cursor`.

## Child projects

Only add/edit `.orc/config.local.yaml`. Keep template `config.yaml` intact for upstream sync.

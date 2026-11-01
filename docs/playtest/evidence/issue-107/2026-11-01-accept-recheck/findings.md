# Findings — issue #107 re-check

Detail for the run in [`notes.md`](notes.md). Build `main@1e90d76`.

## Build under judgement is unchanged

`git diff --stat ed9e33b 1e90d76 -- game` is empty. The only commits since are
evidence-only (#122, for #106). The re-check therefore carried the prior
judgement forward instead of re-deriving it.

## Test surface re-run independently

In a clean detached worktree at `1e90d76`, after
`godot --headless --path game --import`:

```
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

→ **Scripts 3, Tests 33, Passing 33, Asserts 642, exit 0** (Godot 4.7.2).
Transcript: [`logs/gut-recheck.log`](logs/gut-recheck.log). `Scripts 3` and
`Tests 33` were checked explicitly, because GUT silently skips a test script
that fails to parse and still exits 0.

## No graphical surface appeared

`game/main.tscn` (`97b1042`, unchanged) is still a single bare `Node` and
remains the only non-addon scene. `game/presentation/` holds only `.gitkeep`.
Nothing draws clue lines, and there is no debug UI (`DBG.1`–`DBG.4`) or
telemetry (`TEL.1`–`TEL.5`).

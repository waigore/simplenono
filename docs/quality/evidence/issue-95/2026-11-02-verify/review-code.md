# Code review — issue #95

```markdown
## Code review: Fail

**Target:** PR #202 and PR #208 code diffs (merged as 71efe63, 94e6c55)

### Findings
- `[SRP]` `must-fix` — game/presentation/result.gd:121-122 + game/presentation/shell.gd:278-285. Two owners drive the same reveal clock: the screen's `_process` and the shell's `_process`. Both run per frame, halving the spec'd stage duration and bypassing the shell's pause guard. Split the timing to one owner.
- `[CONT]` `suggestion` — game/presentation/settings.gd:18,26-27. `COPY_TITLE`, `HINT_HAPTICS`, `HINT_MUTE` are never read; settings.tscn hardcodes the same strings. Remove the constants or make the scene read them.
- `[CONT]` `suggestion` — game/presentation/result.gd:26,60 vs game/presentation/result_reveal.gd:96. `_clock_running` duplicates `ResultReveal.is_morphing()` as a second source of truth for "morphing".

### Notes
- `Code lint`, `Unit tests`, and `Coverage` are green on both PRs (`gh pr checks 202`, `gh pr checks 208`).
- Tests: 215/215 pass, but the result clock tests call `_process` directly instead of crossing engine frames, so they do not exercise the duplicate clock or the pause guard in the real loop.
- Everything else follows the presentation-layer patterns: intent signals, shell routing, one `SessionFlags` source.
```

Finding detail and the real-frame probe: [`rationale.md`](rationale.md).

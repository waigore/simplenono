# Criteria — #127 accept

Checked against `main@1fa6659` in a clean detached worktree containing the merged deliverable `c864c6b` (PR #146). Tools were installed in a throwaway virtualenv at the pinned `gdtoolkit==4.5.0`, the same pin `Code lint` installs.

| # | Criterion | Verdict | How it was checked | Evidence |
|---|-----------|---------|--------------------|----------|
| 1 | `docs/coding-conventions.md` has no `<!-- fill in -->` placeholder in the Rules or Tooling tables; each rule has a permanent `CC-<n>` and a level | Pass | `grep -n 'fill in' docs/coding-conventions.md` returns nothing; `CC-1` and `CC-2` are both level `must` and name the gdlint/gdformat behaviour each covers; the Tooling table has three populated rows | `docs/coding-conventions.md` 26–31, 40–44 |
| 2a | The chosen command appears both in the Tooling table and as a step in `.github/workflows/code-lint.yml` | Pass | Tooling rows `gdformat --check game` and `gdlint game` appear as the `Format check` and `Lint` steps with the same text, after a `pip install "gdtoolkit==4.5.0"` matching the table's pin. The workflow comment binds the two files together | `.github/workflows/code-lint.yml` 27–37 |
| 2b | The `Code lint` check fails on a deliberate violation | Pass | Appended `func   BadName(  ):` to `game/play/attempt_state.gd`. `gdformat --check game` → `would reformat …`, **exit 1**; `gdlint game` → `Function name "BadName" is not valid (function-name)`, **exit 1**. Both steps are non-`continue-on-error`, so either exit fails the job. Reverted; tree clean again | `logs/violation-detected.log`, `logs/violation-reverted.log` |
| 3 | `Code lint` passes on the current tree after the formatting pass | Pass | `gdformat --check game` → `28 files would be left unchanged`, exit 0; `gdlint game` → `Success: no problems found`, exit 0. Run on the merge commit itself, so the claim is about what landed, not what was promised | `logs/tree-clean.log`, `logs/tool-versions.log` |
| 4 | `pocs/` is excluded from the check ([`docs/pocs.md`](../../../../../docs/pocs.md)) | Pass | `.gdlintrc` / `.gdformatrc` list `pocs` in `excluded_directories`. Proved positively: `pocs/` ships no `.gd` file, so `pocs/accept-probe/bad.gd` with the *same* violation was added; CI stayed green (`exit 0`) while `gdlint pocs/accept-probe` caught it (`exit 1`). Probe removed | `logs/pocs-excluded.log`, `.gdlintrc`, `.gdformatrc` |
| 5 | If no tool is chosen: `None — <reason>` tables, no dead step, ADR reason | N/A | A tool was chosen, so this branch does not apply. Recorded rather than dropped | ADR-0007 is `Accepted` |

## Supporting checks

- **ADR deliverable exists.** [`0007-gdscript-lint-format.md`](../../../../../specs/adr/decisions/0007-gdscript-lint-format.md) is `Accepted`, category Library, choosing gdtoolkit 4.5.0 (MIT) with rejected alternatives moved to `0007-gdscript-lint-format/non-functional.md`. Indexed in `adr.md` (Libraries row and the Decisions line) and in `traceability.md` (alignment and imposed-constraint rows).
- **Formatting pass was formatting only.** `git diff c864c6b^1 c864c6b -- game` shows signal declarations moved above `const`/`var` for gdlint's declaration-order rule and multi-line argument reflow for the 100-column limit. No expression, branch, or value changed. This matters because the gate keys on playable behaviour: the deliverable does not alter it.
- **Scope.** Steps run over `game` only — not `pocs/` or the repository root.

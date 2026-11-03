## Code review: Pass

**Target:** PR #316 (`16c8df9`, squash on `main`) — `game/play/attempt.gd`, `game/play/attempt_state.gd`, `game/records/pack.gd`, `game/presentation/shell.gd`, and the test updates.

### Findings

- `[CONT]` `suggestion` — `game/presentation/shell.gd:56` — `progress_path` is a public mutable test seam. It is documented and matches the existing scene-instantiation pattern, but a setter or an init parameter would keep the seam narrower.
- `[SRP]` `suggestion` — `game/play/attempt.gd:236-249` — `leave()` clears six fields inline. If more open-attempt fields are added, a small `_close()` helper would keep the S3 cleanup in one place.
- `[CONT]` `suggestion` — `game/presentation/shell.gd:145-147` — `leave_puzzle()` returns early on `_attempt == null`, but a solved attempt stays in `_attempt` until the result screen returns. The user-visible behavior matches `SEQ-leave` B2, but the stale reference is why the `solve-reset` harness step now fails; clearing it on solve/result-close would make the shell's state match its name.

### Notes

- `CTR-attempt` O6 is implemented in `Attempt.leave()` with the B1/B2/B3 branches, one `_commit()` path through `CTR-pack` O5, and E2 after the attempt is cleared. `AttemptState.commit` was removed, so the pack is the only writer.
- `CTR-pack` O5 `commit()` replaces the record and `user://progress.cfg` (G3) and refuses an unknown id (G2). The temp-file rename in `ProgressFile.save` keeps a failed write from truncating the previous file.
- `Shell` routes leave through O6, binds E2, and shows the gallery on E2; B2 keeps the current screen.
- Tests use temporary `user://` documents and remove them; the new `test_leave.gd` covers S2/S3/S4, B1/B2/B3, M1 file contents, and leave-then-reopen.
- CI: `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass. Local `gdformat --check game` and `gdlint game` are clean; GUT is 254/254.
- No cataloged assets changed; `review-asset` is N/A. No main-tree screen UI changed, so no mockup gate applies.

# Notes — issue #257 acceptance run

## What was judged

The four shipped rows of this slice at `main@fbde7ca` — `pack-098`, `pack-099`, `pack-100`, `pack-101` — through the
real shell on a graphical (Xvfb) run: gallery → puzzle → ready beat → marks → solve → result → gallery, plus the
cross-heavy board and the last-fill win. Protocols in scope and their outcomes are in
[`manifest.md`](manifest.md).

The rows' content is unchanged from PR #386's squash `5ac4894` to `fbde7ca`: `git diff 5ac4894 fbde7ca` lists no
`game/assets/puzzle-pictures/pack-098…101*` path, no catalog id of these eight entries, and the four `pack.json` rows
compare equal. This tree therefore plays exactly the delivered rows, even though later slices added their own.

## Blockers

None. No game or interface miss was found, so no defect is filed.

## Non-blocking marks

- **Look by measurement, not eyeball.** This session has no image input, so the K4 / `AES.P1` judgement rests on
  measurement and printed silhouettes (see `manifest.md`). A human look at the result screen of #098 remains open for
  the product owner.
- **Slice PR note is on PR #386, not this run.** Item 9 of the shared bar is satisfied there; this run only re-checks
  its claims against the committed files.
- **Host rendering.** The run used one Xvfb display with software OpenGL. Frame timings on this host are not
  comparable with the mid-range-phone targets in `specs/definition/quality.md`; no quality record was produced or
  cited from them.

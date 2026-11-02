## Code review: Pass

**Target:** PR #291 (deliverable `a5dd745`) — `.github/scripts/puzzle_derive.py`, `.github/scripts/tests/test_puzzle_derive.py`, `.github/scripts/tests/test_generate_pack.py`

### Findings

- none (`must-fix`: none; `suggestion`: none)

### Notes

- **Checks.** `Code lint` pass, `Unit tests` pass, `Coverage` pass (also `Spec lint`, `PR hygiene`, `Integration harness`). Local `python3 -m unittest discover -s .github/scripts/tests` → 110 tests OK.
- **SRP.** `puzzle_derive.py` is one offline authoring tool with one job — derive a pixel from a square and judge it. PNG codec (`read_png`/`unfilter`/`paeth`/`write_png`), the derive steps (`flatten_vignette`, `box_downsample`), the fill rule (`fills`, `runs`, `clues`), and the judge (`line_placements`, `propagate`, `count_solutions`, `judge`) are separated by lifetime and reason to change; no orchestration leak between them. `greppable` module docstring names its authority rows.
- **DIP/ISP.** No I/O beyond `pathlib` and the CLI; `read_png`/`write_png` take and return plain row lists, so the pipeline is testable without files. `PictureError` is the single failure type crossing the boundary, and `main` maps it to exit 1.
- **LSP/OCP.** `PictureError` subclasses `Exception` without narrowing; the derive step list is data (`steps` in `derive`), so adding a step does not change control flow.
- **Continuous fixed rules.** The threshold (`FILL_LUMA = 128.0`), band (`25–45`), and vignette constants (`EDGE_RING`, `EDGE_BAND`) are module constants used everywhere; nothing is tuned per image, matching the issue's fixed-criterion requirement.
- **CONV.** `docs/coding-conventions.md` CC-1/CC-2 cover GDScript only, so no `CONV` finding applies to a Python authoring script. No `CONT` finding: `puzzle_derive.py` follows the existing `.github/scripts` pattern (module docstring with usage, `argparse` subcommands, JSON on stdout, `python3 <script>` entry) used by `generate_pack.py` and `asset_manifest.py`.
- **Test coverage.** `test_puzzle_derive.py` (12 tests) covers the fill rule, BOX downsampling, vignette flattening, run-length clues, and judge outcomes; `test_generate_pack.py` was changed to a seeded fixture so it no longer reads the live catalog, which removes a real coupling.
- **Independent re-derivation** in the verify worktree reproduced all four committed pixels byte-identically (`cmp`, zero differing bytes) and re-judged each `verdict: pass`.

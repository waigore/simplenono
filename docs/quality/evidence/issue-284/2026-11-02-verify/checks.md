# Independent checks — issue #284, `9e1a275`

Run by `issue-workflow-verify-agent` (parallel id 1) on 2026-11-02, Godot 4.7.2 headless on Linux, on `main`
at `9e1a275` (the squash of PR #287). Nothing was modified besides this folder.

## Scope of this pass

The deliverable is the `J-settings` journey leg only: gallery → settings → one preference toggled → back to
the gallery, with the toggled value reading back on a re-open. The implementation comment's own caveat is
respected — screen rendering (`UI-settings` R/C), `NAV` routing, the haptics player (#191), and the
preferences store are not re-verified, because the diff does not touch them.

## Deliverables checked against the issue

| Deliverable | Result |
|-------------|--------|
| Journey path over shipped screens (`UI-gallery.C3` → `UI-settings`, `C1`/`C2` toggle, `C3` back) | present — `test_haptics_branch_*`, `test_mute_branch_*`, `test_back_returns_to_an_unchanged_gallery` drive the real controls |
| Automated coverage of both branches, one-flag mutation, read-back on re-open | present — four new tests; the one-flag assertions read both `SCH-preferences` flags |
| Evidence for `J-settings` US1.1/US1.2 under `docs/playtest/evidence/` | present — `issue-284/2026-11-02-implement/`: manifest, notes, probe, 9 screenshots, 3 logs |
| `J-settings` row in `specs/playtest/story-rows.md` names this task | present — `| `J-settings` | #284 | — |` |

## Unit tests

```sh
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

`246/246` passing across 20 scripts, 30 338 asserts — reproduces the implementor's count.

## Lint, format, specs

```sh
gdformat --check game   # 82 files would be left unchanged
gdlint game             # Success: no problems found
python3 .github/scripts/spec_lint.py   # 0 errors, 1 pre-existing glossary warning
```

## Integration harness

Five protocols in this folder — `app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset` — all `outcome=pass`
([`integration/results.md`](integration/results.md)).

## Mockup gate

`MC.settings-mobile`, `MC.settings-desktop`, and `MC.settings-journey` remain `approved` in
`specs/ux/mockups/catalog.md`. The deliverable changes no main-tree UI, so there is no drift to compare.

## Evidence reviewed, not re-run

The graphical probe (`probe/probe_journey_284.gd`, 27/27 checks, 9 screenshots) is the implementor's run; it
was read, not re-executed, because the headless suite already proves the same assertions through the same
controls and the screenshots corroborate them (`00` = `03` = `07` for the unchanged gallery). Graphical
acceptance of the look remains the acceptance step.

## Non-blocking notes

- The `ui-ack` harness protocol measures open/settings/back but has no toggle step, so I8's "settings toggle"
  wording is observed through the synchronous unit assertions rather than a harness probe — the same reading
  #95's passing run used. Not a gap this task introduces.

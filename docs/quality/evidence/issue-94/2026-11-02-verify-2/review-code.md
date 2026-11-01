# Code review — issue #94

## Code review: Pass

**Target:** PR #220 code diff, squash-merged as `fe8c109`, reviewed at `fe8c109`.
Sources: [`docs/solid.md`](../../../../../docs/solid.md),
[`docs/coding-conventions.md`](../../../../../docs/coding-conventions.md).

### Findings

- `[TEST]` `suggestion` — `game/test/integration/sampler.gd:136-143`,
  `game/test/integration/supervisor.gd:697`: the I1 row passes on
  `frame_time_meets_bar()`, the p95 over every window combined, while the observation names
  each window. A slow `gallery` window can be masked by a larger, faster `reveal` window.
  `window_frame_time_meets_bar()` exists but is unused; making I1 require every window to
  pass (and adding a sampler unit test for that rule) would make the printed per-window
  figures authoritative. The current run passes in every window, so this does not change
  the record.
- `[CONT]` `suggestion` — `game/test/integration/protocols/navigate.gd:16-19` and
  `game/test/integration/README.md:56-58` say the `gallery` window includes the `refresh()`
  on return. The return runs after `reveal-start`, so those frames are tagged `reveal`.
  Either move the `gallery` stop/start around the return or correct the comments; the
  frames are observed either way.
- `[CONT]` `suggestion` — `game/presentation/gallery.gd:30-32`: `PAGE_MARGIN := 16.0`
  restates `gallery.tscn`'s `Margin` value for the harness's fit check; reading the
  container's margin would keep one source.
- `[CONT]` `suggestion` — `game/test/integration/relaunch.gd:156` still calls the shell
  home a "gallery stand-in"; the gallery is the real home since #94.

### Notes

- `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `Spec lint`, and `PR hygiene`
  are green on PR #220 (`gh pr check 220`); the squashed commit is `fe8c109`.
- Structure and layering continue the existing patterns: the sampler owns per-window
  frames, the supervisor reduces rows, the gallery raises intents, `GalleryThumb` owns only
  drawing, and the tile exposes `picture_size()` / `picture_aspect()` seams for the tests.
- The new integration layout expectation is a reusable `size` / `columns` / `fills` shape
  rather than gallery-specific logic in the supervisor.
- No `pocs/` paths touched; no assets changed.

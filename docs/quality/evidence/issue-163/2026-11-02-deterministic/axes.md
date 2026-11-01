# Axes not selected — issue #163

The run scores only Applies deterministic axes whose outcome this deliverable can
move. The three selected rows are the same ones the previous run used, so the rerun
is directly comparable.

| Axis | Invariant | Why not selected |
|------|-----------|------------------|
| `frame-time` | I1 | Integration level and produced by the `paint` protocol; the seams add no timing, and the observed numbers stay #110's row. |
| `hitch-bound` | I2 | Same as `frame-time`; `paint-hitches.ndjson` is empty in this run but that is not this issue's outcome. |
| `time-to-playable` | I6 | Launch to the interactive gallery (#94), untouched. |
| `transition-latency` | I7 | Navigation in/out is #112 and #94/#95. |
| `response-delay` | I8 | Non-paint acknowledgements belong to #112 and the settings work (#95/#96). |
| `crash-free` | I9 | Open, solve, reset, and back are #109 and #112; this issue adds no player flow. |
| `resume-after-failure` | I10 | Kill/relaunch restore is #96. |
| Accessibility, localization | — | `quality.md` marks every such row N/A; an N/A axis is not scored. |

The `paint` run in `integration/` also reports I1, I2, and I9 rows. They are quoted
nowhere in the manifest because they belong to the issues that own those flows; the
run was made to observe I11 in one folder, beside its timing samples and telemetry.

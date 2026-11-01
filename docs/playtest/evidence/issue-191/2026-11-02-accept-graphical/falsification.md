# Falsification — issue #191

Both mutations were applied to the acceptance tree, run headless with the same probe, and
reverted.

- **Bed start removed** (`_audio.on_puzzle_open()` → `pass`) → 5 failures: bed player, bed
  playing, loop, bed under the sting, unmute restart; exit 1.
  [`logs/falsify-bed.log`](logs/falsify-bed.log)
- **F1 gate removed** in `haptics.gd` → "H1: F1 off suppresses the click"; exit 1.
  [`logs/falsify-haptics.log`](logs/falsify-haptics.log)

The restored tree passes again (79 checks, exit 0):
[`logs/probe-headless-restored.log`](logs/probe-headless-restored.log).

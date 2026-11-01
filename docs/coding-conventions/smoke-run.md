# Headless smoke run

Boot check for the project's start scene. Parent: [`../coding-conventions.md`](../coding-conventions.md).

[`.github/scripts/smoke_run.sh`](../../.github/scripts/smoke_run.sh) runs `godot --headless --path game` and passes on a clean startup: the engine's start banner, the process still up after a short settle, and no `SCRIPT ERROR:` or `ERROR:` line. The app does not quit by itself, so the bounded timeout is the success path, never a failure; an early exit fails.

A step in the `Unit tests` job of [`unit-tests.yml`](../../.github/workflows/unit-tests.yml). Overrides: `SMOKE_PROJECT_PATH`, `SMOKE_TIMEOUT_SECONDS` (banner wait, default 20), `SMOKE_SETTLE_SECONDS` (post-banner wait, default 2).

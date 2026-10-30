# Authoring rules: haptics

Read this before editing `specs/view/haptics.md`. Do not copy these rules into the spec.

Also read [view.md](view.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Vibration and force feedback the player feels. Platforms come from `specs/definition/definition.md`.

## Header

- **Platforms with haptics**: the definition's platforms that have haptic output. When there are none, write "None", mark the topic N/A in `traceability.md`, and delete the sections below.

## Sections

- **Haptic cues**: `H1`, `H2`, …. Columns: the event (cite the design or view ID), platforms, the pattern (intensity from 0 to 1, duration in milliseconds, repeats), and side (left, right, or both) when it conveys direction. A haptic cue never carries game information on its own.
- **Settings**: `S1`, `S2`, …. Columns: setting (such as haptics on or off, intensity), what it changes, choices or range, and default.
- **Experience intent**: what touch should add to the experience. Intent only. No ID.

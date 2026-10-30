# Authoring rules: experience

Read this before editing `specs/design/experience.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [quality.md](../quality.md).

The intended player experience across the game: pacing, feedback, and presentation intent. Intent only. No screen layouts, interface widgets, asset specs, or technology. Layouts and controls live under `specs/ux/`. Cameras, readability guarantees, comfort options, spatial audio, and haptics that realize this intent live under `specs/view/`.

Performance, load time, reliability, and observability targets stay in `specs/definition/quality.md`. Do not restate them here.

## Experience goals

One row per vision quality: the moment the player feels it, and links to the specs that produce it.

## Pacing

- **Session arc**: how a typical session opens, builds, and closes.
- **Rhythm**: how tension and release, effort and reward, alternate.
- **Durations**: expected length of a loop iteration, a stage, and a session.

Platform implications from the design profile (for example session length) show up here.

## Feedback principles

What the player must perceive when the game changes, and how strongly. State the requirement, not the implementation. Columns: event, what the player must understand, and priority (high, medium, or low).

## Sensory intent

Mood and style (keywords and contrasts), the role of sound and music in play, and clarity rules: what must always remain distinguishable. The concrete style that realizes this intent (palette, form, motion, interface and sound style) lives in `specs/aesthetics/`.

## Accessibility

When accessibility Applies in `specs/definition/quality.md`, state what the player must perceive or be able to do: channels (what stays understandable with one channel removed), timing and assists (pressure the player can ease, or "None"), and scale (text and audio scale, or "None"). A rule change is an option in `configuration.md`. No widgets and no input bindings.

When accessibility is N/A, write "N/A" and the same reason as the quality spec.

## Localization

When localization Applies, list the player-facing content that varies by locale. When it is N/A, write "N/A" and the same reason.

## Learning and mastery

How players learn rules through play, the order new ideas are introduced, and what separates a beginner from an expert.

## Experiences to avoid

Each entry names an experience to avoid and why.

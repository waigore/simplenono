# Authoring rules: sound style

Read this before editing `specs/aesthetics/sound.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md) and [ids.md](ids.md).

How the game sounds as a style: music, sound effects, voice, and mix. The role of sound in play and when music changes are design facts in `experience.md`. Where sounds sit in space and how the player hears them by position is `specs/view/audio.md`. Cite both; do not restate them.

Write "N/A — reason" in each section when the game has no sound.

## Header

- **Serves**: vision qualities, style pillars, and design or view specs.

## Sections

- **Music**: `M1`, `M2`, …. Columns: ID, context (a flow, stage, or "menus"; link the design spec), genre and instrumentation, tempo range in beats per minute, and mood. When music layers or changes in play, state the layers' style; the design states when they change.
- **Sound effects**: `X1`, `X2`, …. Columns: ID, category (interface, movement, impact, ability, ambience, pickup), character (synthesized, recorded, stylized, chiptune), and duration range. A sound that carries a feedback principle cites it.
- **Voice**: `V1`, `V2`, …. Columns: ID, speaker class (link characters), voice kind (none, vocalizations, invented language, full lines), and tone. When localization Applies and voice has lines, state which locales are voiced.
- **Mix**: `L1`, `L2`, …. Columns: ID, category, target loudness (such as integrated loudness in LUFS), and its relation to other categories (such as ducking under dialogue). No positional rules. Asset kind specifications, recipe post-process, and `review-asset` loudness checks cite these `L` rows; music, SFX, and voice rows feed kind `prompt_policy`. Do not name generation products here — tools live in `docs/asset-tools.md`.

## Splitting

If the file passes 500 words, move music to `sound/music.md`. Leave a summary and a link, and update `aesthetics.md`.

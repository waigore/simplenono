# Authoring rules: spatial audio

Read this before editing `specs/view/audio.md`. Do not copy these rules into the spec.

Also read [view.md](view.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Where sound sources are placed in the world and how the player hears them by position. Music, interface sounds, and the role of sound in play stay in `specs/design/experience.md` and `specs/ux/`. Sound style lives in `specs/aesthetics/sound.md`, and sound assets in `specs/assets/`. Asset lists do not belong here.

Write "N/A — reason" in each section when the game has no positional sound.

## Sections

- **Listener**: `L1`, `L2`, …. Where the player's ears are (the camera, the avatar, or a stated point between), which way they face, and any change by camera.
- **Spatial rules**: `R1`, `R2`, …. Distance falloff (full level within a stated distance in units, silent beyond a stated distance, and the curve between), left-right placement by angle, height, muffling when scenery is between source and listener, and pitch change with motion. Concrete values.
- **Positional cues**: `Q1`, `Q2`, …. Columns: the event (cite the design ID), the source position (link the character or entity), the audible range in units, and priority when many play at once. A cue that carries game information has a non-audio equivalent when accessibility Applies (cite the `PER.D` cue, haptic cue, or UX region).
- **Experience intent**: what the soundscape should make the player feel about the space. Intent only. No ID.

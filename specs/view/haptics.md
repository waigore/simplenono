# Haptics

Authoring rules: [`.agents/specs/rules/view/haptics.md`](../../.agents/specs/rules/view/haptics.md).

- **Serves**: Calm tactile grid — slight place click under visual/audio feedback ([`experience.md`](../design/experience.md)).
- **Platforms with haptics**: iOS, Android

## Haptic cues

| ID | Event | Platforms | Pattern | Side |
|----|-------|-----------|---------|------|
| H1 | Mark applied — fill or cross ([`experience.md`](../design/experience.md)) | iOS, Android | Intensity 0.25, duration 20 ms, once | both |

Clear/erase and desktop platforms have no haptic cue. H1 never carries game information alone.

## Settings

| ID | Setting | Changes | Choices or range | Default |
|----|---------|---------|------------------|---------|
| S1 | Haptics | Enables or disables H1 | on / off | on |

## Experience intent

A slight tactile click when placing a fill or cross. Quiet and clinical; visuals and soft mark ticks remain the primary channels.

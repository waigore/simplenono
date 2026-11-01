# Asset Access

Authoring rules: [`.agents/specs/rules/assets/access.md`](../../.agents/specs/rules/assets/access.md).

- **Serves**: Cool clinical look and snappy solve ([`vision.md`](../vision.md)); gallery / puzzle / result ([`ux.md`](../ux/ux.md)); hitch-bound during paint ([`quality.md`](../definition/quality.md)). Load-time budgets: TBD — what are the `time-to-playable` / `transition-latency` targets in quality?
- **Technical counterpart**: [`specs/technical/asset-access.md`](../technical/asset-access.md)

## Addressing

| ID | Rule |
|----|------|
| A1 | Code and data name an asset only by its asset ID, never by file path or handle. |
| A2 | An asset manifest generated from the catalog, never hand-edited, maps each asset ID to its files. The asset manifest main code uses lists only approved entries. |
| A3 | Unresolved asset ID (unknown, draft, or deprecated): in development, fail loudly so the miss is obvious; in a release build, the build fails—unresolved IDs must not ship ([`quality.md`](../definition/quality.md) hitch-bound / reliability intent). |

## Placement

| ID | Rule |
|----|------|
| P1 | The asset root holds only cataloged asset files and the engine's import sidecars. |
| P2 | Engine resources and build outputs live outside the asset root, are not cataloged, and are listed in the technical counterpart. |

## Load groups

| ID | Group | Members | Load point | Unload point | Serves |
|----|-------|---------|------------|--------------|--------|
| G1 | Core UI | `fonts`, `sfx` (planned kinds) | App start / first playable shell | Never unload in a session | Readable chrome and mark tick ([`ui-style.md`](../aesthetics/ui-style.md), [`sound.md`](../aesthetics/sound.md) X1); hitch-bound |
| G2 | Music | `music` (planned) | Gallery or puzzle opens; solve sting with result | Session end or mute bed only (SFX stay) | M1/M2 ([`sound.md`](../aesthetics/sound.md); [`settings.md`](../ux/screens/settings.md)) |
| G3 | Puzzle pictures | [`puzzle-pictures`](kinds/puzzle-pictures.md) generated and pixel | Generated picture as the thumbnail when ever-completed; both pictures on the result | Leave result / gallery tile not needing it | Gallery thumbnail and the two-stage win reveal ([`gallery.md`](../ux/screens/gallery.md), [`result.md`](../ux/screens/result.md), [`perception.md`](../view/perception.md) R5) |

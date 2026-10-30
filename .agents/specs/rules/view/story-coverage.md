# Authoring rules: view story coverage

Read this before writing view stories. Do not copy this table into `specs/view/story-coverage.md` or into a story file. That file only links here.

Also read [stories.md](stories.md) and [ids.md](ids.md).

Every element is proven, not only mentioned.

This file is the Full coverage level. A spec at Baseline or None follows [depth.md](../depth.md) instead. The `stories.md` index records each spec's level.

## Every element

Every element ID and every named item (camera actions) is proven by at least one scenario in the story file of the spec that defines it. Requirements below are cumulative. Any element with a numeric limit or threshold also needs scenarios at the boundary and on each side of it. Any element that varies by platform needs one scenario per platform that differs.

## Requirements by kind

| Element kind | Scenarios required |
|--------------|--------------------|
| Coordinate frame (`SPC.A`), units and scale (`SPC.U`) | An object placed at a stated position lies in the stated direction and at the stated distance from a reference object. A reference object measures its stated size. |
| Placement (`SPC.P`), object extent (`SPC.E`) | An object placed by the rule occupies its stated extent, anchor, and facing. |
| Layer and depth (`SPC.L`) | An object on a nearer layer is drawn over a farther one. A parallax layer moves by its stated factor of camera motion. |
| Bounds (`SPC.B`) | At the edge, the stated extent holds and the cited design rule applies. |
| Projection (`PRJ.P`) | An object of known size at a known distance or position occupies the stated fraction of the frame. |
| Visible area (`PRJ.V`), aspect and safe area (`PRJ.A`) | At each end of the supported aspect range, and outside it, the visible extent and safe area are as stated. |
| Pixel scale (`PRJ.X`) | At each stated resolution, the scale is the stated value. |
| Visibility limit (`PRJ.D`) | An object inside the limit is visible. An object beyond it is not. |
| Camera framing (`F`) | With the target inside the dead zone, the camera does not move. Outside it, the camera moves until the target is back inside. |
| Camera motion (`M`) | After the stated trigger, the camera reaches the stated position or angle within the stated time and tolerance. |
| Camera limit (`L`) | At the limit, the camera stops at the limit value. |
| Occlusion (`O`) | While the target is blocked, the stated response holds. When unblocked, the camera returns as stated. |
| Camera transition (`T`) | When the trigger holds, the target camera is in use within the stated duration, with the stated carry-over. When it does not, the camera is unchanged. |
| Camera effect (`E`) | The trigger produces the effect with the stated magnitude and duration. With the comfort option that disables it, no effect. |
| Player control (`P` on a camera) | Each allowed camera action produces its stated change in this camera. A disallowed action changes nothing. |
| Camera action (`CC.<name>`) | Its effect in each camera that allows it. No effect in a camera that does not. |
| Setting (`CC.S`, `HAP.S`), comfort option (`PER.M`) | Behavior at the default and at each choice, or at both ends of its range. |
| Physics motion (`PHY.M`) | The stated values at the stated times, and the cited design outcome still holds. |
| Collision (`PHY.K`) | Contact between the stated shapes produces the stated response. Shapes that never collide pass through. |
| Contact feel (`PHY.I`) | The trigger produces the stated feedback. |
| Readability (`PER.R`) | In each camera the rule names, the guarantee holds, including during transitions and effects. |
| Depth cue (`PER.D`) | The cue is present when its condition holds and absent when it does not. |
| Listener (`AUD.L`) | A source at a stated position relative to the listener is heard from the stated side at the stated level. |
| Spatial rule (`AUD.R`) | The stated level or effect at the stated distances or conditions. |
| Positional cue (`AUD.Q`) | The event produces the cue at the source's position. |
| Haptic cue (`HAP.H`) | The event produces the stated pattern on each platform with haptics. With haptics off, nothing. |

## Not covered

Sections without IDs (dimensionality, embodiment, sense of scale, experience intent, and similar) are judged during review and acceptance. Diagrams are checked against the spec during review.

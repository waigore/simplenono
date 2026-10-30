# Authoring rules: view element IDs

Read this before assigning or citing a view element ID. Do not copy these rules into `specs/view/ids.md` or into any other spec. That file only links here.

Also read [view.md](view.md).

Stable IDs let view stories, UX specs, and issues name a view behavior exactly.

Design IDs stay in [../design/ids.md](../design/ids.md) and UX IDs in [../ux/ids.md](../ux/ids.md). Cite them. Do not reuse their keys.

## Format

- **Spec key**: the prefix from the table below plus the file name without extension. `cameras/follow.md` → `CAM-follow`. Global specs use the fixed key in the table.
- **Element ID**: a section letter plus a number, unique within its spec, such as `F2`. Use it bare inside the same spec. Elsewhere, qualify it, such as `CAM-follow.F2`.
- **Named elements**: camera actions use the key plus the name, such as `CC.orbit`.
- **Story IDs**: `VS<n>` for a story and `VS<n>.<m>` for a scenario, qualified by the key of the view spec they prove, such as `CAM-follow.VS2.1`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it.
- When an element's meaning changes, keep its ID and update every story that proves it.
- Where order matters (priority, layers), list order is authoritative, not the ID number.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `spatial-model.md` | `SPC` | Coordinate frame `A`, Units and scale `U`, Placement `P`, Object extents `E`, Layers and depth `L`, Bounds `B` |
| `projection.md` | `PRJ` | Projections `P`, Visible area `V`, Aspect and safe area `A`, Pixel scale `X`, Visibility limits `D` |
| `cameras/` | `CAM-<name>` | Framing `F`, Motion `M`, Limits `L`, Occlusion `O`, Transitions `T`, Effects `E`, Player control `P` |
| `camera-controls.md` | `CC` | Camera actions by name, such as `CC.orbit`; Settings `S` |
| `physics.md` | `PHY` | Motion `M`, Collision `K`, Contact feel `I` |
| `perception.md` | `PER` | Readability `R`, Depth cues `D`, Comfort options `M` |
| `audio.md` | `AUD` | Listener `L`, Spatial rules `R`, Positional cues `Q` |
| `haptics.md` | `HAP` | Haptic cues `H`, Settings `S` |

Sections not listed (dimensionality, embodiment, purpose, sense of scale, experience intent, and similar) carry no IDs. View stories do not prove them.

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist. A diagram labels each drawn element with its ID.

# Authoring rules: aesthetics element IDs

Read this before assigning or citing an aesthetics element ID. Do not copy these rules into `specs/aesthetics/ids.md` or into any other spec. That file only links here.

Also read [aesthetics.md](aesthetics.md).

Stable IDs let asset specs, asset reviews, catalog records, and UX presentation name a style element exactly.

Design, view, and UX IDs stay in their folders. Cite them. Do not reuse their keys.

## Format

- **Spec key**: the fixed key in the table below.
- **Element ID**: a section letter plus a number, unique within its spec, such as `C4`. Use it bare inside the same spec. Elsewhere, qualify it, such as `PAL.C4`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it, including asset kind specs.
- When an element's meaning changes, keep its ID. Asset kind specs that cite it are re-checked, and approved assets that cite it are re-reviewed per `specs/assets/procedures.md`.
- Where order matters (pillar priority), list order is authoritative, not the ID number.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `aesthetics.md` | `AES` | Style pillars `P` |
| `palette.md` | `PAL` | Swatches `C`, Palette sets `S`, Color rules `K` |
| `form.md` | `FRM` | Shape language `S`, Proportions `P`, Silhouette `L`, Detail `D` |
| `surface.md` | `SRF` | Shading `S`, Outline `O`, Materials `M`, Light `L`, Effects `E` |
| `motion.md` | `MOT` | Animation principles `A`, Timing `T`, Effect motion `E` |
| `ui-style.md` | `UIS` | Typography `T`, Iconography `I`, Panels `F`, Color roles `C`, Interface motion `M` |
| `sound.md` | `SND` | Music `M`, Sound effects `X`, Voice `V`, Mix `L` |
| `references.md` | `REF` | Reference images `R` |

Sections not listed (medium, content limits, variation, experience intent, and similar) carry no IDs.

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist. A sheet labels each drawn element with its ID.

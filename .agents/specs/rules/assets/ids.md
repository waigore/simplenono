# Authoring rules: asset pipeline element IDs

Read this before assigning or citing an asset pipeline element ID or an asset ID. Do not copy these rules into `specs/assets/ids.md` or into any other spec. That file only links here.

Also read [assets.md](assets.md).

Stable IDs let tasks, reviews, catalog records, and code name a pipeline rule or an asset exactly.

Aesthetics, design, view, and UX IDs stay in their folders. Cite them. Do not reuse their keys. Asset IDs follow [catalog.md](catalog.md).

## Format

- **Spec key**: the prefix from the table below plus the file name without extension when under a folder. `kinds/character-sprites.md` → `AK-character-sprites`. Global specs use the fixed key in the table.
- **Element ID**: a section letter plus a number, unique within its spec, such as `R2`. Use it bare inside the same spec. Elsewhere, qualify it, such as `AK-character-sprites.R2`.
- **Named elements**: procedures use the key plus the name, such as `APR.generate`. Tool roles use `TL.<n>`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it, including catalog records.
- When a recipe's meaning changes, keep its ID. Approved assets made with it are re-reviewed per `APR.update`.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `tools.md` | `TL` | Tool roles by number, such as `TL.2` |
| `procedures.md` | `APR` | Procedures by name, such as `APR.import` |
| `catalog.md` | `CAT` | Fields `F`, Integrity `I` |
| `access.md` | `ACC` | Addressing `A`, Placement `P`, Load groups `G` |
| `kinds/` | `AK-<name>` | Coverage `V`, Specification `S`, Budgets `B`, Recipes `R`, Checks `K`, Style series `SS` |

Sections not listed (purpose, sources, lifecycle, access, consistency, naming, and similar) carry no IDs. A kind’s primary style series is `SS1` (qualified `AK-<name>.SS1`).

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist.

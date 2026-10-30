# Authoring rules: technical element IDs

Read this before assigning or citing a technical element ID. Do not copy these rules into `specs/technical/ids.md` or into any other spec. That file only links here.

Also read [technical.md](technical.md).

Stable IDs let contracts, sequences, issues, and code comments name a technical element exactly.

Design, view, and UX IDs stay in their folders. Cite them. Do not reuse their keys. ADR IDs stay as `ADR-NNNN`.

## Format

- **Spec key**: the prefix from the table below plus the file name without extension for unit folders. `components/input.md` → `CMP-input`. Global specs use the fixed key in the table.
- **Element ID**: a section letter plus a number, unique within its spec, such as `R2`. Use it bare inside the same spec. Elsewhere, qualify it, such as `CMP-input.R2`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it.
- When an element's meaning changes, keep its ID and update every sequence or contract that cites it.
- Where order matters (layer order, sequence steps), list order is authoritative, not the ID number.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `layers.md` | `LAY` | Layers `L`, Dependency rules `D` |
| `modules.md` | `MOD` | Modules `M`, Boundaries `B` |
| `components/` | `CMP-<name>` | Responsibilities `R`, Communication `C` |
| `contracts/` | `CTR-<name>` | Operations `O`, Events `E`, Guarantees `G` |
| `schemata/` | `SCH-<name>` | Fields `F`, Invariants `I`, Lifecycle `L` |
| `sequences/` | `SEQ-<name>` | Steps `S`, Branches `B` |
| `failures.md` | `FAIL` | Taxonomy `T`, Recovery `R`, Degraded modes `M` |
| `concurrency.md` | `CON` | Update loops `U`, Ownership `O`, Synchronization `S` |
| `persistence.md` | `SAV` | Durable vs ephemeral `D`, Save mapping `M`, Migration `G` |
| `configuration.md` | `CFG` | Sources `S`, Tables and tunables `T`, Binding `B` |
| `verification.md` | `VER` | Seams `S`, Invariants `I`, Harness expectations `H` |
| `asset-access.md` | `AST` | Resolution `R`, Engine resources `E`, Build outputs `O`, Load groups `G` |

Sections not listed (overview, purpose, Serves, Informed by, and similar) carry no IDs.

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist. A diagram labels each drawn element with its ID when the element has one.

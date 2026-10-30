# Authoring rules: UX element IDs

Read this before assigning or citing a UX element ID. Do not copy these rules into `specs/ux/ids.md` or into any other spec. That file only links here.

Also read [ux.md](ux.md).

Stable IDs let user stories and other specs name interface behavior exactly.

Design IDs stay in [../design/ids.md](../design/ids.md) and view IDs in [../view/ids.md](../view/ids.md). Cite them. Do not reuse their letters for a different meaning.

## Format

- **Spec key**: the prefix from the table below plus the file name without extension. `screens/main-menu.md` → `UI-main-menu`. Global specs use the fixed key in the table.
- **Element ID**: a section letter plus a number, unique within its spec, such as `C2`. Use it bare inside the same spec. Elsewhere, qualify it, such as `UI-main-menu.C2`.
- **Named elements**: exceptions and UI actions use the key plus the name, such as `EX.loading` and `IN.confirm`.
- **Story IDs**: `US<n>` for a story and `US<n>.<m>` for a scenario, qualified by the key of the UX spec they prove, such as `UI-main-menu.US2.1`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it.
- When an element's meaning changes, keep its ID and update every story that proves it.
- Where order matters (focus, journey steps), list order is authoritative, not the ID number.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `actors/` | `ACT-<name>` | Can operate `C`, Cannot operate `K` |
| `screens/` | `UI-<name>` | Regions `R`, Controls `C`, States `S` |
| `journeys/` | `J-<name>` | Steps `S`, Branches `B`, Entry and exit `N` |
| `navigation.md` | `NAV` | Transitions `T`, Entry and resume `N` |
| `exceptions.md` | `EX` | Exceptions by name, such as `EX.loading` |
| `controls.md` | `IN` | UI actions by name, such as `IN.confirm`; Bindings `B`; Focus `F` |

Sections not listed (job, goals, experience intent, copy, and similar) carry no IDs. User stories do not prove them. Copy is checked against the mockup during review.

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist. A screen state's mockup anchor is `state-default`, or `ex-<name>` for `EX.<name>`.

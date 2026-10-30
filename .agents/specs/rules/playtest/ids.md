# Authoring rules: playtest element IDs

Read this before assigning or citing a playtest element ID. Do not copy these rules into `specs/playtest/ids.md` or into any other spec. That file only links here.

Also read [playtest.md](playtest.md).

Stable IDs let protocols, tools, and evidence name playtest behavior exactly.

Design IDs stay in [../design/ids.md](../design/ids.md). UX IDs stay in [../ux/ids.md](../ux/ids.md). Cite them. Do not reuse their letters for a different meaning. View story IDs are never playtest targets.

## Format

- **Spec key**: the prefix from the table below plus the file name without extension when under a folder. `design/core-loop.md` → `PTD-core-loop`. Global specs use the fixed key in the table.
- **Element ID**: a section letter or fixed name plus a number, unique within its spec. Use it bare inside the same spec. Elsewhere, qualify it, such as `PTD-core-loop.S2`.
- **Tool IDs**: fixed names from [`tools.md`](tools.md): `DBG.<n>`, `TEL.<n>`, `SIT.<n>`.
- **Protocol IDs**: the protocol file's key is the protocol ID. Steps use `S<n>`. Pass and fail criteria use `P<n>` and `F<n>` when listed as separate rows.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it.
- When an element's meaning changes, keep its ID and update every protocol that uses it.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `tools.md` | `PT-tools` | Debug `DBG`, Telemetry `TEL`, Situational `SIT` (names as in the tools table) |
| `procedures.md` | `PT-proc` | Steps are ordered; no separate ID letters required beyond document order |
| `evidence.md` | `PT-ev` | Artifact kinds by name in the required-artifacts table |
| `coverage.md` | `PT-cov` | Critical entries `C` |
| `design/` | `PTD-<name>` | Steps `S`, Pass `P`, Fail `F`, Tools cited by `DBG`/`TEL`/`SIT` |
| `ux/` | `PTU-<name>` | Steps `S`, Pass `P`, Fail `F`, Tools cited by `DBG`/`TEL`/`SIT` |

Every section in this table gives each element an ID in this form when the section uses numbered rows. A qualified ID cited anywhere must exist. Cited design and UX story IDs must exist in those domains.

# Authoring rules: design element IDs

Read this before assigning or citing a design element ID. Do not copy these rules into `specs/design/ids.md` or into any other spec. That file only links here.

Also read [design.md](design.md).

Stable IDs let player stories, issues, and other specs name a behavior exactly.

## Format

- **Spec key**: the prefix from the table below plus the file name without extension. `features/movement.md` → `F-movement`. Global specs use the fixed key in the table.
- **Element ID**: a section letter plus a number, unique within its spec, such as `R3`. Use it bare inside the same spec. Elsewhere, qualify it with the spec key, such as `F-movement.R3`.
- **Story IDs**: `PS<n>` for a story and `PS<n>.<m>` for a scenario, qualified by the key of the design spec they prove, such as `F-movement.PS2.1`.

## Stability

- Never renumber or reuse an ID. A new element takes the next number after the highest ever used in that section.
- When an element is removed, delete it, leave the gap, and update every reference to it.
- When an element's meaning changes, keep its ID and update every story that proves it.
- Where order matters (priority, sequence), list order is authoritative, not the ID number.

## Keys and identified sections

| Spec | Key | Sections and their ID letters |
|------|-----|-------------------------------|
| `characters/` | `C-<name>` | Attributes `P`, Actions and abilities `A`, States `S`, Behavior `B`, Interactions `I` |
| `entities/` | `E-<name>` | Properties `P`, Lifecycle and states `S`, Interactions `I` |
| `loops/` | `L-<name>` | Steps `K`, Exits `E` |
| `features/` | `F-<name>` | Rules `R`, Interactions with other features `I`, Edge cases `X`, Difficulty and configuration effects `D` |
| `flows/` | `FL-<name>` | Phases `P`, Transitions `T`, Entry and exit `N`, Interruptions `U` |
| `stages/` | `ST-<name>` | Contents `C`, Objectives `O`, Stage rules `R`, Entry and exit `N`, Pacing beats `B` |
| `scenarios/` | `SC-<name>` | Walkthrough steps `W<walkthrough>.<step>`, such as `W2.3` |
| `sub-games/` | `SG-<name>` | Entry and exit `N`, Rules `R`, End conditions and rewards `O` |
| `game-state.md` | `GS` | Fields by name, such as `GS.health`; Global invariants `V`; Hidden and visible state `H`; Randomness and determinism `Q` |
| `configuration.md` | `CFG` | Modes, game options, and designer tunables by name, such as `CFG.permadeath`; Dependencies and restrictions `K` |
| `demo.md` | `DEMO` | Limitations `L`, Entry and exit `N` |
| `difficulty.md` | `DIF` | Rule adjustments `R`, Dynamic adjustment `Y`, Changing difficulty `C` |
| `progression.md` | `PRG` | Progression axes `A`, Unlocks `U`, Persistence `P`, Committing progress `M`, Failure consequences `F`, Completion `Z` |
| `end-conditions.md` | `END` | Conditions by their ID, such as `END.L1`; Precedence `P` |

Sections not listed (purpose, motivation, layout, experience intent, and similar) carry no IDs. They explain or motivate. Player stories do not prove them.

Every section in this table gives each element an ID in this form. A qualified ID cited anywhere must exist.

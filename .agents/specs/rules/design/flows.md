# Authoring rules: flow

Read this before editing `specs/design/flows/_template.md` or `specs/design/flows/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `flows/<kebab-name>.md`, one file per flow. Do not fill the template in place.

A flow is a sequence of game phases and the transitions between them: the overall game, a run, a match, a turn, or stage-to-stage progression. Phases are states of the game, not screens.

## Header

- **Scope**: game, session, run, match, turn, or other.
- **Parent flow**: a link, or "None".
- **Serves**: vision qualities and definition scope items.

## Sections

- **Overview**: one paragraph from start to finish.
- **Phases**: `P1`, `P2`, …. Columns: purpose, the verbs the player can do (name verbs that are explicitly unavailable), and a link to the stage, loop, sub-game, or child flow. Every phase is reachable. Every phase has an exit unless it ends the flow. Each listed verb is available. A verb named as unavailable does not change game state.
- **Transitions**: `T1`, `T2`, …. Columns: from, to, trigger, conditions, which game-state fields carry over or reset, and the experience intent. A phase that does not end the flow has a transition out.
- **Entry and exit**: `N1`, `N2`, …. How the flow starts and its starting state, and one entry per way it ends, linking `end-conditions.md`.
- **Interruptions**: `U1`, `U2`, …. What happens to game state if play is suspended, abandoned, or interrupted. Link `progression.md`.
- **Diagram**: optional. A mermaid `stateDiagram` of phases and transitions. The tables are authoritative. Delete the section when there is no diagram.

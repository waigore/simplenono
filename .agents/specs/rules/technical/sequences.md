# Authoring rules: sequence

Read this before editing `specs/technical/sequences/_template.md` or `specs/technical/sequences/<name>.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Copy the template to `sequences/<kebab-name>.md`, one file per sequence. Do not fill the template in place.

A sequence is an ordered interaction across components and contracts for one trigger.

## Header

- **Trigger**: event, input, tick, or lifecycle moment that starts the sequence.
- **Participants**: components involved, linked.
- **Contracts used**: contract links.
- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Steps**: `S1`, `S2`, …. From participant, to participant, via contract (or "internal"), action or message. Order in the table is the happy path.
- **Branches**: `B1`, `B2`, …. Condition, next step IDs, outcome. Write "None" when linear.
- **Postconditions**: what must be true when the sequence completes (success path).
- **Diagram**: required when there is branching or three or more participants. Mermaid sequence (or equivalent) in this file, or a linked artifact under `diagrams/`. Label steps with IDs.

## Splitting

If the file passes 500 words, move Branches to `sequences/<name>-branches.md` and leave a link.

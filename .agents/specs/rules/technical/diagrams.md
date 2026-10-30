# Authoring rules: technical diagrams

Read this before editing `specs/technical/diagrams/README.md` or any file under `specs/technical/diagrams/`. Do not copy these rules into the diagram.

Also read [technical.md](technical.md).

Diagrams clarify structure and flow stated in technical specs. When a diagram and its spec disagree, the spec wins and the diagram changes. HTML under `specs/technical/diagrams/` is exempt from the 500-word limit.

## Placement

- Prefer Mermaid (or equivalent) **in the owning Markdown** next to the prose it illustrates.
- Use `diagrams/` for larger or multi-view artifacts (HTML or linked `.md`). Index them from the owning spec and from `diagrams/README.md` when helpful.
- Every artifact under `diagrams/` is cited from an owning technical spec. Orphan diagrams are not allowed.

## When required

| Spec kind | Diagram required when |
|-----------|------------------------|
| `layers.md`, `modules.md` | More than a trivial two-node map |
| `components/` | Two or more communication peers |
| `sequences/` | Branching, or three or more participants |
| `schemata/` | Non-trivial relationships or state-machine lifecycle |
| `failures.md`, `concurrency.md`, `persistence.md` | Dense paths, ownership, or save graphs |
| `asset-access.md` | Overlapping load groups or a dense load flow |
| `contracts.md`, `configuration.md`, `verification.md` | Only when prose alone is hard to follow |

## What a diagram contains

- Shows only elements and relationships the owning spec states.
- Labels drawn elements with their technical element IDs when they have IDs.
- For HTML: one self-contained file; no required external scripts or fonts for the diagram to read.
- Title or heading names the owning spec.

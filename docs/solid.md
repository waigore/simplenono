# SOLID coding principles

Agents that write or change code follow these principles. They **complement** reuse-before-new-code and clean-coding workflow rules; they do not replace them.

This file is owned by the template and applies to every project made from it. Each project adds its own language and engine conventions in [`coding-conventions.md`](coding-conventions.md), which extends this file and never contradicts it.

Review a diff with the [`review-code`](../.agents/skills/review-code/SKILL.md) skill. Suggest structural refactors with [`suggest-code-refactors`](../.agents/skills/suggest-code-refactors/SKILL.md).

## Structure continuity

Match the existing module layout, naming, layering, and patterns unless SOLID or a project convention requires a change. Prefer extending current seams over inventing parallel structure. Precedence: SOLID, then project conventions, then continuity.

## Principles

### Single Responsibility (SRP)

One unit has one reason to change.

- Bad: A “save progress” routine that validates input, writes storage, and updates the display.
- Good: Separate validate, persist, and present — each changes for a different reason.

### Open/Closed (OCP)

Open for extension, closed for modification.

- Bad: Adding a new enemy type by editing a central switch that lists every type.
- Good: A new type plugs into an existing extension point; old types stay untouched.

### Liskov Substitution (LSP)

A substitute must honor the contract of what it replaces.

- Bad: A “special” variant that silently ignores an operation callers rely on.
- Good: Every variant fulfills the same promises; callers need no special cases.

### Interface Segregation (ISP)

Depend only on the capability you use.

- Bad: Forcing a simple reader to accept a wide “do everything” surface.
- Good: Narrow surfaces so callers take only what they need.

### Dependency Inversion (DIP)

Depend on abstractions, not concretions.

- Bad: Core rules import a specific file format and a vendor SDK.
- Good: Core rules depend on a port/contract; adapters implement it at the edge.

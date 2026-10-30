# Authoring rules: contract

Read this before editing `specs/technical/contracts/_template.md` or `specs/technical/contracts/<name>.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Copy the template to `contracts/<kebab-name>.md`, one file per contract. Do not fill the template in place.

A contract is a behavioral interface: operations, events, and guarantees between a provider and consumers. Describe function, not engine wiring.

## Header

- **Kind**: API, event bus, message, shared memory protocol, or other (one word plus a short phrase if needed).
- **Provider**: component that fulfills the contract.
- **Consumers**: components that use it, or "Any in layer X".
- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Operations**: `O1`, `O2`, …. Name, input shape, output or effect, when it may be called. Functional description; cite schemata by link.
- **Events**: `E1`, `E2`, …. Name, payload, when emitted, who may subscribe. Write "None" and delete unused rows when the contract has no events.
- **Guarantees**: `G1`, `G2`, …. Ordering, idempotence, atomicity, delivery, or timing promises.
- **Errors**: conditions and results; align with `failures.md` when that file Applies.
- **Diagram**: optional when the surface is small; required when operations and events together exceed a handful or have ordering constraints. Mermaid or link under `diagrams/`.

## Splitting

If the file passes 500 words, move Events to `contracts/<name>-events.md` and leave a link.

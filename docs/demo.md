# Product demo mode

A **demo** is a limited form of the **same** game: same architecture, specs, SOLID, tests, and code tree. What distinguishes it is application-level configuration that caps features or content (for example a turn limit or one track). Authority: [`specs/design/demo.md`](../specs/design/demo.md). Config values live in [`specs/design/configuration.md`](../specs/design/configuration.md).

Not a proof of concept. PoCs live under `pocs/` and follow [`pocs.md`](pocs.md).

## When Offering is undecided or not offered

If `demo.md` Offering is `TBD` or **not offered**, do not implement demo mode. The rest of that spec may stay TBD or N/A.

## When offered

- Implement demo mode in the **main tree** like any other feature (ordinary issue workflow). No separate `create-demo` skill.
- Limitations in `DEMO.L*` are enforced only via the cited `CFG.*` parameters—no parallel ruleset ([Parity](../specs/design/demo.md)).
- Same bars as full game: [`solid.md`](solid.md), [`coding-conventions.md`](coding-conventions.md), unit tests, `review-code`.
- Verification and acceptance follow the issue workflow against `demo.md` and the linked config.

## Entry and UX

Design states entry/exit in `DEMO.N1`. Screens and menus belong under `specs/ux/`.

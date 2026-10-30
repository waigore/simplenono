# Authoring rules: verification

Read this before editing `specs/technical/_templates/verification.md` or `specs/technical/verification.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Optional. Create only when test seams, assertable invariants, or harness expectations need a shared technical map. Copy `_templates/verification.md` to `verification.md`; do not fill the template in place.

This is not a test plan dump and not player stories. It names hooks and invariants implementers and verifiers can use. When `specs/playtest/tools.md` Must or cited Situational capabilities need seams, name those seams here and cite the playtest tool IDs (`DBG.*`, `TEL.*`, `SIT.*`).

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Seams**: `S1`, `S2`, …. Injection or observe point, purpose, how a test drives it.
- **Invariants to assert**: `I1`, `I2`, …. What must hold, level (unit, integration, smoke), when checked. Cite schema or contract IDs. Each automatable deterministic axis listed from `specs/definition/quality/rubrics.md` is cited by one invariant.
- **Harness expectations**: `H1`, `H2`, …. What the test harness or CI must provide (fakes, determinism, fixtures).
- **Diagram**: optional; add when seam topology is non-obvious.

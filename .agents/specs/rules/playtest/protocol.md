# Authoring rules: playtest protocol

Read this before editing a file under `specs/playtest/design/` or `specs/playtest/ux/` (except `_template.md`). Do not copy these rules into the spec.

Also read [playtest.md](playtest.md), [ids.md](ids.md), [tools.md](tools.md), [procedures.md](procedures.md), and [evidence.md](evidence.md).

One protocol per file. Copy that folder's `_template.md` to `<kebab-name>.md`, fill the copy, leave the template unchanged, and link it from the hub index.

## Header

- **Level**: Design (`design/`) or UX (`ux/`).
- **Cites**: design story/element IDs, or UX story/journey IDs. At least one. No view story IDs.
- **Tools**: Must tools assumed; list every Situational ID (`SIT.*`) required.
- **Spec key**: per [ids.md](ids.md) (`PTD-<name>` or `PTU-<name>`).

## Steps

Numbered `S1`, `S2`, …. Concrete enough that two agents would run the same actions. May cite `DBG.*` and player-facing controls by UX action ID.

## Pass and fail

- **Pass** (`P1`, …): observable outcomes that mean the cited stories hold in the build.
- **Fail** (`F1`, …): observable outcomes that mean they do not. Fails block acceptance per procedures unless a row is marked non-blocking (rare; say so explicitly).

## Evidence

State any protocol-specific screenshot or note requirements beyond [`evidence.md`](evidence.md). Otherwise write "Default evidence rules".

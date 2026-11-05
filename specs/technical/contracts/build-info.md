# Contract: Build info

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API (build-time data)
- **Provider**: The release build — `build_info.json` written by `.github/scripts/export_release.sh`
- **Consumers**: [`CMP-shell`](../components/shell.md)
- **Serves**: Main menu build stamp ([`screens/menu.md`](../../ux/screens/menu.md) R3)
- **Informed by**: [`screens/menu.md`](../../ux/screens/menu.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | product version | None | Returns the product version string | The main menu renders its stamp |
| O2 | short git SHA | None | Returns the short git SHA | The main menu renders its stamp |

Sources: the product version comes from `game/project.godot` `config/version`, with the export presets' `application/version` / `version/name` for platform metadata. The short git SHA comes from the CI-generated `build_info.json` written by `.github/scripts/export_release.sh` and read at runtime.

## Events

None.

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | Both values are fixed at build time and do not change while the app runs |
| G2 | Neither value is empty |
| G3 | The short SHA is 7–12 lowercase hex characters |

## Errors

| Condition | Result |
|-----------|--------|
| `build_info.json` is missing or unreadable at export | The export fails; a running build never returns an empty value (G2) |

## Diagram

N/A — two read-only operations with no ordering; no diagram needed.

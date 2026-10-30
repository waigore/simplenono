# Asset Catalog Fields

Authoring rules: [`.agents/specs/rules/assets/catalog.md`](../../../.agents/specs/rules/assets/catalog.md).

Part of [`catalog.md`](../catalog.md). Keys are the JSON keys of an entry file per **Format** there.

## Fields

| ID | Field | Key | Required | Meaning |
|----|-------|-----|----------|---------|
| `F1` | Asset ID | `id` | Always | UUID version 7, per **Asset IDs** in [`catalog.md`](../catalog.md) |
| `F2` | Kind spec | `kind_spec` | Always | `AK-<name>`; may be planned |
| `F3` | Coverage | `coverage` | Unless demo-only and person-supplied | List of `V` IDs this asset satisfies |
| `F4` | Serves | `serves` | Always | List of design, view, or UX IDs it depicts or sounds for |
| `F5` | State | `state` | Always | `draft`, `approved`, or `deprecated` |
| `F6` | Version | `version` | Always | Integer from 1, raised on every update |
| `F7` | Files | `files` | Always | List of paths relative to the asset root |
| `F8` | Source type | `source_type` | Always | `ai-generation`, `procedural-generation`, `third-party`, or `human-made` |
| `F9` | Tool role | `tool_role` | Agent-generated | `role` (`TL.<n>`) and `adr` (ADR ID, or `adr-free` per [`docs/asset-tools.md`](../../../docs/asset-tools.md)) |
| `F10` | Recipe | `recipe` | Agent-generated | `AK-<name>.R<n>` |
| `F11` | Generation record | `generation` | Generated | Structured object; shape in [`generation.md`](generation.md) |
| `F12` | License | `license` | Always | Third-party: source, license, attribution, proof. Generated: tool terms. Human-made: rights |
| `F13` | Review | `review` | Approved, unless exempt | `verdict`, `date`, `reviewer`, `report` |
| `F14` | Successor | `successor` | Deprecated, when replaced | Asset ID of the replacement |
| `F15` | Deprecation reason | `deprecation_reason` | Deprecated | Why it was retired |
| `F16` | Supplier | `supplier` | Person-supplied | The person who made or supplied it |
| `F17` | Review exemption | `exemption` | Exempt | `granted_by`, `date`, `reason` |
| `F18` | Handle | `handle` | Always | `<kind>/<name>`, per **Asset IDs** in [`catalog.md`](../catalog.md) |
| `F19` | Touch-ups | `touchups` | Touched up | Oldest first: `operation`, `tool`, `terms`, `date`, `reason`, `run_by`; `agreed_by` when person-supplied; `prompt`/`inputs`/`settings` when used. Never clears `series` |
| `F20` | History | `history` | After an update | `{ version, date, reason, generation, touchups_added }` before overwriting `generation` |
| `F21` | Guidance | `guidance` | Optional | Short non-binding note for later agents |

## Example

```json
{
  "id": "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e",
  "handle": "character-sprites/player-idle",
  "kind_spec": "AK-character-sprites",
  "serves": ["CH-player"],
  "state": "approved",
  "version": 1,
  "files": ["character-sprites/player-idle.png"],
  "source_type": "human-made",
  "license": {"grant": "All rights assigned to the project"},
  "supplier": "A. Artist",
  "exemption": {"granted_by": "A. Artist", "date": "2026-10-15", "reason": "Hand-drawn to the style sheet"}
}
```

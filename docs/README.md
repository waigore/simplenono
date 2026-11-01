# `docs/`

Project and process documentation (labels, issues, skills, repo setup). Product/technical specifications live in [`specs/`](../specs/).

## Concise docs

Every file under `docs/` must stay under **500 words**. If content would exceed that, split into multiple focused files and link between them. CI enforces this for Markdown (`word-limit` in [Spec lint](spec-lint.md)); run `python3 .github/scripts/spec_lint.py` locally.

## Index

| Path | Covers |
|------|--------|
| [asset-tools.md](asset-tools.md) | Asset tools index: bans, preference; Recraft, ElevenLabs, fal, Cheaper Inference, Poly Haven linked |
| [asset-tools-cheaperinference-steps.md](asset-tools-cheaperinference-steps.md) | Locked Cheaper Inference generate / reference-anchor steps + script |
| [asset-tools-polyhaven.md](asset-tools-polyhaven.md) | Poly Haven CC0 texture/model catalog (ADR-free REST) |
| [asset-tools-polyhaven-steps.md](asset-tools-polyhaven-steps.md) | Locked Poly Haven search / pick / download steps |
| [texture-pipeline.md](texture-pipeline.md) | Texture select → land → tile check → optional touch-up → review |
| [mcp.md](mcp.md) | Project MCP wiring for Cursor / OpenCode / Grok; auth rules; declared servers; smoke test |
| [coding-conventions.md](coding-conventions.md) | Project-owned coding conventions and lint/format/unit-test/coverage tooling; extends `solid.md` |
| [demo.md](demo.md) | Product demo mode: config-bounded slice of the main game; `specs/design/demo.md` |
| [pocs.md](pocs.md) | Proofs of concept under `pocs/`: requests, scope, relaxed bars, optional promotion |
| [poc-promotion.md](poc-promotion.md) | Optional PoC reconcile act; keep/drop/adapt; reimplementation |
| [poc-style-assets.md](poc-style-assets.md) | Style and asset gate when a PoC shows or plays them |
| [dev-env-setup.md](dev-env-setup.md) | Local game-stack and asset-tool install/verify; then `setup-unit-test-ci` |
| [open-design-skill-setup.md](open-design-skill-setup.md) | User-local Open Design skill + content under `~/.open-design-skill/`; optional agent wiring |
| [ux-mockups.md](ux-mockups.md) | Mockup catalog approval; main-tree UI gate; verification and PoC promotion |
| [github-repo-setup.md](github-repo-setup.md) | First-time GitHub settings to apply and verify (remotes, Actions, `main` ruleset, squash, auto-merge, labels) |
| [github-repo-setup-examples.md](github-repo-setup-examples.md) | Non-binding example commands for the setup |
| [issues/](issues/) | Epic / Task / Defect contract and status workflow |
| [labels.md](labels.md) | Label catalog and sync |
| [pull-requests.md](pull-requests.md) | PR flow, branch names, body contract, auto-merge holds |
| [requirements/](requirements/README.md) | Unconfirmed requirement notes awaiting capture into specs (not specs) |
| [playtest/evidence/](playtest/evidence/) | AI-agent playtest evidence (story IDs, pass/fail, screenshots, notes, logs); requirements in `specs/playtest/` |
| [playtest/debug-seams.md](playtest/debug-seams.md) | How a playtest run drives S1–S5: the one flag, commands, keys, telemetry log lines |
| [quality/evidence/](quality/evidence/) | Quality-evaluator evidence: per-axis pass, fail, or blocked for deterministic verification and llm-judge acceptance |
| [skills.md](skills.md) | Skill authoring and native wiring |
| [../agent-orc/](../agent-orc/) | agent-orc daemon: spin up workflow skill agents ([usage](../agent-orc/docs/usage.md)) |
| [solid.md](solid.md) | SOLID principles + structure continuity for agents; owned by the template |
| [spec-lint.md](spec-lint.md) | CI checks for spec structure (rules line, templates, links, glossaries) |

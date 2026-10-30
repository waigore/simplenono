# `specs/`

Product and technical specifications: what to build. Process docs live in [`docs/`](../docs/).

If it is not in `specs/`, it must not be in the code. Do not read [`adr/archive/`](adr/archive/README.md) unless explicitly asked.

## Concise specs

Every Markdown file under `specs/` stays under **500 words**; split and link if longer. CI enforces this (`word-limit` in [Spec lint](../docs/spec-lint.md)). HTML mockups and diagrams are exempt.

## Authoring

Read the matching rules file in [`.agents/specs/rules/`](../.agents/specs/rules/README.md) before editing a spec (`author-spec` skill). Reviews follow [`.agents/specs/alignment.md`](../.agents/specs/alignment.md). CI checks the mechanical rules ([`docs/spec-lint.md`](../docs/spec-lint.md)).

## Index

Add a row for each new spec file. Each hub indexes its own unit specs; its rules file says what it contains.

| Spec | Covers | Review instructions |
|------|--------|---------------------|
| [`vision.md`](vision.md) | Pitch, audience, qualities, non-goals | [`vision-review.md`](../.agents/specs/vision-review.md) |
| [`definition/definition.md`](definition/definition.md) | Scope, objectives, platforms, constraints, spec depth | [`definition-review.md`](../.agents/specs/definition-review.md) |
| [`definition/quality.md`](definition/quality.md) | Non-functional requirements | [`definition-review.md`](../.agents/specs/definition-review.md) |
| [`definition/quality/rubrics.md`](definition/quality/rubrics.md) | Rubric axes and evaluators for those characteristics | [`definition-review.md`](../.agents/specs/definition-review.md) |
| [`definition/quality/rubrics/baseline.md`](definition/quality/rubrics/baseline.md) | Fixed baseline axes | [`definition-review.md`](../.agents/specs/definition-review.md) |
| [`design/design.md`](design/design.md) | Game design hub | [`design-review.md`](../.agents/specs/design-review.md) |
| [`view/view.md`](view/view.md) | View hub: camera, projection, feel | [`view-review.md`](../.agents/specs/view-review.md) |
| [`aesthetics/aesthetics.md`](aesthetics/aesthetics.md) | Aesthetics hub: medium, style pillars, palette, form, motion, interface and sound style | [`aesthetics-review.md`](../.agents/specs/aesthetics-review.md) |
| [`ux/ux.md`](ux/ux.md) | UX hub: screens, navigation, input, mockups | [`ux-review.md`](../.agents/specs/ux-review.md) |
| [`playtest/playtest.md`](playtest/playtest.md) | AI-agent playtesting and acceptance evidence | [`playtest-review.md`](../.agents/specs/playtest-review.md) |
| [`assets/assets.md`](assets/assets.md) | Asset pipeline: kinds, tool roles, procedures, catalog | [`assets-review.md`](../.agents/specs/assets-review.md) |
| [`adr/adr.md`](adr/adr.md) | Architecture decision records | [`adr-review.md`](../.agents/specs/adr-review.md) |
| [`technical/technical.md`](technical/technical.md) | Technical design hub | [`technical-review.md`](../.agents/specs/technical-review.md) |

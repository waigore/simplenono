# Updating terminology audit references

How to keep [`glossary-ownership.md`](glossary-ownership.md) and [`risk-lexicon.md`](risk-lexicon.md) accurate. Edit these files only under `.agents/skills/audit-spec-terminology/references/`. Do not copy them into `specs/`.

## When to update

| Trigger | Update |
|---------|--------|
| Glossary authoring rules change in [`.agents/specs/rules/`](../../../specs/rules/) (`*/glossary.md` or hub "Shared language") | `glossary-ownership.md` |
| Skeleton required rows change in those rules | Ownership **Skeleton rows** table |
| A `review-spec` or terminology audit finds a recurring collision not listed | Add a row to `risk-lexicon.md` |
| A lexicon word never produces findings and is noise | Remove or narrow its "Typical colliding senses" |
| A new spec hub with its own glossary appears | Ownership table + skill seed list |

Do **not** update references while running an audit (audits are read-only). Update in a separate change, then re-run the audit.

## How to update glossary ownership

1. Open the six glossary rules files: design, view, aesthetics, UX, assets, technical under `.agents/specs/rules/`.
2. Sync the **Owns** / **Must not redefine** columns with those rules (and hub "Shared language" bullets).
3. Sync **Skeleton rows** with any "The skeleton already defines…" lists. If design gains a fixed list, add it.
4. Confirm glossary paths still match `specs/<hub>/glossary.md` and the split convention in the rules.
5. Keep the file under 500 words. Do not paste full rules text.

Source of truth for ownership is always the rules files, not this reference.

## How to update the risk lexicon

1. Add a word only when it has collided (or clearly will) across at least two domains, or between a glossary sense and ordinary technical English.
2. One row per word. **Typical colliding senses** is a short hint for the auditor, not a glossary definition.
3. Do not require every lexicon word to appear in a glossary. Absence alone is not a finding.
4. Prefer game-dev collisions (level, screen, state, …) over generic English.
5. Keep alphabetical order by **Word**. Stay under 500 words; if longer, split into `risk-lexicon/<domain>.md` and leave this file as an index.

## Checklist after editing

- [ ] Links from [`SKILL.md`](../SKILL.md) still resolve.
- [ ] No new finding tags invented here (tags live only in the skill).
- [ ] Facades unchanged (they do not duplicate reference content).
- [ ] Spot-check: run `audit-spec-terminology` on one added lexicon word or one ownership change.

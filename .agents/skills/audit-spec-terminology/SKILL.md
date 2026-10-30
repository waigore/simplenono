---
name: audit-spec-terminology
description: |-
  Audit glossary ownership and term usage across the spec set: find undefined
  terms, cross-domain redefinitions, sense drift, synonyms, and homonym risks.
  Use when glossaries change, after design/view/UX/technical authoring, or before
  a whole-spec review. Read-only; report mismatches for author-spec.

  Examples:
    - user: "Audit the term level" → usages vs owning glossary
    - user: "Terminology audit for UX" → UX glossary + UI usages
    - user: "Terminology audit for the whole spec" → all glossaries + risk lexicon
---

# Audit spec terminology

Read-only audit of **shared language** across design, view, aesthetics, UX, asset pipeline, and technical specs. Fixes go through [`author-spec`](../author-spec/SKILL.md). Full checklist review is [`review-spec`](../review-spec/SKILL.md), which runs this audit on whole-spec review. Applicability (Applies/N/A) is [`audit-spec-applicability`](../audit-spec-applicability/SKILL.md).

**Ownership:** [`references/glossary-ownership.md`](references/glossary-ownership.md). **Risk words:** [`references/risk-lexicon.md`](references/risk-lexicon.md). **Maintaining those files:** [`references/README.md`](references/README.md).

## Steps

1. **Resolve the seed**:
   - **One term** (e.g. level, session, state).
   - **One domain** (design, view, aesthetics, UX, assets, or technical): that glossary plus specs under that hub.
   - **Whole set**: every glossary entry, then every word in the risk lexicon.
2. **Load ownership**: read [`glossary-ownership.md`](references/glossary-ownership.md). Open only the glossaries and hubs that apply to the seed.
3. **Collect candidates**:
   - Seed term → that word only.
   - Domain → every row in that domain's glossary (and splits), plus risk-lexicon words that collide with that domain.
   - Whole set → all glossary rows across the six hubs, then risk-lexicon words not already covered.
4. **Compare usages**: for each candidate, sample definitions and in-spec usages across domains. Match against the owning glossary sense. Cap sampling: prefer glossary files, hub indexes, and files that already use the term; do not thesaurus-expand.
5. **Report** using the shape below, then close per [`../audit-spec-applicability/references/report-back.md`](../audit-spec-applicability/references/report-back.md). If the requester wants fixes, point them at `author-spec`.

## Finding tags

| Tag | Meaning |
|-----|---------|
| `undefined` | Used as a term of art, not in any glossary |
| `cross-domain redefine` | Same word defined in two glossaries (or redefined outside the owner) |
| `sense drift` | One glossary sense; usages imply another |
| `synonym pair` | Two words for one concept |
| `homonym risk` | Same spelling, different legitimate senses, not disambiguated by domain or qualifier |
| `orphan entry` | In a glossary, unused in that domain's specs |

## Report shape

```markdown
**Terminology audit: Pass | Fail**

Seed: <term | domain | whole set>

Findings:
- <tag> — <term> — <where A vs where B> — <suggested fix for author-spec>

Notes (optional): <non-blocking observations>
```

Do not tag an unfilled glossary row `undefined` or `orphan entry`.

## Rules

- Close per [`../audit-spec-applicability/references/report-back.md`](../audit-spec-applicability/references/report-back.md).
- Do not fail ordinary English used once in prose. Fail terms of art, repeated domain nouns, and risk-lexicon hits.
- Homonyms across domains are OK when each sense lives in the right glossary and usages stay in-domain or use a qualifier (e.g. "UI screen" vs playfield).
- Do not invent finding tags beyond the table above.

# Spec lint

CI check ([`spec-lint.yml`](../.github/workflows/spec-lint.yml)) that enforces the mechanical parts of the spec authoring rules and the docs/specs word limit. Judgment calls stay with the `review-spec` skill.

Run locally:

```bash
python3 .github/scripts/spec_lint.py            # lint specs/ and docs/
python3 -m unittest discover -s .github/scripts/tests   # test the linter
```

Errors fail the check. Warnings are printed but pass; add `--strict` to fail on them too.

## Checks

| Check | Fails when |
|-------|------------|
| `rules-line` | A spec has no `Authoring rules:` line, or it links a file other than the one the path table in [`.agents/specs/rules/README.md`](../.agents/specs/rules/README.md) assigns. Split files and story files follow that table's most-specific-path rule. |
| `template-copy` | A copy keeps the `<!-- Template: … -->` comment, a file or directory name is not kebab-case, or a `_template` file holds content: a section, table row, or paragraph with no placeholder left. |
| `skeleton` | A copy is missing a `##` heading from its template, or has it out of order. Headings marked `(optional)` or holding a placeholder are skipped. Mark an unused section N/A instead of deleting it. |
| `bare-na` | A table cell or `- **Field**:` value is just `N/A`. Write `N/A — reason`. |
| `bare-tbd` | `TBD` appears without an open question. Write `TBD — question` ([rule](../.agents/specs/rules/README.md#undecided-aspects-tbd)). |
| `links` | A relative link in `specs/`, `docs/`, or `.agents/` points at a missing file. |
| `orphans` | A spec or mockup is linked from no other spec. A link to a folder counts for its `README.md`. |
| `glossary` | A glossary term repeats in the same file or breaks alphabetical order. A term defined in two glossaries is a warning. |
| `word-limit` | A Markdown file in `docs/` or `specs/` exceeds 500 words, counted like `wc -w` on the raw file. Split it and link. |

## Asset catalog

The same workflow runs [`asset_catalog.py`](../.github/scripts/asset_catalog.py) (`python3 .github/scripts/asset_catalog.py` locally). It checks the catalog's entry files against the default format and integrity rules in [`specs/assets/catalog.md`](../specs/assets/catalog.md): asset IDs, handles, required fields, approval and exemptions, successors, and that every file under the asset root belongs to one entry. It is skipped until the asset hub sets a catalog root.

## Adding a check

Add a function to [`spec_lint.py`](../.github/scripts/spec_lint.py) that returns findings, register it in `CHECKS`, add a row here, and add a test that injects the violation in [`tests/`](../.github/scripts/tests/).

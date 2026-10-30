# Rules and review alignment

How authoring rules in [`.agents/specs/rules/`](rules/README.md) relate to the review checklists in this directory. `author-spec` and `review-spec` follow this file.

## File-level requirements

These apply to every spec. They are aligned requirements even though each rules file does not repeat them.

- The spec links its authoring-rules file from [rules/README.md](rules/README.md). A split file uses the rules file of the spec it came from. HTML mockups and HTML under `specs/view/diagrams/` or `specs/technical/diagrams/` do not carry this link.
- The rules text is not pasted into the spec. The authoring-rules link is not game or interface content.
- A formalized section has no `<!-- fill in -->` placeholder. A section whose body is still only placeholders is not formalized: skip its checks and do not fail the file for it. A file with no formalized section is not formalized: report it as not formalized, not as Fail. Unused rows and sections the rules file says to delete are deleted when that section is formalized.
- An undecided aspect in a formalized section reads `TBD — <open question>` per [rules/README.md](rules/README.md). A reviewer reports each such TBD as a failed aligned check tagged `needs clarification` and does not choose an outcome. Placeholders are not TBDs.
- Each Markdown file under `specs/` stays under 500 words. HTML mockups and HTML diagrams under `view/diagrams/` and `technical/diagrams/` are exempt. Split the way the rules file says.

## Aligned checks

Aligned checks are the sections and the required content. For each document type they match that type's rules file: same sections, same things each section must contain. Checklist wording is the check form of the rule.

A section or a required field that exists only in the rules file, or only in the checklist, is a defect in `.agents`. Fix both files together. A reviewer does not invent a section or a required field during a review.

## Imposed conditions

Imposed conditions are listed only in the checklist, under **Imposed**. They are judgments the rules do not spell out. A reviewer may fail the spec on one. The finding may ask for a clearer statement inside a section the rules already require. It must not add a section or a required field.

If a checklist has no imposed conditions, the reviewer does not invent one.

## Review findings

Tag every failed check `aligned` or `imposed`. If the check cannot be judged without product-owner input, also tag it `needs clarification`.

## Refinement

Refinement edits the spec after a failed spec review. It is not the GitHub issue refine workflow.

- **Aligned:** change the spec so it meets the rules. If the rules require an outcome and the spec does not already imply one, do not invent it. Mark that point TBD and report it as `needs clarification`.
- **Imposed:** apply the suggested fix, unless it materially challenges the project scope, the definition, or the design. Then do not change the spec on that point. Report the finding and leave it.
- **Needs clarification:** do not choose an outcome. Mark the point TBD if it is not already, and report the finding.
- Do not paste authoring rules into the spec.

Material means the edit would change what the game includes or excludes, a definition objective, platform, constraint, or quality target, or what happens in play. Stating an outcome the spec already implies is not material.

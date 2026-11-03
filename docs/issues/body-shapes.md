# Canonical issue body shapes

Skills and forms emit these bodies. Fill every required section; use `None` / `none` where shown when empty. Requirements: [requirements.md](requirements.md). Feedback rules: [feedback.md](feedback.md). Index: [README.md](README.md).

## Epic (`type:epic`)

| Section | Required | Content |
|---------|----------|---------|
| `## Goal / outcome` | yes | What "done" looks like |
| `## Scope` | yes | In scope and explicitly out of scope |
| `## Notes` | no | Design notes, constraints, relevant specs |

```markdown
## Goal / outcome
<goal>

## Scope
### In scope
-

### Out of scope
-

## Notes
<notes or None>
```

## Task (`type:task`)

| Section | Required | Content |
|---------|----------|---------|
| `## Description` | yes | What needs to be done |
| `## Deliverables` | yes | Files/areas to change — as specific as possible |
| `## Acceptance criteria` | yes | Clear, testable done conditions; follow [requirements.md](requirements.md) (no “`none` must link a defect” story-row ACs) |
| `## Parent` | no | `#N` of parent epic or task, or `None` |

```markdown
## Description
<description>

## Deliverables
- <path or area> — <what changes>

## Acceptance criteria
- [ ] <testable criterion>

## Parent
<#n or None>
```

## Defect (`type:defect`)

| Section | Required | Content |
|---------|----------|---------|
| `## Description` | yes | Problem — as specific as possible |
| `## Reproduction steps` | no | Steps to reproduce |
| `## Expected behavior` | yes | What should happen |
| `## Actual behavior` | yes | What happens instead |
| `## Additional context` | no | Platform, build, screenshots, logs, config |
| `## Related tasks or defects` | no | Related issue numbers/links |

```markdown
## Description
<description>

## Reproduction steps
1.
2.
3.
(or None)

## Expected behavior
<expected>

## Actual behavior
<actual>

## Additional context
<context or None>

## Related tasks or defects
<#n, … or None>
```

## Feedback (`type:feedback`)

| Section | Required | Content |
|---------|----------|---------|
| `## Points` | yes | One bullet per distinct piece of feedback |
| `## Analysis` | yes | One bullet per point: text, disposition, `#N` or `None` |
| `## Related issues` | yes | `#N` list of open or newly filed work, or `None` |
| `## Notes` | no | Raw feedback and source context |

```markdown
## Points
-

## Analysis
- <point> — <disposition> — <#N or None>

## Related issues
<#N, … or None>

## Notes
<notes or None>
```


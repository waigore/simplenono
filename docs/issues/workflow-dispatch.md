# Background dispatch agents

Automation entrypoints for unattended runs of the [issue workflow](workflow.md). Humans keep calling `*-project-issue` directly. Each agent handles **one** issue per run — do not drain the queue.

| Agent | Status filter | Delegates to |
|-------|---------------|--------------|
| `issue-workflow-review-agent` | `status:pending-review` | `review-project-issue` |
| `issue-workflow-refine-agent` | `status:pending-refinement` | `refine-project-issue` |
| `issue-workflow-clarify-agent` | `status:pending-clarification` | `clarify-project-issue` |
| `handle-feedback-agent` | `type:feedback` in `pending-resolution` | [feedback.md](feedback.md) |
| `issue-workflow-implement-agent` | `status:pending-implementation` | do the work, then `implement-project-issue` |
| `issue-workflow-verify-agent` | `status:pending-verification` | `verify-project-issue` |
| `issue-workflow-accept-agent` | `status:pending-acceptance` | `accept-project-issue` |

No agent for `status:accepted` (terminal). No agent closes `status:resolved`; the planner does ([feedback.md](feedback.md)). No agent for `status:pending-redefinition` — planner via [workflow-comment-cap.md](workflow-comment-cap.md).

## Resolve the target issue

1. If `#n` is provided, use it (the underlying skill asserts the expected status). In an agent-orc prompt, `Assigned issue: N` is `#n` when N is a number. `Assigned issue: none` means this step did not receive an issue.
2. Otherwise discover candidates: open issues with that agent's type labels and status filter. `handle-feedback-agent` uses `type:feedback` in `pending-resolution`. Other agents use `type:epic`, `type:task`, and `type:defect` (`issue-workflow-clarify-agent` does not include feedback).
3. Pick **one** using **priority first, then judgement**:
   1. **Priority tier** (hard): `priority:critical`, then `priority:high`, then `priority:normal` / unlabeled (unlabeled counts as normal). If more than one `priority:*` is present, use the highest tier and leave hygiene to `enforce-task-workflow-status`.
   2. **Within the same tier**, pick by judgement (not a rigid sort). Soft preferences, which an unblocker or foundational issue can outweigh: defects over tasks, and tasks over epics; an earlier wave over a later one; an issue named by an open `pending-resolution` feedback issue ([feedback.md](feedback.md)). A wave is the issue’s milestone titled `Wave N — …` ([waves.md](waves.md)). Also prefer high-impact work — bottlenecks that unblock others (judge fan-out and how much dependents matter — not a raw count), foundational work, and issues that move the project most. Prefer issues that are themselves unblocked and ready to advance; prefer a leaf over its parent when both are eligible; age can break near-ties. Skip issues that clearly need human-only input you do not have (e.g. PO clarification with no answer in context).
4. Read and run the mapped skill for that issue. Do not invent parallel statuses, evidence formats, or transition rules.

Agents must not set or change `priority:*` labels, except hygiene via `enforce-task-workflow-status`.

Trivial `[orc-e2e]` probe issues may use a minimal PR or doc touch as the implement deliverable.

Priority catalog: [`docs/labels.md`](../labels.md). The orchestrator claim list is a parallel lock, not this judgement: priority tier, then defect → task → epic, then earlier `Wave N`, then issue number. No `Wave N` milestone sorts after numbered waves. Discovering with `Assigned issue: none` still judges. Scripts and config: [`.orc/scripts/list-status-issues.sh`](../../.orc/scripts/list-status-issues.sh), [`.orc/scripts/list-feedback-issues.sh`](../../.orc/scripts/list-feedback-issues.sh), [`agent-orc/docs/config.md`](../../agent-orc/docs/config.md).

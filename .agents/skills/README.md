# Project skills

Canonical skill bodies live here (one folder per skill). This catalog is the list agents should maintain — not a full inventory in `AGENTS.md`.

Native facades (Cursor / OpenCode / Grok) and authoring rules (veneers, **Invoke, don't restate**): [`docs/skills.md`](../../docs/skills.md).

## Catalog

| Skill | Purpose |
|-------|---------|
| [`ensure-project-setup`](ensure-project-setup/SKILL.md) | Check first-time setup is done; apply gaps via `setup-github-repo` |
| [`ensure-dev-env-setup`](ensure-dev-env-setup/SKILL.md) | Explicit-only: invent and best-effort install/verify game stack + asset tools from Accepted ADRs; then `setup-unit-test-ci` |
| [`ensure-open-design-skill-setup`](ensure-open-design-skill-setup/SKILL.md) | Explicit-only: git clone/pull Open Design skill + content under `~/.open-design-skill/`; optional user-local Cursor/OpenCode/Grok symlinks |
| [`setup-github-repo`](setup-github-repo/SKILL.md) | Apply and verify first-time GitHub settings (Actions, `main` ruleset, squash-only, auto-merge, labels) |
| [`setup-unit-test-ci`](setup-unit-test-ci/SKILL.md) | Wire Unit tests + Coverage CI from sources or Engine/framework ADRs; sync conventions + workflow; require both checks |
| [`setup-project-mcp`](setup-project-mcp/SKILL.md) | Add, enable, disable, or smoke-test MCP servers for Cursor / OpenCode / Grok; credentials never in-repo |
| [`manage-agent-orc`](manage-agent-orc/SKILL.md) | Set up, configure, run, and monitor the agent-orc skill-agent daemon (facade over `agent-orc/docs/`) |
| [`create-project-label`](create-project-label/SKILL.md) | Add a label to config + docs and sync to GitHub |
| [`create-project-epic`](create-project-epic/SKILL.md) | Create an Epic issue (`type:epic`) on GitHub |
| [`create-project-task`](create-project-task/SKILL.md) | Create a Task issue (`type:task`) with parent/blocked-by wiring |
| [`plan-project-waves`](plan-project-waves/SKILL.md) | Cut coherent waves from formalized specs; vertical epics + leaves for the expanded wave; confirm before filing |
| [`audit-project-wave`](audit-project-wave/SKILL.md) | Audit a filed wave (epics + tasks) for coherence, focus, completeness; confirm before mutating |
| [`project-planner-agent`](project-planner-agent/SKILL.md) | Align plan with specs; shrink/distill (close non-gameplay defects); create only when necessary |
| [`unblock-project-issues`](unblock-project-issues/SKILL.md) | Remove blocked-by when the default branch satisfies the blocker or the edge is obsolete (acceptance is not a gate) |
| [`redefine-project-issue`](redefine-project-issue/SKILL.md) | Replace comment-capped `pending-redefinition` task/defect with a new `pending-clarification` task (planner) |
| [`create-project-defect`](create-project-defect/SKILL.md) | Create a Defect issue (`type:defect`) with related/blocked-by wiring |
| [`enforce-task-workflow-status`](enforce-task-workflow-status/SKILL.md) | Gate or audit `status:*` labels; hygiene for duplicate `priority:*` |
| [`review-project-issue`](review-project-issue/SKILL.md) | Review pass / fail / clarify → next status |
| [`refine-project-issue`](refine-project-issue/SKILL.md) | Refine issue body → pending-review |
| [`clarify-project-issue`](clarify-project-issue/SKILL.md) | Record PO clarification → review or refinement |
| [`implement-project-issue`](implement-project-issue/SKILL.md) | Implementation summary → pending-verification |
| [`verify-project-issue`](verify-project-issue/SKILL.md) | Independent verify pass / fail |
| [`accept-project-issue`](accept-project-issue/SKILL.md) | Accept / fail / clarify after verification |
| [`issue-workflow-review-agent`](issue-workflow-review-agent/SKILL.md) | Background dispatch → `review-project-issue` |
| [`issue-workflow-refine-agent`](issue-workflow-refine-agent/SKILL.md) | Background dispatch → `refine-project-issue` |
| [`issue-workflow-clarify-agent`](issue-workflow-clarify-agent/SKILL.md) | Background dispatch → `clarify-project-issue` |
| [`issue-workflow-implement-agent`](issue-workflow-implement-agent/SKILL.md) | Background dispatch → implement work + `implement-project-issue` |
| [`issue-workflow-verify-agent`](issue-workflow-verify-agent/SKILL.md) | Background dispatch → `verify-project-issue` |
| [`issue-workflow-accept-agent`](issue-workflow-accept-agent/SKILL.md) | Background dispatch → `accept-project-issue` |
| [`babysit-pr-agent`](babysit-pr-agent/SKILL.md) | Soft Actions check queue (~3 active), then one same-repo PR: conflicts, behind, in-scope CI for auto-merge |
| [`author-spec`](author-spec/SKILL.md) | Write or edit a spec from `.agents/specs/rules/`; do not copy the rules into the spec |
| [`author-quality-rubrics`](author-quality-rubrics/SKILL.md) | Interview baseline targets and orthogonal domain axes; write via `author-spec`; execution is `run-quality-evaluators` |
| [`run-quality-evaluators`](run-quality-evaluators/SKILL.md) | Execute Applies axes: deterministic from verify, llm-judge from accept; write `docs/quality/evidence/`; no status change |
| [`capture-requirements`](capture-requirements/SKILL.md) | Default path: interview specs the user picks, foundation first; confirm, `author-spec`, open a spec PR. A PoC only when they ask to explore |
| [`review-spec`](review-spec/SKILL.md) | Review a spec doc or the formalized set; placeholder-only files are not a Fail; whole-spec also runs applicability, terminology, and TBD audits |
| [`serve-ux-mockups`](serve-ux-mockups/SKILL.md) | Explicit-only: serve `specs/ux/mockups/` on the LAN with a generated index, open it in the browser, and report localhost and LAN URLs |
| [`review-code`](review-code/SKILL.md) | Review code vs `docs/solid.md` (SOLID + continuity) and `docs/coding-conventions.md` (project rules + Code lint / Unit tests / Coverage); Pass/Fail, read-only |
| [`audit-code-structure`](audit-code-structure/SKILL.md) | Audit implementation structure and debt (SOLID, conventions, continuity, duplication, dead code, seams, parallel structure); proposed targets; read-only |
| [`suggest-code-refactors`](suggest-code-refactors/SKILL.md) | File refactor epics and tasks from an `audit-code-structure` pass; judgement sizes the cut; no repo edits |
| [`audit-spec-applicability`](audit-spec-applicability/SKILL.md) | Audit Applies/N/A upstream grounds and downstream carry-outs; report for author-spec |
| [`audit-spec-terminology`](audit-spec-terminology/SKILL.md) | Audit glossary ownership and term usage (undefined, drift, synonyms, homonyms); report for author-spec |
| [`audit-spec-tbd`](audit-spec-tbd/SKILL.md) | Find TBDs (undecided aspects), propose grounded answers, confirm with the user, then author-spec |
| [`scope-poc`](scope-poc/SKILL.md) | Clarify PoC purpose/scope/outcome from log or issue; tool/env blockers only; [Before building](../../docs/pocs.md#before-building) |
| [`create-poc`](create-poc/SKILL.md) | Build a PoC under `pocs/` after `scope-poc` passes; formalized specs constrain it; SOLID and conventions do not |
| [`manage-asset`](manage-asset/SKILL.md) | Generate, import, update, or deprecate assets per `specs/assets/` procedures; catalog, review, PR |
| [`establish-asset-style`](establish-asset-style/SKILL.md) | Establish or refresh a kind Style series (anchors → Recraft / ElevenLabs CLI / soft SFX → registry); PR |
| [`register-asset`](register-asset/SKILL.md) | Catalog a person-supplied (human-made or third-party) asset; person-granted review exemption or review-asset; PR |
| [`review-asset`](review-asset/SKILL.md) | Review produced assets vs kind spec and `specs/aesthetics/`; Pass/Fail by element ID, read-only |
| [`reconcile-poc`](reconcile-poc/SKILL.md) | Formalize act: keep/drop/adapt claims, resolve conflicts into the keep list, record act |
| [`promote-poc`](promote-poc/SKILL.md) | Reimplement one PoC's keep/adapt list: assumptions into specs, technical design, asset approval, code review |
| [`sync-upstream-template`](sync-upstream-template/SKILL.md) | Merge upstream template changes downstream: baseline, per-file classify, confirm conflicts, one sync PR |

When adding or renaming a skill: update this table, add facades per `docs/skills.md`, and keep the thin Skills pointer in [`AGENTS.md`](../../AGENTS.md) unchanged unless the path to this catalog moves.

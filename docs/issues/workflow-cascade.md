# Cascade (fail review)

Which other issues move when a review fails. Status labels and the fail transition: [workflow.md](workflow.md).

A fail moves the reviewed issue to `pending-refinement`. Another issue moves only when a cascade is authorized below. Parent, child, and sibling links alone do not authorize one.

**User order.** An explicit user order (for example “fail #8; also impacts #9”) authorizes each named issue. Move it to `pending-refinement` from any current status except `status:pending-redefinition` (comment-capped; redefine instead). Record the order in the fail comment. Dependence proof is not required.

**Agent cascade.** Authorize only when the fail comment records both:

1. A native blocked-by edge between the failed issue and the other issue.
2. A concrete reason that edge makes the other issue’s implementation or verification impossible to do or to judge while this fail stands.

When both facts are recorded, move the other issue to `pending-refinement` from its current status, including `status:accepted`, if implementation or verification is the step that cannot be done or judged. Leave it in place when its current step is review, refinement, or clarification. Never cascade onto or off `status:pending-redefinition`.

**Not authorized.** For every blocked-by neighbor considered for cascade, and for any issue the user asked about that was not ordered onto the cascade, post a short comment that points at the fail and states why the status stays.

**Planner.** [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) removes every cascade this file does not still authorize. The issue that failed review stays in `pending-refinement`. Restore each other issue’s prior `status:*`; when that label cannot be read, use `pending-review`. Comment the reason.

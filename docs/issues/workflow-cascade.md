# Cascade (fail review)

Which other issues move when a review fails. Status labels and the fail transition: [workflow.md](workflow.md).

A fail moves the reviewed issue to `pending-refinement`. Another issue moves only when a cascade is authorized below. Parent, child, and sibling links alone do not authorize one. Agents do **not** cascade on their own.

**User order.** An explicit user order (for example “fail #8; also impacts #9”) authorizes each named issue. Move it to `pending-refinement` from any current status except `status:pending-redefinition` (comment-capped; redefine instead). Record the order in the fail comment. Dependence proof is not required. Never cascade onto or off `status:pending-redefinition`.

**Not authorized.** For any issue the user asked about that was not ordered onto the cascade, post a short comment that points at the fail and states why the status stays.

**Planner.** [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) removes every cascade this file does not still authorize. The issue that failed review stays in `pending-refinement`. Restore each other issue’s prior `status:*`; when that label cannot be read, use `pending-review`. Comment the reason.

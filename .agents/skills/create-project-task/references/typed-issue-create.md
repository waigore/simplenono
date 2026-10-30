# Typed issue create

Shared by `create-project-epic`, `create-project-task`, and `create-project-defect`. The calling skill names the type and any extra collects or checks. Do not copy this procedure into those skills.

**Contract:** [`docs/issues/`](../../../../docs/issues/) (`requirements.md`, `body-shapes.md`, `hierarchy.md`). Do not redefine sections.

**Commands:** [`github-issue-linking.md`](github-issue-linking.md). Substitute the calling skill's `type:*` label in the create example.

## Every run

1. **Read** that type's requirements and body shape.
2. **Collect** `title` and every required section, plus the calling skill's extras. Ask if required content is missing.
3. Run the calling skill's **before-create** checks. Abort when it says to.
4. **Build** the body exactly as `body-shapes.md` specifies.
5. If `--no-create` / "draft only": print title + body and stop.
6. **Create** on GitHub with labels `type:<type>`, `status:pending-review`, and exactly one `priority:*`. Default `priority:normal`. Use `priority:high` or `priority:critical` only when the human explicitly requests that priority at create time. Attach a parent at create time when the linking reference supports it.
7. **Wire** parent and blocked-by per the linking reference and the calling skill. Related-only links stay in the body when that skill says so.
8. **Report** URL, labels (`type:*`, `status:pending-review`, `priority:*`), and dependency wiring.

## Rules

- Do not change priority after create. Only humans set or change priority later.
- Default is create on GitHub.

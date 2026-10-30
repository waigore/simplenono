# Authoring rules: interface style

Read this before editing `specs/aesthetics/ui-style.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md), [ids.md](ids.md), and [palette.md](palette.md).

How the interface looks: type, icons, panels, color roles, and interface motion. What a screen holds, and how it is operated, lives in `specs/ux/`. The design system bound in `specs/ux/presentation.md` must realize this style; that file records how under **Aesthetics fit**. When they disagree, this spec wins and the binding changes.

Write "N/A — reason" in each section when the game has no interface beyond the world itself.

## Header

- **Serves**: vision qualities, style pillars, and design or UX-relevant quality categories.

## Sections

- **Typography**: `T1`, `T2`, …. Columns: ID, type role (title, body, numbers in play, labels), classification (pixel, geometric sans, humanist sans, serif, script), weight and case, and size as screen pixels at a reference frame height or as a fraction of frame height. A named typeface is an asset sourced per `specs/assets/`. When accessibility Applies, state the smallest size the target allows. When localization Applies, state the scripts every type role must cover.
- **Iconography**: `I1`, `I2`, …. Columns: ID, icon class, grid size, line or fill, stroke width, corner treatment, and perspective (flat or angled).
- **Panels**: `F1`, `F2`, …. Columns: ID, surface (panel, button, frame, tooltip), border and corner treatment, fill (flat, textured, translucent), and whether it reads as part of the world or apart from it.
- **Color roles**: `C1`, `C2`, …. Columns: ID, role (background, surface, text, accent, danger, focus, disabled), the swatch it uses (a `PAL.C` ID), and the contrast it must keep against its pair (cite a `PAL.K` rule).
- **Interface motion**: `M1`, `M2`, …. Columns: ID, motion class (screen transition, focus change, value change, notification), duration in seconds, and easing. UX states which transitions happen; this states how they look.

## Splitting

If the file passes 500 words, move typography to `ui-style/typography.md`. Leave a summary and a link, and update `aesthetics.md`.

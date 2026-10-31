# Presentation

Authoring rules: [`.agents/specs/rules/ux/presentation.md`](../../.agents/specs/rules/ux/presentation.md).

## Binding

- **Design system**: `minimal` / `design-systems/minimal`
- **Content root**: `~/.open-design-skill/repo` (default when `OPEN_DESIGN_ROOT` is unset)
- **Aesthetics fit**: Open Design supplies layout structure and components only. Remap chrome to [`PAL.S1`](../aesthetics/palette.md) (Paper, Ink, Cross, Rule, Dim, Contradiction). Panels stay square with Rule borders ([`UIS.F1`](../aesthetics/ui-style.md)). Type is geometric sans ([`UIS.T1`](../aesthetics/ui-style.md), [`UIS.T2`](../aesthetics/ui-style.md)). Drop seed purple/blue accents, soft shadows, and pills — aesthetics win over the seed.
- **Catalog**: [`mockups/catalog.md`](mockups/catalog.md)

## Surfaces

| Surface | Screens | Template | Craft |
|---------|---------|----------|-------|
| Meta UI — mobile (iOS, Android) | gallery, result, settings | `mobile-app` | `state-coverage`, accessibility |
| Meta UI — desktop (Windows, macOS, Linux) | gallery, result, settings | `web-prototype` | `state-coverage`, accessibility |
| Play UI — all platforms | puzzle | [`mockups/screens/_template.html`](mockups/screens/_template.html) + remapped DS tokens | `state-coverage`, accessibility |

At `small` depth, meta mockups use platform-group suffixes: `<screen>.mobile.html` and `<screen>.desktop.html`. Play uses one mockup path per screen until a platform split is needed.

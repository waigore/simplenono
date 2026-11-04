---
name: serve-ux-mockups
description: |-
  Serve specs/ux/mockups over HTTP on all interfaces (0.0.0.0), with a generated
  index of screen and journey HTML, then open the page in the browser and report
  the localhost and LAN URLs. When the user says they are on a tailnet, also
  expose Tailscale Serve as plain https://<MagicDNS>/ (no port) and report that
  URL. Use only when the user asks to serve, preview, or open UX mockups. Do not
  run it during spec review or authoring unless asked.

  Examples:
    - user: "Serve the mockups" → start the server, open the index, give localhost and LAN URLs
    - user: "Serve the mockups on my tailnet" → same, plus Tailscale HTTPS URL
    - user: "Preview the title screen mockup" → open that screen URL in the browser
    - user: "Show me the onboarding journey" → open that journey URL in the browser
    - user: "Stop the mockup preview" → stop the server; if Tailscale was enabled, reset serve
---

# Serve UX mockups (facade)

Canonical instructions: [`.agents/skills/serve-ux-mockups/SKILL.md`](../../../.agents/skills/serve-ux-mockups/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

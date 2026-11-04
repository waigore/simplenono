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

# Serve UX mockups

Explicit only. Do not call this from other skills.

The server is [scripts/serve_mockups.py](scripts/serve_mockups.py). It serves `specs/ux/mockups/` on `0.0.0.0`, generates the index in memory at `/`, and writes nothing into the repo. Screen and journey files whose names start with `_` (the templates) stay available as files and are omitted from the index.

When the user says they are on a tailnet (or asks for a Tailscale / MagicDNS URL), the script also runs `tailscale serve` so phones and other tailnet devices open plain `https://<MagicDNS>/` with no port. That is tailnet-only Serve, never Funnel.

## Steps

1. Confirm `specs/ux/mockups/` exists. If it does not, stop and say so.
2. If the user named a screen or journey, set `--target` to its path relative to `specs/ux/mockups/` (`screens/<file>.html` or `journeys/<file>.html`). Match the filled HTML file. If none matches, say so and serve the index instead.
3. Start the script in the background from the repo root:

```bash
python3 .agents/skills/serve-ux-mockups/scripts/serve_mockups.py
```

Add `--target <path>` when a file matched. Add `--tailscale` only when the user said they are on a tailnet (or asked for Tailscale / MagicDNS). Leave the process running.

4. Read stdout until `status:` is `serving` or `reused`. On `reused`, use that server. Do not start a second copy.
5. Open `target:` when present, otherwise `localhost:`. Use a browser tool when one is available: navigate to the `127.0.0.1` URL, then snapshot the page so the user can see it. When no browser tool exists, give the URLs and say the page was not opened.
6. Tell the user the localhost URL and every `lan:` URL. `lan: none` means no LAN address was found; report localhost only. When `--tailscale` was used, also report `tailscale:` (plain HTTPS, no port). Prefer that URL for mobile / remote tailnet devices. If stdout has `tailscale: error:`, report the error and keep localhost/LAN. When the error mentions serve config access denied, tell the user to run `sudo tailscale set --operator=$USER` once (then retry). When a target was requested and Tailscale succeeded, also report `target-tailscale:`.
7. Say that the server keeps running until that process is stopped, and that anyone on the local network can open the LAN URL while it runs. When Tailscale is active, say any device on the tailnet can open the HTTPS URL while Serve is configured.
8. When the user asks to stop the preview: stop only the process this skill started. If this session used `--tailscale` (or stdout showed a successful `tailscale:` URL), also run `tailscale serve reset`. If reset fails with access denied, report that and the same `--operator=$USER` fix (or `sudo tailscale serve reset`).

## Rules

- Do not edit mockup HTML, specs, or git state.
- Do not bind a narrower interface. The user asked for LAN access.
- Serve only `specs/ux/mockups/`. Do not serve the repo root or the rest of `specs/`.
- Prefer the running server when `status:` is `reused`.
- Do not pass `--tailscale` unless the user asked for tailnet / Tailscale access.
- Prefer the `tailscale` CLI for Serve setup, status, MagicDNS, and reset. Do not invent a parallel HTTPS tunnel.
- Use Tailscale Serve (tailnet only). Do not use Funnel or otherwise expose the mockups to the public internet.
- Do not use `sudo` for Tailscale; if Serve is denied, tell the user to grant operator once.
- Stop only the process this skill started when the user asks to stop the preview; when Tailscale was enabled, always `tailscale serve reset` as part of stop.

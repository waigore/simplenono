# Secret guard

Hard rule: credentials and keys must never be saved in the project repository.

## Refuse

Stop and tell the user if they ask to:

- Paste an API key, token, password, or OAuth client secret into any project file
- Add `envFile` pointing at the workspace, or commit a `.env` / `.env.*` for MCP
- Put literal secrets in `env`, `headers`, `args`, or URL query strings
- Put secret values in a PR body, commit message, or docs

Allowed in committed files: env var **names** and `${env:NAME}` (or client-equivalent) references.

## Before any PR that touches MCP configs

Scan the staged/unstaged diff for:

- Long base64- or hex-like blobs assigned to auth fields
- Strings matching common key prefixes (`sk-`, `ghp_`, `xoxb-`, `Bearer ` + token)
- New `.env` / `envFile` / credential filenames under the repo
- `enabled: true` / `enabled = true` that should stay local-only

If any hit: abort the PR, scrub the value from the working tree, and restate that secrets live only outside the repo (shell profile, OS env, agent env UI).

## What to tell the user

1. Set `<VAR_NAME>` in their environment (or agent env UI)—do not paste the value into chat if they can avoid it.
2. Restart the agent client so it picks up the env.
3. Enable the server locally per `docs/mcp.md`.
4. Run smoke test via this skill’s **Test** mode.

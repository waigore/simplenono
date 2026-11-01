# Integration harness

Harness command, scope, and exit codes. Parent: [`../coding-conventions.md`](../coding-conventions.md).

Runs one protocol per invocation and writes a run folder; exit `0` pass, `1` protocol fail, `2` usage or seam flag off ([`verification.md`](../../specs/technical/verification.md) H1–H4). The `Integration harness` job in [`integration.yml`](../../.github/workflows/integration.yml) runs only the CI-only `self-test`; the six game protocols run now that #163's seams have merged, but stay out of CI while their product rows are red (#94–#96). Layout and protocols: [`game/test/integration/README.md`](../../game/test/integration/README.md).

| Tool | Command | Scope |
|------|---------|-------|
| Integration harness | `godot --headless --path game -s test/integration/run_protocol.gd -- --protocol=<id> --run-dir=<dir>` | CI passes `--protocol=self-test`; game protocols also pass `--debug-seams` |

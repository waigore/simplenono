# Checks — #232 verify (deliverable a5dd745)

```
$ python3 .github/scripts/generate_pack.py --check
/tmp/opencode/v232/game/data/pack.json is current
$ python3 .github/scripts/asset_manifest.py --check
Asset manifest: 0 error(s).
$ python3 .github/scripts/asset_catalog.py
Asset catalog: 0 error(s).
$ python3 .github/scripts/spec_lint.py
  WARNING: specs/view/glossary.md:12 [glossary] 'Diagram' is also defined in specs/technical/glossary.md; define it once and link
Spec lint: 0 error(s), 1 warning(s) across 9 checks.
$ python3 -m unittest discover -s .github/scripts/tests
Ran 110 tests in 43.890s

OK
```

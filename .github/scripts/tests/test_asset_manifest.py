"""Tests for asset_manifest.py."""
from __future__ import annotations

import contextlib
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from asset_manifest import MANIFEST, build_manifest, render, run  # noqa: E402
from new_asset_id import uuid7  # noqa: E402

HUB = """# Asset Pipeline

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | Applies | 2D | [`kinds/character-sprites.md`](kinds/character-sprites.md) |

## Catalog

- **Catalog root**: {catalog} (ADR-0003)
- **Asset root**: {assets} (ADR-0003)

## Lifecycle
"""


def entry(asset_id: str, files: list[str], state: str = "approved") -> dict[str, object]:
    return {
        "id": asset_id,
        "handle": "character-sprites/player-idle",
        "kind_spec": "AK-character-sprites",
        "serves": ["CH-player"],
        "state": state,
        "version": 1,
        "files": files,
        "source_type": "human-made",
        "license": {"grant": "assigned"},
    }


class ManifestTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root / "specs/assets").mkdir(parents=True)
        (self.root / "game").mkdir(parents=True)
        (self.root / "game/project.godot").write_text("[application]\n", encoding="utf-8")
        (self.root / "game/assets").mkdir()
        (self.root / "assets/catalog").mkdir(parents=True)
        self.hub()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def hub(self, catalog: str = "`assets/catalog/`", assets: str = "`game/assets/`") -> None:
        (self.root / "specs/assets/assets.md").write_text(HUB.format(catalog=catalog, assets=assets), encoding="utf-8")

    def add(self, data: dict[str, object], *, make_files: bool = True, name: str | None = None) -> str:
        asset_id = str(data["id"])
        (self.root / "assets/catalog" / f"{name or asset_id}.json").write_text(json.dumps(data), encoding="utf-8")
        for file in data.get("files", []) if make_files else []:  # type: ignore[union-attr]
            path = self.root / "game/assets" / str(file)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"png")
        return asset_id

    def manifest(self) -> dict[str, list[str]]:
        return json.loads((self.root / MANIFEST).read_text(encoding="utf-8"))

    def invoke(self, *args: str) -> tuple[int, str]:
        out = io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            code = run([str(arg) for arg in args] + ["--root", str(self.root)])
        return code, out.getvalue()

    def test_writes_only_approved_entries_with_res_paths(self) -> None:
        approved = self.add(entry(str(uuid7()), ["character-sprites/idle.png", "character-sprites/run.png"]))
        draft = self.add(entry(str(uuid7()), ["character-sprites/draft.png"], state="draft"))
        deprecated = self.add(entry(str(uuid7()), ["character-sprites/old.png"], state="deprecated"))
        self.assertNotEqual(approved, draft)
        self.assertNotEqual(approved, deprecated)

        code, out = self.invoke()

        self.assertEqual(code, 0)
        self.assertIn(MANIFEST, out)
        self.assertEqual(
            self.manifest(),
            {approved: ["res://assets/character-sprites/idle.png", "res://assets/character-sprites/run.png"]},
        )

    def test_output_is_byte_stable_on_consecutive_runs(self) -> None:
        self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        self.add(entry(str(uuid7()), ["character-sprites/run.png"]))
        self.assertEqual(self.invoke()[0], 0)
        first = (self.root / MANIFEST).read_bytes()
        self.assertEqual(self.invoke()[0], 0)
        self.assertEqual((self.root / MANIFEST).read_bytes(), first)
        self.assertTrue(first.endswith(b"\n"))
        self.assertEqual(first.decode("utf-8"), render(json.loads(first)))

    def test_file_order_within_an_entry_is_preserved(self) -> None:
        asset_id = self.add(entry(str(uuid7()), ["character-sprites/z.png", "character-sprites/a.png"]))
        self.assertEqual(self.invoke()[0], 0)
        self.assertEqual(
            self.manifest()[asset_id],
            ["res://assets/character-sprites/z.png", "res://assets/character-sprites/a.png"],
        )

    def test_check_passes_when_the_manifest_is_identical(self) -> None:
        self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        self.assertEqual(self.invoke()[0], 0)
        self.assertEqual(self.invoke("--check"), (0, "Asset manifest: 0 error(s).\n"))

    def test_check_fails_when_the_manifest_is_missing(self) -> None:
        self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        code, out = self.invoke("--check")
        self.assertEqual(code, 1)
        self.assertIn(f"ERROR: {MANIFEST} is missing; regenerate it", out)

    def test_check_names_missing_extra_and_changed_entries(self) -> None:
        kept = self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        gone = self.add(entry(str(uuid7()), ["character-sprites/run.png"]))
        stale = str(uuid7())
        (self.root / MANIFEST).write_text(
            json.dumps(
                {
                    kept: ["res://assets/character-sprites/elsewhere.png"],
                    gone: ["res://assets/character-sprites/run.png"],
                    stale: ["res://assets/character-sprites/old.png"],
                }
            ),
            encoding="utf-8",
        )
        code, out = self.invoke("--check")
        self.assertEqual(code, 1)
        self.assertIn(f"ERROR: {kept} paths differ", out)
        self.assertIn(f"ERROR: {stale} is not generated from the catalog", out)

        (self.root / MANIFEST).write_text(json.dumps({kept: ["res://assets/character-sprites/idle.png"]}), encoding="utf-8")
        code, out = self.invoke("--check")
        self.assertEqual(code, 1)
        self.assertIn(f"ERROR: {gone} is missing from {MANIFEST}", out)

    def test_missing_cataloged_file_fails_without_touching_the_manifest(self) -> None:
        asset_id = self.add(entry(str(uuid7()), ["character-sprites/idle.png"]), make_files=False)
        sentinel = '{"sentinel": []}\n'
        (self.root / MANIFEST).write_text(sentinel, encoding="utf-8")

        code, out = self.invoke()

        self.assertEqual(code, 1)
        self.assertIn(f"ERROR: {asset_id}: cataloged file 'character-sprites/idle.png' does not exist", out)
        self.assertEqual((self.root / MANIFEST).read_text(encoding="utf-8"), sentinel)

    def test_unset_roots_skip_and_leave_the_manifest_alone(self) -> None:
        self.hub(catalog="TBD — which folder?", assets="<!-- fill in -->")
        self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        sentinel = '{"sentinel": []}\n'
        (self.root / MANIFEST).write_text(sentinel, encoding="utf-8")

        code, out = self.invoke()

        self.assertEqual(code, 0)
        self.assertIn("NOTE:", out)
        self.assertIn("skipped", out)
        self.assertEqual((self.root / MANIFEST).read_text(encoding="utf-8"), sentinel)
        manifest, errors, notes = build_manifest(self.root)
        self.assertIsNone(manifest)
        self.assertEqual(errors, [])
        self.assertIn("skipped", notes[0])
        self.assertEqual(self.invoke("--check"), (0, "NOTE: catalog root not set in specs/assets/assets.md; manifest generation skipped\nAsset manifest: generation skipped; assets/manifest.json not compared.\n"))

    def test_writes_an_empty_object_when_nothing_is_approved(self) -> None:
        self.add(entry(str(uuid7()), ["character-sprites/draft.png"], state="draft"))
        self.assertEqual(self.invoke()[0], 0)
        self.assertEqual((self.root / MANIFEST).read_text(encoding="utf-8"), "{}\n")

    def test_malformed_entry_fails_generation(self) -> None:
        (self.root / "assets/catalog/broken.json").write_text("{not json", encoding="utf-8")
        code, out = self.invoke()
        self.assertEqual(code, 1)
        self.assertIn("ERROR: assets/catalog/broken.json: not valid UTF-8 JSON", out)
        self.assertFalse((self.root / MANIFEST).exists())

    def test_asset_root_must_be_under_the_godot_project(self) -> None:
        self.hub(assets="`outside/assets/`")
        self.add(entry(str(uuid7()), ["character-sprites/idle.png"]))
        (self.root / "outside/assets/character-sprites").mkdir(parents=True)
        (self.root / "outside/assets/character-sprites/idle.png").write_bytes(b"png")
        code, out = self.invoke()
        self.assertEqual(code, 1)
        self.assertIn("no project.godot above the asset root", out)

    def test_write_and_check_are_mutually_exclusive(self) -> None:
        with self.assertRaises(SystemExit) as raised:
            self.invoke("--write", "--check")
        self.assertEqual(raised.exception.code, 2)


if __name__ == "__main__":
    unittest.main()

"""Tests for check_release_assets.py (issue #499 / ADR-0008)."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from check_release_assets import INBUILD, MANIFEST, check  # noqa: E402
from new_asset_id import uuid7  # noqa: E402

HUB = """# Asset Pipeline

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | Applies | 2D | [`kinds/character-sprites.md`](kinds/character-sprites.md) |

## Catalog

- **Catalog root**: `assets/catalog/` (ADR-0003)
- **Asset root**: `game/assets/` (ADR-0003)

## Lifecycle
"""


class ReleaseFixture(unittest.TestCase):
    """A repo-shaped tree: manifest, catalog, asset files, and shipped game code."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root / "specs/assets").mkdir(parents=True)
        (self.root / "specs/assets/assets.md").write_text(HUB, encoding="utf-8")
        (self.root / "game/assets").mkdir(parents=True)
        (self.root / "game/presentation").mkdir(parents=True)
        (self.root / "assets/catalog").mkdir(parents=True)
        (self.root / "game/presentation/shell.gd").write_text("extends Node\n", encoding="utf-8")
        self.ids: list[str] = []

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def asset(
        self,
        *,
        state: str = "approved",
        make_file: bool = True,
        sidecar_only: bool = False,
        name: str = "slide.png",
    ) -> str:
        asset_id = str(uuid7())
        self.ids.append(asset_id)
        (self.root / "assets/catalog" / f"{asset_id}.json").write_text(
            json.dumps({"id": asset_id, "state": state, "handle": f"character-sprites/{name}"}),
            encoding="utf-8",
        )
        path = self.root / "game/assets" / name
        if make_file and not sidecar_only:
            path.write_bytes(b"png")
        if sidecar_only:
            path.with_name(path.name + ".import").write_text("[remap]\n", encoding="utf-8")
        return asset_id

    def manifest(self, entries: dict[str, list[str]] | None = None) -> None:
        data = entries if entries is not None else {i: [f"res://assets/slide.png"] for i in self.ids}
        (self.root / MANIFEST).write_text(json.dumps(data), encoding="utf-8")

    def errors(self) -> list[str]:
        return check(self.root)


class CleanTreeTest(ReleaseFixture):
    def test_a_complete_tree_has_no_findings(self) -> None:
        self.asset()
        self.manifest()
        self.assertEqual(self.errors(), [])

    def test_an_import_sidecar_without_the_file_is_enough(self) -> None:
        self.asset(sidecar_only=True)
        self.manifest()
        self.assertEqual(self.errors(), [])


class ManifestScopeTest(ReleaseFixture):
    def test_a_missing_file_and_sidecar_is_an_error(self) -> None:
        asset_id = self.asset(make_file=False)
        self.manifest({asset_id: ["res://assets/slide.png"]})
        self.assertIn("no file or .import sidecar", self.errors()[0])

    def test_a_path_outside_the_asset_root_is_an_error(self) -> None:
        asset_id = self.asset()
        self.manifest({asset_id: ["res://presentation/shell.gd"]})
        self.assertIn("outside the asset root", self.errors()[0])

    def test_a_non_res_path_is_an_error(self) -> None:
        asset_id = self.asset()
        self.manifest({asset_id: ["assets/slide.png"]})
        self.assertIn("not res://", self.errors()[0])

    def test_an_empty_entry_is_an_error(self) -> None:
        asset_id = self.asset()
        self.manifest({asset_id: []})
        self.assertIn("lists no path", self.errors()[0])

    def test_an_empty_manifest_is_an_error(self) -> None:
        self.manifest({})
        self.assertIn("lists no assets", self.errors()[0])


class CatalogStateTest(ReleaseFixture):
    def test_a_draft_entry_ships_nothing(self) -> None:
        asset_id = self.asset(state="draft")
        self.manifest({asset_id: ["res://assets/slide.png"]})
        self.assertIn("not approved", self.errors()[0])

    def test_a_deprecated_entry_ships_nothing(self) -> None:
        asset_id = self.asset(state="deprecated")
        self.manifest({asset_id: ["res://assets/slide.png"]})
        self.assertIn("not approved", self.errors()[0])

    def test_an_entry_without_a_catalog_record_is_an_error(self) -> None:
        asset_id = self.asset()
        (self.root / "assets/catalog" / f"{asset_id}.json").unlink()
        self.manifest({asset_id: ["res://assets/slide.png"]})
        self.assertIn("no catalog entry", self.errors()[0])


class ShippedIdTest(ReleaseFixture):
    def test_a_shipped_id_absent_from_the_manifest_is_an_error(self) -> None:
        asset_id = self.asset()
        self.manifest({asset_id: ["res://assets/slide.png"]})
        unknown = str(uuid7())
        (self.root / "game/presentation/shell.gd").write_text(f'const ID := "{unknown}"\n', encoding="utf-8")
        self.assertIn(f"shell.gd: ships {unknown}", self.errors()[0])

    def test_test_files_may_name_ids_the_manifest_omits(self) -> None:
        self.asset()
        self.manifest()
        (self.root / "game/test").mkdir()
        (self.root / "game/test/test_x.gd").write_text(f'const ID := "{uuid7()}"\n', encoding="utf-8")
        self.assertEqual(self.errors(), [])


class RuntimeReadTest(ReleaseFixture):
    def test_a_res_parent_read_in_shipped_code_is_an_error(self) -> None:
        self.asset()
        self.manifest()
        (self.root / "game/presentation/leak.gd").write_text(
            'const P := "res://../assets/manifest.json"\n', encoding="utf-8"
        )
        self.assertIn("reads res://../ at runtime", self.errors()[0])

    def test_the_resolver_may_name_the_dev_read(self) -> None:
        self.asset()
        self.manifest()
        resolver = self.root / "game/presentation/asset_resolver.gd"
        resolver.write_text('const P := "res://../assets/manifest.json"\n', encoding="utf-8")
        self.assertEqual(self.errors(), [])


class InBuildCopyTest(ReleaseFixture):
    def test_an_identical_copy_passes(self) -> None:
        self.asset()
        self.manifest()
        copy = self.root / INBUILD
        copy.parent.mkdir(parents=True)
        copy.write_bytes((self.root / MANIFEST).read_bytes())
        self.assertEqual(self.errors(), [])

    def test_a_stale_copy_is_an_error(self) -> None:
        self.asset()
        self.manifest()
        copy = self.root / INBUILD
        copy.parent.mkdir(parents=True)
        copy.write_text(json.dumps({"stale": ["res://assets/gone.png"]}), encoding="utf-8")
        self.assertIn("differs from", self.errors()[0])


if __name__ == "__main__":
    unittest.main()

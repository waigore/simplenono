"""Tests for asset_catalog.py."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from asset_catalog import check, read_hub  # noqa: E402
from new_asset_id import uuid7  # noqa: E402

HUB = """# Asset Pipeline

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | Applies | 2D | [`kinds/character-sprites.md`](kinds/character-sprites.md), `tile-sprites` (planned) |
| Music | N/A — silent | none | <!-- fill in --> |

## Catalog

- **Catalog root**: {catalog} (ADR-0004)
- **Asset root**: {assets} (ADR-0004)

## Lifecycle
"""


def entry(**overrides: object) -> dict[str, object]:
    base: dict[str, object] = {
        "id": str(uuid7()),
        "handle": "character-sprites/player-idle",
        "kind_spec": "AK-character-sprites",
        "serves": ["CH-player"],
        "state": "draft",
        "version": 1,
        "files": ["character-sprites/player-idle.png"],
        "source_type": "human-made",
        "license": {"grant": "assigned"},
        "supplier": "A. Artist",
    }
    base.update(overrides)
    return {k: v for k, v in base.items() if v is not ...}


class CatalogTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root / "specs/assets").mkdir(parents=True)
        self.hub("`game/catalog/`", "`game/assets`")
        (self.root / "game/catalog").mkdir(parents=True)
        (self.root / "game/assets/character-sprites").mkdir(parents=True)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def hub(self, catalog: str, assets: str) -> None:
        (self.root / "specs/assets/assets.md").write_text(HUB.format(catalog=catalog, assets=assets), encoding="utf-8")

    def add(self, data: dict[str, object], *, files: bool = True) -> str:
        name = f"{data.get('id', 'x')}.json"
        (self.root / "game/catalog" / name).write_text(json.dumps(data), encoding="utf-8")
        for f in data.get("files", []) if files else []:  # type: ignore[union-attr]
            path = self.root / "game/assets" / str(f)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"png")
        return name

    def checks(self) -> list[str]:
        findings, _ = check(self.root)
        return [f"{f.check}: {f.message}" for f in findings]

    def test_reads_hub(self) -> None:
        hub = read_hub(self.root)
        self.assertEqual((hub.catalog_root, hub.asset_root), ("game/catalog", "game/assets"))
        self.assertEqual(hub.kind_specs, {"character-sprites", "tile-sprites"})

    def test_skips_until_catalog_root_is_set(self) -> None:
        self.hub("TBD — which folder? `game/catalog/`", "<!-- fill in -->")
        findings, notes = check(self.root)
        self.assertEqual(findings, [])
        self.assertIn("skipped", notes[0])

    def test_valid_entry_passes(self) -> None:
        self.add(entry())
        self.add(entry(handle="tile-sprites/grass", kind_spec="AK-tile-sprites", files=["tile-sprites/grass.png"]))
        self.assertEqual(self.checks(), [])

    def test_asset_id_must_be_uuid7_and_match_file_name(self) -> None:
        self.add(entry(id="123e4567-e89b-12d3-a456-426614174000"))
        good = entry(files=["character-sprites/b.png"], handle="character-sprites/b")
        (self.root / "game/catalog/wrong-name.json").write_text(json.dumps(good), encoding="utf-8")
        (self.root / "game/assets/character-sprites/b.png").write_bytes(b"png")
        found = self.checks()
        self.assertIn("I2: 'id' is not a lowercase UUID version 7", found)
        self.assertIn("I2: file name must be '<id>.json'", found)

    def test_handles_unique_and_prefixed_by_hub_kind_spec(self) -> None:
        self.add(entry())
        self.add(entry(files=["character-sprites/other.png"]))
        self.add(entry(handle="sprites/hero", files=["character-sprites/hero.png"]))
        found = self.checks()
        self.assertTrue(any(f.startswith("I7: handle 'character-sprites/player-idle' is also used") for f in found))
        self.assertTrue(any("prefix 'sprites' is not a kind spec" in f for f in found))

    def test_approved_needs_pass_or_exemption(self) -> None:
        self.add(entry(state="approved"))
        self.add(entry(state="approved", handle="character-sprites/b", files=["character-sprites/b.png"],
                       exemption={"granted_by": "A. Artist", "date": "2026-10-15", "reason": "hand-drawn"}))
        found = self.checks()
        self.assertEqual([f for f in found if f.startswith("I3")], ["I3: approved entry needs a review with verdict 'Pass', or an exemption"])

    def test_exemption_needs_person_date_reason(self) -> None:
        self.add(entry(exemption={"granted_by": "", "date": "15/10/2026", "reason": "ok"}))
        found = self.checks()
        self.assertIn("I6: 'exemption' is missing granted_by", found)
        self.assertIn("I6: 'exemption.date' must be YYYY-MM-DD", found)

    def test_agent_generated_needs_tool_recipe_generation(self) -> None:
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"]))
        found = self.checks()
        for key in ("generation", "tool_role", "recipe"):
            with self.subTest(key=key):
                self.assertTrue(any(f"'{key}'" in f for f in found))

    def test_agent_generation_needs_structured_parts(self) -> None:
        gen = {"tool": "Recraft"}
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("'generation' is missing" in f for f in found))

    def test_agent_generation_with_style_needs_series(self) -> None:
        gen = {
            "prompt": "player idle", "tool": "Recraft", "operation": "generate_image",
            "settings": {"model": "recraftv4_1_raster", "input_style_id": "style-1"},
            "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("'series'" in f for f in found))

    def test_agent_generation_structured_passes(self) -> None:
        gen = {
            "prompt": "player idle", "tool": "Recraft", "operation": "generate_image",
            "settings": {"model": "recraftv4_1_raster", "image_size": "1:1", "input_style_id": "style-1"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-character-sprites.SS1", "recraft_style_id": "style-1"},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_music_series_passes(self) -> None:
        gen = {
            "prompt": "battle theme", "tool": "ElevenLabs", "operation": "compose",
            "settings": {"model": "music_v2_5", "finetune_id": "ft-1"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-music.SS1", "elevenlabs_finetune_id": "ft-1"},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_sfx_soft_series_passes(self) -> None:
        gen = {
            "prompt": "ui click", "tool": "ElevenLabs", "operation": "text_to_sound_effects",
            "settings": {"model": "eleven_text_to_sound_v2"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-sound-effects.SS1", "soft_enforce": True},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_series_rejects_multiple_bindings(self) -> None:
        gen = {
            "prompt": "x", "tool": "ElevenLabs", "operation": "compose",
            "settings": {"model": "music_v2_5", "finetune_id": "ft-1"},
            "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {
                "id": "AK-music.SS1",
                "elevenlabs_finetune_id": "ft-1",
                "recraft_style_id": "style-1",
            },
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("exactly one" in f for f in found))

    def test_files_exist_and_every_file_is_owned(self) -> None:
        self.add(entry(), files=False)
        (self.root / "game/assets/character-sprites/stray.png").write_bytes(b"png")
        (self.root / "game/assets/character-sprites/stray.png.import").write_bytes(b"x")
        found = self.checks()
        self.assertIn("I1: file 'character-sprites/player-idle.png' does not exist under game/assets", found)
        self.assertIn("I1: file belongs to no catalog entry", found)
        self.assertEqual(len([f for f in found if f.startswith("I1")]), 2)

    def test_successor_must_be_another_entry(self) -> None:
        self.add(entry(state="deprecated", deprecation_reason="replaced", successor=str(uuid7())))
        self.assertTrue(any(f.startswith("I4: successor") for f in self.checks()))

    def test_touchups_need_full_record_and_agreement_when_person_supplied(self) -> None:
        full = {"operation": "remove background", "tool": "Recraft", "terms": "Pro plan", "date": "2026-10-15",
                "reason": "transparent background per S4", "run_by": "agent",
                "prompt": "remove background", "inputs": {}}
        self.add(entry(touchups=[full]))
        self.add(entry(handle="character-sprites/b", files=["character-sprites/b.png"], touchups=[{"tool": "Recraft"}]))
        self.add(entry(handle="character-sprites/c", files=["character-sprites/c.png"], touchups=[]))
        found = self.checks()
        self.assertIn("fields: 'touchups[0]' is missing agreed_by", found)
        self.assertTrue(any("'touchups[0]' is missing operation, terms, date, reason, run_by, agreed_by" in f for f in found))
        self.assertIn("fields: 'touchups' must be a non-empty list", found)

    def test_agent_touchups_need_prompt_and_inputs(self) -> None:
        touchup = {"operation": "remove background", "tool": "Recraft", "terms": "Pro plan",
                   "date": "2026-10-15", "reason": "transparent background", "run_by": "agent"}
        self.add(entry(supplier=..., coverage=["AK-character-sprites.V1"], touchups=[touchup]))
        found = self.checks()
        self.assertTrue(any("prompt" in f and "inputs" in f for f in found))

    def test_banned_tools_rejected(self) -> None:
        (self.root / "docs").mkdir()
        (self.root / "docs/asset-tools.md").write_text(
            "# Asset tools\n\n## Banned tools\n\n| Tool | Scope |\n|------|-------|\n| Pixellab | Never |\n\n## Touch-up\n",
            encoding="utf-8")
        touchup = {"operation": "inpaint", "tool": "PixelLab MCP", "terms": "t", "date": "2026-10-15",
                   "reason": "r", "run_by": "agent", "agreed_by": "A. Artist"}
        self.add(entry(source_type="ai-generation", generation={"tool": "pixellab"}, touchups=[touchup]))
        found = self.checks()
        self.assertEqual(len([f for f in found if f.startswith("I8")]), 2)

    def test_rejects_null_and_non_entry_files(self) -> None:
        self.add(entry(successor=None))
        (self.root / "game/catalog/notes.txt").write_text("hi", encoding="utf-8")
        found = self.checks()
        self.assertIn("fields: 'successor' is null", found)
        self.assertTrue(any(f.startswith("catalog: only entry files") for f in found))


if __name__ == "__main__":
    unittest.main()

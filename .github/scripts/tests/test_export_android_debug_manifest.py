"""Static checks: Android debug export stages the ADR-0008 in-build manifest (#506)."""
from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / ".github/scripts/export_android_debug.sh"
PRESET = ROOT / "game/export_presets.cfg"


class ExportAndroidDebugManifest(unittest.TestCase):
    def test_script_copies_committed_manifest_into_res(self) -> None:
        text = SCRIPT.read_text(encoding="utf-8")
        self.assertIn('MANIFEST="$ROOT/assets/manifest.json"', text)
        self.assertIn('INBUILD="$INBUILD_DIR/asset_manifest.json"', text)
        self.assertIn('cp "$MANIFEST" "$INBUILD"', text)
        self.assertIn('rm -f "$INBUILD"', text)
        self.assertIn("ADR-0008", text)

    def test_android_preset_include_filter_packs_the_copy(self) -> None:
        text = PRESET.read_text(encoding="utf-8")
        match = re.search(
            r'\[preset\.0\]\n(?:.*\n)*?include_filter="([^"]*)"',
            text,
        )
        self.assertIsNotNone(match, "preset.0 must declare include_filter")
        self.assertEqual(
            match.group(1),
            "release/asset_manifest.json",
            "Android debug must pack the in-build manifest so pictures resolve",
        )


if __name__ == "__main__":
    unittest.main()

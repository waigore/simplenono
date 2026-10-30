"""Tests for new_asset_id.py."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from new_asset_id import is_asset_id, uuid7  # noqa: E402


class Uuid7Test(unittest.TestCase):
    def test_version_and_variant(self) -> None:
        value = uuid7()
        self.assertEqual(value.version, 7)
        self.assertEqual(value.variant, "specified in RFC 4122")
        self.assertTrue(is_asset_id(str(value)))

    def test_embeds_timestamp(self) -> None:
        value = uuid7(unix_ms=0x0192F3A47C1E, rand=bytes(10))
        self.assertEqual(str(value)[:13], "0192f3a4-7c1e")

    def test_orders_by_time(self) -> None:
        self.assertLess(str(uuid7(unix_ms=1_000)), str(uuid7(unix_ms=1_001)))

    def test_unique_in_bulk(self) -> None:
        values = {uuid7() for _ in range(10_000)}
        self.assertEqual(len(values), 10_000)


class IsAssetIdTest(unittest.TestCase):
    def test_rejects_other_versions_and_forms(self) -> None:
        for text in (
            "123e4567-e89b-12d3-a456-426614174000",
            "0192F3A4-7C1E-7B2A-9D4E-5F6A7B8C9D0E",
            "0192f3a4-7c1e-7b2a-cd4e-5f6a7b8c9d0e",
            "character-sprites/player-run",
            "",
        ):
            with self.subTest(text=text):
                self.assertFalse(is_asset_id(text))


if __name__ == "__main__":
    unittest.main()

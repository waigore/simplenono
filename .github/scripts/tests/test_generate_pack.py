"""Tests for generate_pack.py: the shipped pack and the generator agree."""
from __future__ import annotations

import collections
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import generate_pack  # noqa: E402
from new_asset_id import is_asset_id  # noqa: E402


class PackFileTest(unittest.TestCase):
    def setUp(self) -> None:
        self.entries = json.loads(generate_pack.PACK.read_text(encoding="utf-8"))

    def test_shipped_pack_is_current(self) -> None:
        self.assertEqual(self.entries, generate_pack.build())

    def test_sizes_match_the_entity(self) -> None:
        counts = collections.Counter(entry["size"] for entry in self.entries)
        self.assertEqual(counts, {10: 10, 15: 170, 20: 20})

    def test_fields_are_f1_to_f7(self) -> None:
        for entry in self.entries:
            self.assertEqual(set(entry), set(generate_pack.FIELDS))

    def test_clues_are_the_runs_of_fills(self) -> None:
        for entry in self.entries:
            size = entry["size"]
            fills = {tuple(cell) for cell in entry["solution-fills"]}
            rows = [generate_pack.runs([(r, c) in fills for c in range(size)]) for r in range(size)]
            columns = [generate_pack.runs([(r, c) in fills for r in range(size)]) for c in range(size)]
            self.assertEqual(rows, entry["row-clues"], entry["id"])
            self.assertEqual(columns, entry["col-clues"], entry["id"])

    def test_ids_and_pictures_are_unique(self) -> None:
        ids = [entry["id"] for entry in self.entries]
        pictures = [entry["picture-id"] for entry in self.entries]
        pixels = [entry["pixel-picture-id"] for entry in self.entries]
        self.assertEqual(len(set(ids)), 200)
        self.assertEqual(len(set(pictures)), 200)
        self.assertEqual(len(set(pixels)), 200)

    def test_picture_ids_are_asset_ids(self) -> None:
        for entry in self.entries:
            self.assertTrue(is_asset_id(entry["picture-id"]), entry["id"])
            self.assertTrue(is_asset_id(entry["pixel-picture-id"]), entry["id"])
            self.assertNotEqual(entry["picture-id"], entry["pixel-picture-id"])


if __name__ == "__main__":
    unittest.main()

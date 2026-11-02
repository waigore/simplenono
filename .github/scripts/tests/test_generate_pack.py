"""Tests for generate_pack.py: the shipped pack and the pixel-picture rule."""
from __future__ import annotations

import collections
import json
import random
import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import generate_pack  # noqa: E402
from new_asset_id import is_asset_id  # noqa: E402

WHITE = (255, 255, 255, 255)
BLACK = (0, 0, 0, 255)


def png_bytes(rows: list[list[tuple[int, ...]]], colour_type: int = 6) -> bytes:
    """A non-interlaced 8-bit PNG from rows of RGB (2) or RGBA (6) pixel tuples."""
    height = len(rows)
    width = len(rows[0]) if rows else 0
    channels = generate_pack.PNG_CHANNELS[colour_type]
    raw = bytearray()
    for row in rows:
        raw.append(0)
        for pixel in row:
            raw.extend(pixel[:channels])

    def chunk(kind: bytes, payload: bytes) -> bytes:
        checksum = zlib.crc32(kind + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", checksum)

    header = struct.pack(">IIBBBBB", width, height, 8, colour_type, 0, 0, 0)
    return (generate_pack.PNG_SIGNATURE + chunk(b"IHDR", header)
            + chunk(b"IDAT", zlib.compress(bytes(raw))) + chunk(b"IEND", b""))


def colour_board(size: int, cells: set[tuple[int, int]]) -> list[list[tuple[int, ...]]]:
    return [[BLACK if (row, column) in cells else WHITE for column in range(size)]
            for row in range(size)]


class PixelFixture(unittest.TestCase):
    """A throwaway repo root with a catalog root and an asset root."""

    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        (self.root / generate_pack.CATALOG_ROOT).mkdir(parents=True)
        (self.root / generate_pack.ASSET_ROOT / "puzzle-pictures").mkdir(parents=True)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def write_file(self, name: str, data: bytes) -> Path:
        path = self.root / generate_pack.ASSET_ROOT / "puzzle-pictures" / name
        path.write_bytes(data)
        return path

    def catalogue(self, pixel_id: str, entry: dict) -> Path:
        path = self.root / generate_pack.CATALOG_ROOT / f"{pixel_id}.json"
        path.write_text(json.dumps(entry), encoding="utf-8")
        return path

    def seeded_entries(self) -> list[dict]:
        """Every row from the seeded silhouette, with no catalog entries."""
        entries, index = [], 0
        for size, count in generate_pack.SIZES:
            for _ in range(count):
                entries.append(generate_pack.entry(index, size, random.Random(f"pack-{index:03d}")))
                index += 1
        return entries


class ShippedPackTest(unittest.TestCase):
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


class NoApprovedPixelTest(PixelFixture):
    """An empty catalog leaves every row on the seeded silhouette."""

    def test_missing_entry_falls_back(self) -> None:
        self.assertIsNone(generate_pack.pixel_fills(self.root, generate_pack.picture_ids(0)[1], 10))

    def test_pack_is_unchanged_without_approved_entries(self) -> None:
        self.assertEqual(generate_pack.build(self.root), self.seeded_entries())


class IneligibleEntryTest(PixelFixture):
    """Only an approved entry is used; every other state keeps the seeded row."""

    def assertFallsBack(self, entry: dict) -> None:
        pixel_id = generate_pack.picture_ids(0)[1]
        self.write_file("pack-000-pixel.png", png_bytes(colour_board(10, {(0, 0)})))
        self.catalogue(pixel_id, {"id": pixel_id, "files": ["puzzle-pictures/pack-000-pixel.png"], **entry})
        self.assertIsNone(generate_pack.pixel_fills(self.root, pixel_id, 10))

    def test_draft_falls_back(self) -> None:
        self.assertFallsBack({"state": "draft"})

    def test_deprecated_falls_back(self) -> None:
        self.assertFallsBack({"state": "deprecated"})

    def test_missing_state_falls_back(self) -> None:
        self.assertFallsBack({})


class DerivedRowTest(PixelFixture):
    """An approved pixel supplies the fills and both clue lists."""

    FILLS = {(0, 0), (0, 1), (0, 2), (5, 5)}

    def setUp(self) -> None:
        super().setUp()
        self.pixel_id = generate_pack.picture_ids(0)[1]
        self.write_file("pack-000-pixel.png", png_bytes(colour_board(10, self.FILLS)))
        self.catalogue(self.pixel_id, {
            "id": self.pixel_id,
            "state": "approved",
            "files": ["puzzle-pictures/pack-000-pixel.png"],
        })

    def test_pixel_fills_are_the_dark_cells(self) -> None:
        self.assertEqual(generate_pack.pixel_fills(self.root, self.pixel_id, 10), self.FILLS)

    def test_row_derives_fills_and_clue_shape(self) -> None:
        fills = generate_pack.pixel_fills(self.root, self.pixel_id, 10)
        row = generate_pack.entry(0, 10, random.Random("pack-000"), fills)
        self.assertEqual(row["solution-fills"], [[0, 0], [0, 1], [0, 2], [5, 5]])
        self.assertEqual(row["row-clues"], [[3], [], [], [], [], [1], [], [], [], []])
        self.assertEqual(row["col-clues"], [[1], [1], [1], [], [], [1], [], [], [], []])
        self.assertEqual(len(row["row-clues"]), 10)
        self.assertEqual(len(row["col-clues"]), 10)

    def test_ids_are_unchanged(self) -> None:
        seeded = generate_pack.entry(0, 10, random.Random("pack-000"))
        derived = generate_pack.entry(0, 10, random.Random("pack-000"), self.FILLS)
        for key in ("id", "size", "picture-id", "pixel-picture-id"):
            self.assertEqual(derived[key], seeded[key])
        self.assertNotEqual(derived["picture-id"], derived["pixel-picture-id"])

    def test_build_rewrites_only_the_catalogued_row(self) -> None:
        entries = generate_pack.build(self.root)
        seeded = self.seeded_entries()
        self.assertEqual(entries[0]["solution-fills"], [[0, 0], [0, 1], [0, 2], [5, 5]])
        self.assertEqual(entries[0]["row-clues"], [[3], [], [], [], [], [1], [], [], [], []])
        self.assertEqual(entries[1:], seeded[1:])


class AlphaCompositeTest(PixelFixture):
    """Alpha composites over white before luma; RGB files are accepted too."""

    def catalogue_board(self, rows: list[list[tuple[int, ...]]], colour_type: int) -> set:
        pixel_id = generate_pack.picture_ids(0)[1]
        self.write_file("pack-000-pixel.png", png_bytes(rows, colour_type))
        self.catalogue(pixel_id, {
            "id": pixel_id,
            "state": "approved",
            "files": ["puzzle-pictures/pack-000-pixel.png"],
        })
        return generate_pack.pixel_fills(self.root, pixel_id, 2)

    def test_transparent_black_is_white(self) -> None:
        rows = [[(0, 0, 0, 0), (0, 0, 0, 255)], [(127, 127, 127, 255), (129, 129, 129, 255)]]
        self.assertEqual(self.catalogue_board(rows, 6), {(0, 1), (1, 0)})

    def test_rgb_file_is_read(self) -> None:
        rows = [[(0, 0, 0), (255, 255, 255)], [(255, 255, 255), (0, 0, 0)]]
        self.assertEqual(self.catalogue_board(rows, 2), {(0, 0), (1, 1)})


class BrokenApprovedEntryTest(PixelFixture):
    """An approved entry that cannot be used is an error naming the id and path."""

    def setUp(self) -> None:
        super().setUp()
        self.pixel_id = generate_pack.picture_ids(0)[1]

    def assertFails(self, entry: dict, fragment: str) -> None:
        self.catalogue(self.pixel_id, {"id": self.pixel_id, "state": "approved", **entry})
        with self.assertRaises(generate_pack.PixelError) as caught:
            generate_pack.pixel_fills(self.root, self.pixel_id, 10)
        message = str(caught.exception)
        self.assertIn(self.pixel_id, message)
        self.assertIn(fragment, message)

    def test_no_files(self) -> None:
        self.assertFails({"files": []}, str(self.root / generate_pack.CATALOG_ROOT))

    def test_two_files(self) -> None:
        self.assertFails({"files": ["a.png", "b.png"]}, str(self.root / generate_pack.CATALOG_ROOT))

    def test_missing_file(self) -> None:
        name = "puzzle-pictures/pack-000-pixel.png"
        self.assertFails({"files": [name]}, str(self.root / generate_pack.ASSET_ROOT / name))

    def test_not_a_png(self) -> None:
        path = self.write_file("pack-000-pixel.png", b"not a png")
        self.assertFails({"files": ["puzzle-pictures/pack-000-pixel.png"]}, str(path))

    def test_wrong_size(self) -> None:
        path = self.write_file("pack-000-pixel.png", png_bytes(colour_board(5, {(0, 0)})))
        self.assertFails({"files": ["puzzle-pictures/pack-000-pixel.png"]}, str(path))

    def test_unreadable_entry(self) -> None:
        path = self.root / generate_pack.CATALOG_ROOT / f"{self.pixel_id}.json"
        path.write_text("{not json", encoding="utf-8")
        with self.assertRaises(generate_pack.PixelError) as caught:
            generate_pack.pixel_fills(self.root, self.pixel_id, 10)
        self.assertIn(self.pixel_id, str(caught.exception))
        self.assertIn(str(path), str(caught.exception))


if __name__ == "__main__":
    unittest.main()

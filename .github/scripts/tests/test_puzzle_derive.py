"""Tests for puzzle_derive.py: flatten, BOX downsample, fills, and the judge."""
from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import puzzle_derive  # noqa: E402

BACKGROUND = (224, 226, 228)
SUBJECT = (48, 56, 66)


def square(size: int, subject: set[tuple[int, int]],
           background: tuple[int, int, int] = BACKGROUND) -> list[list[tuple[int, int, int, int]]]:
    return [[(*(SUBJECT if (row, column) in subject else background), 255)
             for column in range(size)] for row in range(size)]


def rectangle(top: int, bottom: int, left: int, right: int) -> set[tuple[int, int]]:
    return {(row, column) for row in range(top, bottom) for column in range(left, right)}


class FlattenTest(unittest.TestCase):
    def test_dark_vignette_frame_is_replaced_by_background(self) -> None:
        size = 20
        rows = square(size, set())
        for row in range(size):
            for column in range(size):
                if row < 1 or row >= size - 1 or column < 1 or column >= size - 1:
                    rows[row][column] = (10, 12, 14, 255)
        flat, report = puzzle_derive.flatten_vignette(rows)
        self.assertEqual(report["background_rgb"], [10, 12, 14])
        for row in range(size):
            for column in range(size):
                if row < 1 or row >= size - 1 or column < 1 or column >= size - 1:
                    self.assertEqual(flat[row][column], (10, 12, 14, 255))
        self.assertEqual(flat[10][10], (*BACKGROUND, 255))

    def test_background_comes_from_the_outer_ring_not_the_subject(self) -> None:
        rows = square(100, rectangle(20, 80, 20, 80))
        _, report = puzzle_derive.flatten_vignette(rows)
        self.assertEqual(report["background_rgb"], list(BACKGROUND))
        self.assertEqual(report["ring_pixels"], 1)
        self.assertEqual(report["band_pixels"], 5)


class DownsampleTest(unittest.TestCase):
    def test_fractional_box_to_exact_size(self) -> None:
        cells = puzzle_derive.box_downsample(square(1024, rectangle(0, 1024, 0, 1024)), 10)
        self.assertEqual(len(cells), 10)
        self.assertTrue(all(len(line) == 10 for line in cells))
        self.assertEqual(cells[0][0], SUBJECT)

    def test_uniform_square_stays_uniform(self) -> None:
        cells = puzzle_derive.box_downsample(square(50, set()), 10)
        self.assertTrue(all(cell == BACKGROUND for line in cells for cell in line))

    def test_alpha_is_composited_over_white(self) -> None:
        rows = [[(0, 0, 0, 0)] * 10 for _ in range(10)]
        cells = puzzle_derive.box_downsample(rows, 10)
        self.assertEqual(cells[0][0], (255, 255, 255))


class FillsTest(unittest.TestCase):
    def test_fixed_luma_threshold_with_alpha_over_white(self) -> None:
        rows = [[(255, 255, 255, 255)] * 10 for _ in range(10)]
        rows[0][0] = (0, 0, 0, 255)
        rows[1][1] = (0, 0, 0, 0)
        rows[2][2] = (128, 128, 128, 255)
        rows[3][3] = (127, 128, 128, 255)
        self.assertEqual(puzzle_derive.fills(rows, 10), {(0, 0), (3, 3)})

    def test_wrong_size_is_rejected(self) -> None:
        with self.assertRaises(puzzle_derive.PictureError):
            puzzle_derive.fills([[(255, 255, 255, 255)] * 3], 10)


class JudgeTest(unittest.TestCase):
    def test_solid_rectangle_is_unique_and_line_solved(self) -> None:
        fill_set = rectangle(2, 7, 2, 7)
        result = puzzle_derive.judge(fill_set, 10)
        self.assertEqual(result["filled"], 25)
        self.assertTrue(result["in_band"])
        self.assertTrue(result["unique"])
        self.assertTrue(result["logic_solved"])
        self.assertTrue(result["matches_pixel"])

    def test_ambiguous_diagonal_has_two_solutions(self) -> None:
        fill_set = {(0, 0), (1, 1)}
        result = puzzle_derive.judge(fill_set, 2)
        self.assertFalse(result["unique"])
        self.assertEqual(result["solutions"], 2)
        self.assertFalse(result["logic_solved"])

    def test_clues_are_run_lengths(self) -> None:
        row_clues, col_clues = puzzle_derive.clues({(0, 0), (0, 2), (1, 1)}, 3)
        self.assertEqual(row_clues, [[1, 1], [1], []])
        self.assertEqual(col_clues, [[1], [1], [1]])

    def test_empty_grid_is_unique_but_out_of_band(self) -> None:
        result = puzzle_derive.judge(set(), 10)
        self.assertEqual(result["filled"], 0)
        self.assertFalse(result["in_band"])
        self.assertTrue(result["unique"])
        self.assertTrue(result["logic_solved"])

    def test_band_is_size_relative(self) -> None:
        self.assertEqual(puzzle_derive.fill_band(10), (25, 45))
        self.assertEqual(puzzle_derive.fill_band(15), (56, 101))
        self.assertEqual(puzzle_derive.fill_band(20), (100, 180))

    def test_sixty_fills_is_in_band_at_15_but_not_at_10(self) -> None:
        fill_set = rectangle(0, 4, 0, 15)
        at_fifteen = puzzle_derive.judge(fill_set, 15)
        self.assertEqual(at_fifteen["filled"], 60)
        self.assertEqual(at_fifteen["band"], [56, 101])
        self.assertTrue(at_fifteen["in_band"])
        at_ten = puzzle_derive.judge(fill_set, 10)
        self.assertEqual(at_ten["band"], [25, 45])
        self.assertFalse(at_ten["in_band"])

    def test_band_edges_are_inclusive(self) -> None:
        at_low = puzzle_derive.judge(rectangle(0, 4, 0, 14), 15)
        self.assertEqual(at_low["filled"], 56)
        self.assertTrue(at_low["in_band"])
        at_high = puzzle_derive.judge(rectangle(0, 9, 0, 9), 15)
        self.assertEqual(at_high["filled"], 81)
        self.assertTrue(at_high["in_band"])
        just_below = puzzle_derive.judge(rectangle(0, 4, 0, 14) - {(3, 13)}, 15)
        self.assertEqual(just_below["filled"], 55)
        self.assertFalse(just_below["in_band"])
        self.assertEqual(puzzle_derive.judge(rectangle(0, 7, 0, 19), 20)["band"], [100, 180])


class DeriveTest(unittest.TestCase):
    def test_derive_is_byte_reproducible_and_in_band(self) -> None:
        rows = square(100, rectangle(20, 80, 20, 80))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            square_path, first, second = root / "square.png", root / "a.png", root / "b.png"
            puzzle_derive.write_png(square_path, [[pixel[:3] for pixel in line] for line in rows])
            first_report = puzzle_derive.derive(square_path, first, 10)
            puzzle_derive.derive(square_path, second, 10)
            self.assertEqual(first.read_bytes(), second.read_bytes())
            self.assertEqual(first_report["verdict"], "pass")
            self.assertEqual(first_report["filled"], 36)
            self.assertEqual(len(puzzle_derive.read_png(first)), 10)


if __name__ == "__main__":
    unittest.main()

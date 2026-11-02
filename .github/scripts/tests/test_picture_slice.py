"""Tests for picture_slice.py: target parsing, board configs, and prompt composition.

The script's network and derive steps are not exercised here; these tests cover the
pure helpers that decide the board size and the prompt a slice sends.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import picture_slice  # noqa: E402


class ParseTargetTest(unittest.TestCase):
    def test_bare_class_uses_the_default_board(self) -> None:
        self.assertEqual(picture_slice.parse_target("pack-004=multi"),
                         ("pack-004", "multi", picture_slice.DEFAULT_BOARD))

    def test_board_prefix_selects_that_board(self) -> None:
        self.assertEqual(picture_slice.parse_target("pack-010=15x15:single"),
                         ("pack-010", "single", "15x15"))

    def test_unknown_board_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("pack-010=24x24:single")

    def test_unknown_class_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("pack-010=15x15:huge")

    def test_missing_key_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("=15x15:single")


class BoardConfigTest(unittest.TestCase):
    def test_every_board_has_a_derive_size_matching_its_name(self) -> None:
        for name, config in picture_slice.BOARDS.items():
            self.assertEqual(config["size"], int(name.split("x")[0]), name)
            self.assertTrue(config["single"], name)
            self.assertTrue(config["multi"], name)

    def test_prompts_name_their_own_board(self) -> None:
        for name in picture_slice.BOARDS:
            for klass in ("single", "multi"):
                for prompt in picture_slice.prompts_for(klass, name):
                    self.assertIn(f"readable as a {name} icon", prompt, (name, klass))

    def test_15x15_single_leads_with_a_single_outline(self) -> None:
        first = picture_slice.prompts_for("single", "15x15")[0]
        self.assertIn("the outline of", first)
        self.assertIn("pale background", first)

    def test_15x15_class_sets_differ_and_multi_keeps_a_second_mass(self) -> None:
        single = picture_slice.prompts_for("single", "15x15")
        multi = picture_slice.prompts_for("multi", "15x15")
        self.assertNotEqual(single, multi)
        self.assertTrue(any("gap between them" in prompt for prompt in multi))

    def test_compose_carries_master_and_negative(self) -> None:
        composed = picture_slice.compose("a shape", "15x15")
        self.assertIn("readable at 15x15", composed)
        self.assertIn(picture_slice.NEGATIVE, composed)
        self.assertTrue(composed.startswith("a shape. "))


if __name__ == "__main__":
    unittest.main()

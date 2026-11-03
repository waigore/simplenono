"""Tests for picture_slice.py: target parsing, board configs, and prompt composition.

The script's network and derive steps are not exercised here; these tests cover the
pure helpers that decide the board size and the prompt a slice sends.
"""
from __future__ import annotations

import subprocess
import sys
import types
import unittest
from pathlib import Path
from unittest import mock

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


class TransientErrorTest(unittest.TestCase):
    def test_rate_limit_and_gateway_errors_are_transient(self) -> None:
        for code in picture_slice.TRANSIENT_HTTP_CODES:
            self.assertTrue(picture_slice.is_transient(f"Cheaper Inference {code}: nope"))

    def test_a_missing_key_or_bad_request_aborts(self) -> None:
        self.assertFalse(picture_slice.is_transient("Cheaper Inference HTTP 401: bad key"))
        self.assertFalse(picture_slice.is_transient("HTTP 422: no such model"))

    def test_generate_retries_a_transient_error_then_succeeds(self) -> None:
        calls = []
        results = [subprocess.CompletedProcess([], 1, "", "Cheaper Inference HTTP 503: busy"),
                   subprocess.CompletedProcess([], 0, '{"out": "square.jpg"}\n', "")]

        def fake_run(*_args, **_kwargs):
            calls.append(1)
            return results[len(calls) - 1]

        class FakeImage:
            def __enter__(self):
                return self

            def __exit__(self, *_exc):
                return False

            def convert(self, _mode):
                return types.SimpleNamespace(save=lambda *_a, **_k: None)

        fake_pil = types.ModuleType("PIL")
        fake_pil.Image = types.SimpleNamespace(open=lambda _path: FakeImage())
        with mock.patch.object(picture_slice.subprocess, "run", fake_run), \
                mock.patch.dict(sys.modules, {"PIL": fake_pil}), \
                mock.patch.object(picture_slice.time, "sleep") as sleep, \
                mock.patch.object(Path, "unlink"), \
                mock.patch.object(picture_slice, "generate", wraps=picture_slice.generate) as real:
            out, meta = real("a prompt", Path("."), "pack-130", 1, "key", retries=2, wait=5.0)
        self.assertEqual(meta, {"out": "square.jpg"})
        self.assertEqual(out, Path("pack-130-attempt1.png"))
        self.assertEqual(len(calls), 2)
        sleep.assert_called_once_with(5.0)

    def test_generate_gives_up_after_the_last_retry(self) -> None:
        def fake_run(*_args, **_kwargs):
            return subprocess.CompletedProcess([], 1, "", "Cheaper Inference HTTP 503: busy")

        with mock.patch.object(picture_slice.subprocess, "run", fake_run), \
                mock.patch.object(picture_slice.time, "sleep") as sleep:
            with self.assertRaises(SystemExit):
                picture_slice.generate("a prompt", Path("."), "pack-130", 1, "key",
                                       retries=2, wait=5.0)
        self.assertEqual(sleep.call_count, 2)


if __name__ == "__main__":
    unittest.main()

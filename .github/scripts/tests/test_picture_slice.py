"""Tests for picture_slice.py: attempt plans, target parsing, and bookkeeping.

The script's network and derive steps are not exercised here; these tests cover
the pure helpers that read the attempt plan and decide the board a slice derives.
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


def plan(size_board: str = "10x10") -> dict:
    return {"pack-004": {"board": size_board, "prompts": ["p1", "p2"]},
            "pack-010": {"board": "15x15", "prompts": ["p1"]}}


class ParseTargetTest(unittest.TestCase):
    def test_bare_key_uses_the_plan_board(self) -> None:
        self.assertEqual(picture_slice.parse_target("pack-010", plan()),
                         ("pack-010", "15x15", ["p1"]))

    def test_known_board_default_applies_when_the_plan_omits_it(self) -> None:
        raw = {"pack-004": {"prompts": ["p1", "p2"]}}
        self.assertEqual(picture_slice.parse_target("pack-004", raw),
                         ("pack-004", picture_slice.DEFAULT_BOARD, ["p1", "p2"]))

    def test_board_prefix_overrides_the_plan_board(self) -> None:
        self.assertEqual(picture_slice.parse_target("pack-004=15x15", plan()),
                         ("pack-004", "15x15", ["p1", "p2"]))

    def test_unknown_board_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("pack-004=24x24", plan())

    def test_missing_key_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("=15x15", plan())

    def test_unknown_key_is_rejected(self) -> None:
        with self.assertRaises(SystemExit):
            picture_slice.parse_target("pack-130", plan())


class AttemptPlanTest(unittest.TestCase):
    def write_plan(self, text: str, tmp: Path) -> Path:
        path = tmp / "attempt_prompts.json"
        path.write_text(text)
        return picture_slice.load_attempt_plan(path)

    def test_reads_boards_and_prompts(self) -> None:
        import json
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            loaded = self.write_plan(json.dumps(plan()), Path(tmp))
        self.assertEqual(loaded, plan())

    def test_board_defaults_to_the_default_board(self) -> None:
        import json
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            loaded = self.write_plan('{"pack-004": {"prompts": ["p1"]}}', Path(tmp))
        self.assertEqual(loaded["pack-004"]["board"], picture_slice.DEFAULT_BOARD)

    def test_unknown_board_is_rejected(self) -> None:
        import json
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(SystemExit):
                self.write_plan(json.dumps({"pack-004": {"board": "24x24",
                                                         "prompts": ["p1"]}}), Path(tmp))

    def test_missing_prompts_are_rejected(self) -> None:
        import json
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(SystemExit):
                self.write_plan('{"pack-004": {"board": "10x10"}}', Path(tmp))

    def test_empty_attempt_prompts_are_rejected(self) -> None:
        import json
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(SystemExit):
                self.write_plan('{"pack-004": {"board": "10x10", "prompts": ["p1", ""]}}',
                                Path(tmp))

    def test_empty_plan_is_rejected(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(SystemExit):
                self.write_plan("{}", Path(tmp))


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

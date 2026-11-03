"""Tests for strip_subject_class.py: the catalog rewrite that drops the class tag.

#486 (product owner, 2026-11-03) retired the per-puzzle single/multi subject
class, so `generation.settings.subject_class` and the class words in
`review.report` must go while every other field and every judged measurement
stays.
"""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import strip_subject_class  # noqa: E402

SQUARE_REPORT = (
    "AK-puzzle-pictures R1/V1, pack-004 (single-subject). Generated square: "
    "flux-2-max 1024x1024, saved as PNG without resampling. Meets K6 (square stored). "
    "The stored 15x15 pixel silhouette is one connected plus-shaped mass "
    "(single-subject). Calm clinical (AES.P1, K4). Subject class: single-subject. "
    "No series (SS1 none). License: Cheaper Inference terms."
)
PIXEL_REPORT = (
    "AK-puzzle-pictures R1/V1, pack-005 (multi-subject and/or holed). Derived from "
    "the generated square. Filled 80/225. Pixel look: silhouette two separate equal "
    "slabs with a clear vertical gap (AES.P1, K4). Subject class: "
    "multi-subject and/or holed. No series (SS1 none)."
)
REPAIR_REPORT = (
    "AK-puzzle-pictures R1/V1, pack-139. Regenerated for the #267 verification repair, "
    "because pack-139 was not multi-subject and/or holed. Look: the square reads as "
    "two blocks. No series (SS1 none)."
)


def entry(report: str, subject_class: str = "single-subject") -> dict:
    return {
        "kind_spec": "AK-puzzle-pictures",
        "coverage": ["V1"],
        "state": "approved",
        "generation": {"tool": "Cheaper Inference",
                       "settings": {"model": "flux-2-max", "size": "1024x1024",
                                    "subject_class": subject_class}},
        "review": {"verdict": "Pass", "report": report},
    }


class StripReportTest(unittest.TestCase):
    def test_square_report_keeps_every_measurement(self) -> None:
        text = strip_subject_class.strip_report(SQUARE_REPORT)
        for kept in ("flux-2-max 1024x1024", "Meets K6 (square stored)",
                     "one connected plus-shaped mass", "AES.P1, K4", "SS1 none"):
            self.assertIn(kept, text)
        self.assertNotIn("single-subject", text)
        self.assertNotIn("not multi-subject", text)

    def test_pixel_report_keeps_its_silhouette(self) -> None:
        text = strip_subject_class.strip_report(PIXEL_REPORT)
        self.assertIn("silhouette two separate equal slabs with a clear vertical gap", text)
        self.assertIn("Filled 80/225", text)
        self.assertNotIn("not multi-subject", text)

    def test_repair_note_loses_the_class_and_keeps_the_rest(self) -> None:
        text = strip_subject_class.strip_report(REPAIR_REPORT)
        self.assertIn("Regenerated for the #267 verification repair", text)
        self.assertIn("two blocks", text)
        self.assertNotIn("not multi-subject", text)

    def test_report_without_a_class_is_unchanged(self) -> None:
        plain = "Generated square; silhouette one ring around a hole (K4)."
        self.assertEqual(strip_subject_class.strip_report(plain), plain)


class TrimEntryTest(unittest.TestCase):
    def test_tag_and_report_words_go_and_the_report_says_why(self) -> None:
        data = entry(SQUARE_REPORT)
        self.assertTrue(strip_subject_class.trim_entry(data))
        self.assertNotIn("subject_class", data["generation"]["settings"])
        self.assertEqual(data["generation"]["settings"]["model"], "flux-2-max")
        report = data["review"]["report"]
        self.assertNotIn("Subject class: single-subject", report)
        self.assertNotIn("mass (single-subject)", report)
        self.assertIn("Class tag removed on 2026-11-03.", report)
        self.assertIn(strip_subject_class.CLASSLESS_NOTE, report)

    def test_nothing_else_changes(self) -> None:
        data = entry(PIXEL_REPORT, "multi-subject and/or holed")
        before = json.loads(json.dumps(data))
        strip_subject_class.trim_entry(data)
        before["generation"]["settings"].pop("subject_class")
        before["review"].pop("report")
        after = json.loads(json.dumps(data))
        after["review"].pop("report")
        self.assertEqual(before, after)

    def test_a_second_pass_changes_nothing(self) -> None:
        data = entry(SQUARE_REPORT)
        strip_subject_class.trim_entry(data)
        report = data["review"]["report"]
        self.assertFalse(strip_subject_class.trim_entry(data))
        self.assertEqual(data["review"]["report"], report)
        self.assertNotIn("Subject class:", report)


class MainTest(unittest.TestCase):
    def test_rewrite_strips_both_entries_then_check_is_green(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "a.json").write_text(json.dumps(entry(SQUARE_REPORT)), encoding="utf-8")
            (root / "b.json").write_text(json.dumps(entry(PIXEL_REPORT)), encoding="utf-8")
            self.assertEqual(strip_subject_class.main(["--root", str(root)]), 0)
            for path in root.glob("*.json"):
                data = json.loads(path.read_text(encoding="utf-8"))
                self.assertNotIn("subject_class", data["generation"]["settings"])
                report = data["review"]["report"]
                self.assertNotIn("Subject class:", report)
                self.assertNotIn("(single-subject)", report)
                self.assertIn("Class tag removed on 2026-11-03.", report)
            self.assertEqual(strip_subject_class.main(["--root", str(root), "--check"]), 0)
            self.assertEqual(strip_subject_class.main(["--root", str(root)]), 0)

    def test_dry_run_writes_nothing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / "a.json"
            path.write_text(json.dumps(entry(SQUARE_REPORT)), encoding="utf-8")
            before = path.read_text(encoding="utf-8")
            self.assertEqual(strip_subject_class.main(["--root", str(root), "--dry-run"]), 0)
            self.assertEqual(path.read_text(encoding="utf-8"), before)

    def test_missing_root_is_an_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            missing = Path(tmp) / "nope"
            self.assertEqual(strip_subject_class.main(["--root", str(missing)]), 2)


if __name__ == "__main__":
    unittest.main()

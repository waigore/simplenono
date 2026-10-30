"""Tests for pr_hygiene.py."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from pr_hygiene import REQUIRED_SECTIONS, TEMPLATE, PullRequest, closing_keywords, lint, template_sections, title_format  # noqa: E402

FILLED_BODY = "\n".join(f"## {name}\n\n<!-- hint -->\nSomething about {name}.\n" for name in REQUIRED_SECTIONS)


def body(text: str) -> PullRequest:
    return PullRequest("Add HUD layout", text)


class ClosingKeywordsTest(unittest.TestCase):
    def test_flags_every_keyword_form(self) -> None:
        for kw in ("close", "closes", "closed", "fix", "fixes", "fixed", "resolve", "resolves", "resolved"):
            for text in (f"{kw} #12", f"{kw.upper()} #12", f"{kw.title()}: #12", f"{kw}:#12"):
                with self.subTest(text=text):
                    self.assertTrue(closing_keywords(body(text)))

    def test_flags_cross_repo_and_url_refs(self) -> None:
        self.assertTrue(closing_keywords(body("Fixes octo/game#7")))
        self.assertTrue(closing_keywords(body("Resolves https://github.com/octo/game/issues/7")))

    def test_flags_title(self) -> None:
        [finding] = closing_keywords(PullRequest("Fix #12 jump input", ""))
        self.assertEqual((finding.field, finding.line), ("title", 1))

    def test_reports_line_numbers(self) -> None:
        [finding] = closing_keywords(body("Summary\n\nRefs #1\nCloses #2"))
        self.assertEqual((finding.field, finding.line), ("body", 4))

    def test_allows_refs_and_prose(self) -> None:
        for text in ("Refs #12", "Fixes the jump bug", "closed-loop control, see #12", "prefix #12", "Never Closes/Fixes/Resolves"):
            with self.subTest(text=text):
                self.assertEqual(closing_keywords(body(text)), [])


class TitleFormatTest(unittest.TestCase):
    def test_accepts_good_title(self) -> None:
        self.assertEqual(title_format(PullRequest("Add HUD layout", "")), [])

    def test_flags_empty_long_and_period(self) -> None:
        self.assertIn("empty", title_format(PullRequest("  ", ""))[0].message)
        self.assertIn("characters", title_format(PullRequest("A" * 73, ""))[0].message)
        self.assertIn("period", title_format(PullRequest("Add HUD layout.", ""))[0].message)


class TemplateSectionsTest(unittest.TestCase):
    def test_template_defines_sections(self) -> None:
        self.assertEqual(REQUIRED_SECTIONS, ["Summary", "Issue", "Authority", "Changes", "Test plan", "Evidence"])

    def test_accepts_filled_body(self) -> None:
        self.assertEqual(template_sections(body(FILLED_BODY)), [])

    def test_unfilled_template_flags_every_section(self) -> None:
        findings = template_sections(body(TEMPLATE.read_text(encoding="utf-8")))
        self.assertEqual(len(findings), len(REQUIRED_SECTIONS))
        self.assertTrue(all("empty" in f.message for f in findings))

    def test_flags_missing_section(self) -> None:
        [finding] = template_sections(body(FILLED_BODY.replace("## Evidence", "## Notes")))
        self.assertIn("missing section '## Evidence'", finding.message)

    def test_flags_bare_na_but_accepts_na_with_reason(self) -> None:
        bare = FILLED_BODY.replace("Something about Evidence.", "N/A")
        [finding] = template_sections(body(bare))
        self.assertIn("without a reason", finding.message)
        reasoned = FILLED_BODY.replace("Something about Evidence.", "N/A (docs-only change)")
        self.assertEqual(template_sections(body(reasoned)), [])

    def test_heading_match_is_case_insensitive(self) -> None:
        self.assertEqual(template_sections(body(FILLED_BODY.replace("## Test plan", "## Test Plan"))), [])


class LintTest(unittest.TestCase):
    def test_good_pr_passes_all_rules(self) -> None:
        self.assertEqual(lint(body(FILLED_BODY.replace("Something about Issue.", "Refs #12"))), [])


if __name__ == "__main__":
    unittest.main()

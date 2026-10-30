"""Tests for spec_lint.py: copy the real specs/ and rules into a temp tree, inject one violation, assert it is caught."""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
REPO = SCRIPTS.parents[1]
sys.path.insert(0, str(SCRIPTS))

import spec_lint  # noqa: E402

FEATURE_TEMPLATE = "specs/design/features/_template.md"
FEATURE = "specs/design/features/movement.md"


class SpecLintTest(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        tracked = subprocess.run(
            ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"], cwd=REPO, check=True, capture_output=True, text=True
        ).stdout.split("\0")
        for rel in filter(None, tracked):
            if (REPO / rel).is_file():
                (self.root / rel).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPO / rel, self.root / rel)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def read(self, rel: str) -> str:
        return (self.root / rel).read_text(encoding="utf-8")

    def write(self, rel: str, text: str) -> None:
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def edit(self, rel: str, old: str, new: str) -> None:
        text = self.read(rel)
        self.assertIn(old, text, f"fixture drift: {old!r} not in {rel}")
        self.write(rel, text.replace(old, new, 1))

    def errors(self, check: str | None = None) -> list[spec_lint.Finding]:
        return [
            f for f in spec_lint.run(self.root)
            if f.severity == "error" and (check is None or f.check == check)
        ]

    def add_feature(self, transform=lambda text: text) -> None:
        lines = self.read(FEATURE_TEMPLATE).splitlines(keepends=True)
        body = "".join(l for l in lines if "<!-- Template:" not in l)
        self.write(FEATURE, transform(body))
        self.edit("specs/design/design.md", "## Index\n", "## Index\n\n[`movement.md`](features/movement.md)\n")

    def test_repo_is_clean(self) -> None:
        self.assertEqual(self.errors(), [])

    def test_clean_copy_passes(self) -> None:
        self.add_feature()
        self.assertEqual(self.errors(), [])

    def test_missing_rules_line(self) -> None:
        self.add_feature(lambda t: "\n".join(l for l in t.splitlines() if not l.startswith("Authoring rules:")))
        self.assertEqual(len(self.errors("rules-line")), 1)

    def test_wrong_rules_target(self) -> None:
        self.add_feature(lambda t: t.replace("rules/design/features.md)", "rules/design/loops.md)"))
        self.assertIn("expected .agents/specs/rules/design/features.md", self.errors("rules-line")[0].message)

    def test_split_and_story_paths_use_parent_rules(self) -> None:
        table = spec_lint.RulesTable(spec_lint.Repo(self.root))
        self.assertEqual(table.lookup("specs/design/glossary/combat.md"), ".agents/specs/rules/design/glossary.md")
        self.assertEqual(table.lookup("specs/design/stories/features/movement.md"), ".agents/specs/rules/design/story.md")
        self.assertEqual(table.lookup("specs/technical/_templates/failures.md"), ".agents/specs/rules/technical/failures.md")

    def test_template_comment_left_in_copy(self) -> None:
        self.add_feature(lambda t: t + "\n<!-- Template: copy to features/<kebab-name>.md -->\n")
        self.assertEqual(len(self.errors("template-copy")), 1)

    def test_non_kebab_file_name(self) -> None:
        self.write("specs/design/features/Movement.md", self.read(FEATURE_TEMPLATE))
        messages = [f.message for f in self.errors("template-copy")]
        self.assertTrue(any("not kebab-case" in m for m in messages))

    def test_template_filled_in_place(self) -> None:
        self.edit(FEATURE_TEMPLATE, "## Purpose\n\n<!-- fill in -->", "## Purpose\n\nLet the player run and jump.")
        self.assertTrue(self.errors("template-copy"))

    def test_missing_heading(self) -> None:
        self.add_feature(lambda t: t.replace("## Edge cases\n", ""))
        self.assertIn("'Edge cases'", self.errors("skeleton")[0].message)

    def test_optional_global_copy_keeps_skeleton(self) -> None:
        text = self.read("specs/technical/_templates/failures.md").replace("## Recovery\n", "")
        self.write("specs/technical/failures.md", "\n".join(l for l in text.splitlines() if "<!-- Template:" not in l))
        self.assertIn("'Recovery'", self.errors("skeleton")[0].message)

    def test_bare_na(self) -> None:
        self.add_feature(lambda t: t.replace("## Parameters\n\n- <!-- fill in -->", "## Parameters\n\n- **Speed**: N/A"))
        self.assertEqual(len(self.errors("bare-na")), 1)

    def test_na_with_reason_passes(self) -> None:
        self.add_feature(lambda t: t.replace("## Parameters\n\n- <!-- fill in -->", "## Parameters\n\n- **Speed**: N/A — turn-based"))
        self.assertEqual(self.errors("bare-na"), [])

    def test_bare_tbd(self) -> None:
        self.add_feature(lambda t: t.replace("## Parameters\n\n- <!-- fill in -->", "## Parameters\n\n- **Speed**: TBD\n\n| Rule | TBD. |"))
        self.assertEqual(len(self.errors("bare-tbd")), 2)

    def test_tbd_with_question_passes(self) -> None:
        self.add_feature(lambda t: t.replace("## Parameters\n\n- <!-- fill in -->", "## Parameters\n\n- **Speed**: TBD — fixed or ramping?\n\nTBD - does it stack? Uses `TBD` and TBDs."))
        self.assertEqual(self.errors("bare-tbd"), [])

    def test_broken_link(self) -> None:
        self.add_feature(lambda t: t + "\nSee [jump](jump.md).\n")
        self.assertIn("jump.md", self.errors("links")[0].message)

    def test_orphan(self) -> None:
        self.write("specs/design/loops/combat.md", self.read("specs/design/loops/_template.md"))
        self.assertTrue(any(f.path == "specs/design/loops/combat.md" for f in self.errors("orphans")))

    def test_glossary_order_and_duplicates(self) -> None:
        rows = "| Zone | An area. | here |\n| Avatar | The player. | here |\n| zone | Again. | here |\n"
        self.edit("specs/design/glossary.md", "| <!-- fill in -->", rows + "| <!-- fill in -->")
        messages = [f.message for f in self.errors("glossary")]
        self.assertTrue(any("alphabetical" in m for m in messages))
        self.assertTrue(any("defined twice" in m for m in messages))


    def test_word_limit(self) -> None:
        self.write("docs/long.md", "word " * (spec_lint.WORD_LIMIT + 1))
        self.assertEqual([f.path for f in self.errors("word-limit")], ["docs/long.md"])

    def test_word_limit_boundary_passes(self) -> None:
        self.write("specs/long.md", "word " * spec_lint.WORD_LIMIT)
        self.assertEqual(self.errors("word-limit"), [])

if __name__ == "__main__":
    unittest.main()

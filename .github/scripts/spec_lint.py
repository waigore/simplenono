#!/usr/bin/env python3
"""Structural lint for specs/ against the authoring conventions in .agents/specs/rules/.

Checks (see docs/spec-lint.md):
  rules-line     every spec links the rules file the path table assigns it
  template-copy  copies drop the template comment, use kebab-case names, and
                 templates hold only placeholders
  skeleton       copies keep every non-optional heading of their template, in order
  bare-na        N/A table cells and bullet values give a reason
  bare-tbd       TBD markers state the open question
  links          relative Markdown links resolve
  orphans        every spec file is linked from another spec file
  glossary       glossary terms are unique and alphabetical
  word-limit     Markdown in docs/ and specs/ stays within WORD_LIMIT words

Usage: spec_lint.py [--root DIR] [--strict]
Exit 1 on any error; warnings exit 1 only with --strict.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Callable, Iterable

SPECS = "specs"
RULES_README = ".agents/specs/rules/README.md"
LINK_ROOTS = ("specs", "docs", ".agents")
OPTIONAL_TEMPLATES = "specs/technical/_templates/"
WORD_LIMIT_ROOTS = ("docs", "specs")
WORD_LIMIT = 500

COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
FENCE_RE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE_RE = re.compile(r"`[^`]*`")
INLINE_LINK_RE = re.compile(r"!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
REF_LINK_RE = re.compile(r"^\s*\[[^\]]+\]:\s*<?(\S+?)>?(?:\s+.*)?$")
RULES_LINE_RE = re.compile(r"^Authoring rules: \[[^\]]*\]\(([^)]+)\)")
TABLE_ROW_RE = re.compile(r"^\s*\|.*\|\s*$")
TABLE_SEP_RE = re.compile(r"^\s*\|(\s*:?-+:?\s*\|)+\s*$")
BULLET_VALUE_RE = re.compile(r"^\s*[-*]\s+\*\*[^*]+\*\*:\s*(.*)$")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
KEBAB_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
BARE_NA_RE = re.compile(r"^N/?A\.?$", re.I)
BARE_TBD_RE = re.compile(r"(?<!\w)TBD(?!\w)(?!\s*[—-]+\s*\S)")
EXTERNAL_RE = re.compile(r"^(?:[a-z][a-z0-9+.-]*:|#)", re.I)


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    check: str
    message: str
    severity: str = "error"


@dataclass
class Doc:
    rel: str
    lines: list[str]

    @property
    def text(self) -> str:
        return "\n".join(self.lines)


class Repo:
    """Read-only view of the files the checks inspect."""

    def __init__(self, root: Path):
        self.root = root
        self._cache: dict[str, Doc] = {}

    def exists(self, rel: str) -> bool:
        return (self.root / rel).exists()

    def doc(self, rel: str) -> Doc:
        if rel not in self._cache:
            text = (self.root / rel).read_text(encoding="utf-8")
            self._cache[rel] = Doc(rel, text.splitlines())
        return self._cache[rel]

    def files(self, top: str, suffixes: tuple[str, ...]) -> list[str]:
        base = self.root / top
        if not base.is_dir():
            return []
        out = []
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
            for name in sorted(filenames):
                if name.endswith(suffixes) and not name.startswith("."):
                    out.append(Path(dirpath, name).relative_to(self.root).as_posix())
        return out

    def spec_markdown(self) -> list[str]:
        return self.files(SPECS, (".md",))


def is_template(rel: str) -> bool:
    name = PurePosixPath(rel).name
    return name.startswith("_template.") or (rel.startswith(OPTIONAL_TEMPLATES) and name != "README.md")


def norm(path: str) -> str:
    return os.path.normpath(path).replace(os.sep, "/")


def strip_comments(text: str) -> str:
    return COMMENT_RE.sub("", text).strip()


def prose_lines(doc: Doc) -> Iterable[tuple[int, str]]:
    """Yield (line number, line) outside fenced code blocks, with inline code removed."""
    in_fence = False
    for i, line in enumerate(doc.lines, 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            yield i, INLINE_CODE_RE.sub("", line)


def split_cells(row: str) -> list[str]:
    return [c.strip() for c in row.strip().strip("|").split("|")]


def headings(doc: Doc, max_level: int = 6) -> list[tuple[int, int, str]]:
    out = []
    for i, line in prose_lines(doc):
        m = HEADING_RE.match(line)
        if m and len(m.group(1)) <= max_level:
            out.append((i, len(m.group(1)), m.group(2)))
    return out


def link_targets(doc: Doc) -> Iterable[tuple[int, str]]:
    for i, line in prose_lines(doc):
        for m in INLINE_LINK_RE.finditer(line):
            yield i, m.group(1)
        m = REF_LINK_RE.match(line)
        if m:
            yield i, m.group(1)


def resolve_link(source: str, target: str) -> str | None:
    """Repo-relative path a relative link points at, or None for external/anchor links."""
    if EXTERNAL_RE.match(target):
        return None
    path = target.split("#", 1)[0].split("?", 1)[0]
    if not path:
        return None
    path = path.replace("%20", " ")
    base = PurePosixPath(source).parent
    return norm(str(base / path)).rstrip("/")


# --- rules table -----------------------------------------------------------


class RulesTable:
    """Path → rules-file mapping parsed from .agents/specs/rules/README.md."""

    def __init__(self, repo: Repo):
        self.entries: list[tuple[str, str | None]] = []
        doc = repo.doc(RULES_README)
        base = PurePosixPath(RULES_README).parent
        for line in doc.lines:
            if not TABLE_ROW_RE.match(line) or TABLE_SEP_RE.match(line):
                continue
            cells = split_cells(line)
            if len(cells) < 2:
                continue
            key = cells[0].strip("`")
            if not key.startswith(f"{SPECS}/"):
                continue
            m = INLINE_LINK_RE.search(cells[1])
            self.entries.append((key, norm(str(base / m.group(1))) if m else None))

    def lookup(self, rel: str) -> str | None:
        if rel.startswith(OPTIONAL_TEMPLATES):
            rel = f"specs/technical/{PurePosixPath(rel).name}"
        best: tuple[tuple[int, int], str | None] | None = None
        for key, rules in self.entries:
            score = self._score(key, rel)
            if score and (best is None or score > best[0]):
                best = (score, rules)
        return best[1] if best else None

    @staticmethod
    def _score(key: str, rel: str) -> tuple[int, int] | None:
        if key.endswith("/"):
            return (len(key), 1) if rel.startswith(key) else None
        if rel == key:
            return (len(key) + 1, 2)
        split_dir = key[: -len(".md")] + "/" if key.endswith(".md") else None
        if split_dir and rel.startswith(split_dir):
            return (len(split_dir), 0)
        return None


# --- checks ----------------------------------------------------------------


def check_rules_line(repo: Repo) -> list[Finding]:
    table = RulesTable(repo)
    findings = []
    for rel in repo.spec_markdown():
        if rel == f"{SPECS}/README.md" or rel == f"{OPTIONAL_TEMPLATES}README.md":
            continue
        expected = table.lookup(rel)
        if expected is None:
            findings.append(Finding(rel, 1, "rules-line", f"no row in {RULES_README} matches this path; add one"))
            continue
        doc = repo.doc(rel)
        hits = [(i, RULES_LINE_RE.match(line)) for i, line in enumerate(doc.lines, 1)]
        hits = [(i, m) for i, m in hits if m]
        if not hits:
            findings.append(Finding(rel, 1, "rules-line", f"missing 'Authoring rules:' line linking {expected}"))
            continue
        line, m = hits[0]
        actual = resolve_link(rel, m.group(1))
        if actual != expected:
            findings.append(Finding(rel, line, "rules-line", f"authoring rules link points at {actual}; expected {expected}"))
    return findings


def nearest_template(repo: Repo, rel: str) -> str | None:
    if rel.startswith("specs/technical/") and rel.count("/") == 2:
        candidate = f"{OPTIONAL_TEMPLATES}{PurePosixPath(rel).name}"
        return candidate if repo.exists(candidate) else None
    parent = PurePosixPath(rel).parent
    while str(parent).startswith(f"{SPECS}/"):
        candidate = (parent / ("_template" + PurePosixPath(rel).suffix)).as_posix()
        if repo.exists(candidate):
            return candidate
        parent = parent.parent
    return None


def check_template_copy(repo: Repo) -> list[Finding]:
    findings = []
    for rel in repo.files(SPECS, (".md", ".html")):
        parts = PurePosixPath(rel).parts[1:]
        if is_template(rel):
            if rel.endswith(".md"):
                findings += _template_filled_in_place(repo.doc(rel))
            continue
        for part in parts[:-1]:
            if part != "_templates" and not KEBAB_RE.match(part):
                findings.append(Finding(rel, 1, "template-copy", f"directory '{part}' is not kebab-case"))
        stem = PurePosixPath(rel).stem
        if stem != "README" and not KEBAB_RE.match(stem):
            findings.append(Finding(rel, 1, "template-copy", f"file name '{stem}' is not kebab-case"))
        for i, line in enumerate(repo.doc(rel).lines, 1):
            if "<!-- Template:" in line:
                findings.append(Finding(rel, i, "template-copy", "copied from a template but the 'Template:' comment was not deleted"))
    return findings


def _template_filled_in_place(doc: Doc) -> list[Finding]:
    """A template keeps a placeholder in every section, table row, and paragraph.

    Fixed-value bullet fields (such as `- **Level**: Design`) are allowed, but a
    section left with no placeholder at all counts as filled.
    """
    message = "template holds content; copy it to a new file and fill the copy instead"
    findings = []
    lines = doc.lines
    in_comment = False
    section_start, section_has_placeholder = 1, False

    def close_section(end: int) -> None:
        if not section_has_placeholder and any(l.strip() for l in lines[section_start:end - 1]):
            findings.append(Finding(doc.rel, section_start, "template-copy", f"{message} (section has no placeholder left)"))

    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if HEADING_RE.match(stripped) and not in_comment:
            close_section(i)
            section_start, section_has_placeholder = i, False
            continue
        if "<!--" in stripped and "<!-- Template:" not in stripped:
            section_has_placeholder = True
        if in_comment:
            in_comment = "-->" not in stripped
            continue
        if stripped.startswith("<!--") and "-->" not in stripped:
            in_comment = True
            continue
        if not stripped or "<!--" in stripped or RULES_LINE_RE.match(stripped) or BULLET_VALUE_RE.match(stripped):
            continue
        if FENCE_RE.match(stripped):
            continue
        if TABLE_SEP_RE.match(stripped):
            continue
        if TABLE_ROW_RE.match(stripped) and i < len(lines) and TABLE_SEP_RE.match(lines[i]):
            continue
        findings.append(Finding(doc.rel, i, "template-copy", message))
    close_section(len(lines) + 1)
    return findings


def _skeleton(doc: Doc) -> list[tuple[int, str]]:
    out = []
    for line, level, text in headings(doc):
        if level < 2 or "<!--" in text or "(optional)" in text.lower():
            continue
        out.append((line, strip_comments(text)))
    return out


def check_skeleton(repo: Repo) -> list[Finding]:
    findings = []
    for rel in repo.spec_markdown():
        if is_template(rel) or PurePosixPath(rel).name == "README.md":
            continue
        template = nearest_template(repo, rel)
        if template is None:
            continue
        wanted = [t for _, t in _skeleton(repo.doc(template))]
        have = [strip_comments(t) for _, _, t in headings(repo.doc(rel))]
        pos = 0
        for title in wanted:
            try:
                pos = have.index(title, pos) + 1
            except ValueError:
                where = "out of order" if title in have else "missing"
                findings.append(Finding(rel, 1, "skeleton", f"heading '{title}' from {template} is {where}; keep it and mark it N/A if it does not apply"))
    return findings


def check_bare_na(repo: Repo) -> list[Finding]:
    findings = []
    for rel in repo.spec_markdown():
        if is_template(rel):
            continue
        for i, line in prose_lines(repo.doc(rel)):
            values: list[str] = []
            if TABLE_ROW_RE.match(line) and not TABLE_SEP_RE.match(line):
                values = split_cells(line)
            else:
                m = BULLET_VALUE_RE.match(line)
                if m:
                    values = [m.group(1).strip()]
            if any(BARE_NA_RE.match(strip_comments(v)) for v in values):
                findings.append(Finding(rel, i, "bare-na", "N/A without a reason; write 'N/A — reason'"))
    return findings


def check_bare_tbd(repo: Repo) -> list[Finding]:
    """`TBD` must be followed by a dash and the open question, wherever it appears."""
    findings = []
    for rel in repo.spec_markdown():
        if is_template(rel):
            continue
        for i, line in prose_lines(repo.doc(rel)):
            if BARE_TBD_RE.search(strip_comments(line)):
                findings.append(Finding(rel, i, "bare-tbd", "TBD without an open question; write 'TBD — question'"))
    return findings


def check_links(repo: Repo) -> list[Finding]:
    findings = []
    for top in LINK_ROOTS:
        for rel in repo.files(top, (".md",)):
            for line, target in link_targets(repo.doc(rel)):
                if "<" in target or "{" in target:
                    continue
                resolved = resolve_link(rel, target)
                if resolved is not None and not repo.exists(resolved):
                    findings.append(Finding(rel, line, "links", f"broken link: {target}"))
    return findings


def check_orphans(repo: Repo) -> list[Finding]:
    linked: set[str] = set()
    for rel in repo.spec_markdown():
        for _, target in link_targets(repo.doc(rel)):
            resolved = resolve_link(rel, target)
            if resolved and resolved != rel:
                linked.add(resolved)
                linked.add(f"{resolved}/README.md")
    findings = []
    for rel in repo.files(SPECS, (".md", ".html")):
        if rel == f"{SPECS}/README.md" or is_template(rel):
            continue
        if rel not in linked:
            findings.append(Finding(rel, 1, "orphans", "not linked from any other spec; add it to its hub index"))
    return findings


def _glossary_terms(doc: Doc) -> list[tuple[int, str]]:
    terms = []
    rows = [(i, l) for i, l in prose_lines(doc) if TABLE_ROW_RE.match(l)]
    for idx, (i, line) in enumerate(rows):
        if TABLE_SEP_RE.match(line):
            continue
        if idx + 1 < len(rows) and TABLE_SEP_RE.match(rows[idx + 1][1]):
            continue
        term = strip_comments(split_cells(line)[0]).strip("*` ")
        if term:
            terms.append((i, term))
    return terms


def check_glossary(repo: Repo) -> list[Finding]:
    findings = []
    owners: dict[str, str] = {}
    for rel in repo.spec_markdown():
        path = PurePosixPath(rel)
        if is_template(rel) or not (path.name == "glossary.md" or path.parent.name == "glossary"):
            continue
        terms = _glossary_terms(repo.doc(rel))
        prev = ""
        for line, term in terms:
            key = term.casefold()
            if key < prev:
                findings.append(Finding(rel, line, "glossary", f"'{term}' is out of alphabetical order"))
            prev = max(prev, key)
            owner = owners.get(key)
            if owner == rel:
                findings.append(Finding(rel, line, "glossary", f"'{term}' is defined twice in this glossary"))
            elif owner:
                findings.append(Finding(rel, line, "glossary", f"'{term}' is also defined in {owner}; define it once and link", "warning"))
            else:
                owners[key] = rel
    return findings


def check_word_limit(repo: Repo) -> list[Finding]:
    """Words are counted like `wc -w` on the raw file; a file at exactly the limit passes."""
    findings = []
    for top in WORD_LIMIT_ROOTS:
        for rel in repo.files(top, (".md",)):
            words = len(repo.doc(rel).text.split())
            if words > WORD_LIMIT:
                findings.append(Finding(rel, 1, "word-limit", f"{words} words (limit {WORD_LIMIT}); split into focused files and link between them"))
    return findings


CHECKS: dict[str, Callable[[Repo], list[Finding]]] = {
    "rules-line": check_rules_line,
    "template-copy": check_template_copy,
    "skeleton": check_skeleton,
    "bare-na": check_bare_na,
    "bare-tbd": check_bare_tbd,
    "links": check_links,
    "orphans": check_orphans,
    "glossary": check_glossary,
    "word-limit": check_word_limit,
}


def run(root: Path) -> list[Finding]:
    repo = Repo(root)
    findings: list[Finding] = []
    for check in CHECKS.values():
        findings += check(repo)
    return findings


def report(findings: list[Finding], annotate: bool) -> None:
    for f in findings:
        print(f"  {f.severity.upper()}: {f.path}:{f.line} [{f.check}] {f.message}")
        if annotate:
            print(f"::{f.severity} file={f.path},line={f.line},title=Spec lint ({f.check})::{f.message}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--strict", action="store_true", help="fail on warnings too")
    args = parser.parse_args(argv)

    findings = run(args.root)
    report(findings, annotate=bool(os.environ.get("GITHUB_ACTIONS")))
    errors = sum(f.severity == "error" for f in findings)
    warnings = len(findings) - errors
    print(f"Spec lint: {errors} error(s), {warnings} warning(s) across {len(CHECKS)} checks.")
    return 1 if errors or (args.strict and warnings) else 0


if __name__ == "__main__":
    sys.exit(main())

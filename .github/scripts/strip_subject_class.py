#!/usr/bin/env python3
"""Strip the retired per-puzzle subject class from the puzzle-picture catalog entries.

`specs/assets/kinds/puzzle-pictures.md` no longer carries a per-puzzle
single/multi subject class (product-owner decision on #486, 2026-11-03). This
one-off rewrite carries that decision into the stored files written under the
old rule:

  * drops `generation.settings.subject_class` from every entry that has it;
  * trims the class words from `review.report`: the `Subject class: …` sentence,
    a `(<class>)` after the pack id in the report's opening line, a `(<class>)`
    after the silhouette description (which already says what the class said),
    and a class sentence that exists only to repair one. The report then says
    what changed, so a later reader is not told a class was judged.

Nothing else changes: no other key, no file list, no prompt, no pixel, and no
catalogued file. Field order and JSON indentation are kept.

Usage:
  python3 .github/scripts/strip_subject_class.py            # rewrite in place
  python3 .github/scripts/strip_subject_class.py --check    # exit 1 if any remain
  python3 .github/scripts/strip_subject_class.py --dry-run  # report, write nothing
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CATALOG_ROOT = REPO_ROOT / "assets" / "catalog"

SETTINGS_KEY = "subject_class"
CLASSLESS_NOTE = ("Per-puzzle subject class retired (PO decision on #486, 2026-11-03): "
                  "the subject is judged by look and the stored silhouette.")

# The class as it was written in the review reports. Only these hyphenated forms
# are class markers; the bare words "single" and "multi" are ordinary prose about
# the picture ("a single connected mass") and are never touched. Longest first,
# so the alternatives match the whole class phrase.
_CLASS = r"(?:multi-subject and/or holed|multi-subject and holed|multi-subject|single-subject)"
# A parenthetical class tag: "(single-subject)" or
# "(multi-subject and holed: the ring's interior is open)". Text after the
# takes-it-with-it class part is prose about the picture and is kept, as in
# "(single-subject; one stepped wedge)" -> "one stepped wedge".
_CLASS_PAREN = re.compile(
    r"\((" + _CLASS + r")(?:[^);]*)[);]\s*([^)]*)\)")
_CLASS_PAREN_BARE = re.compile(r"\s*\((?:" + _CLASS + r")[^)]*\)")
# "... (single-subject) (single-subject)." — a doubled trailing tag.
_SUBJECT_CLASS_SENTENCE = re.compile(r"\.?\s*Subject class: [^.]+\.?", re.IGNORECASE)
# "AK-puzzle-pictures R1/V1, pack-063 (single-subject)." — the tag after the pack
# id. Anything after a semicolon inside the parentheses is prose and stays.
_PACK_ID = re.compile(r"^([^\s,]+(?: [^\s,]+)*, pack-\d+) \((?:" + _CLASS + r")")
# "… was one mass, not multi-subject and/or holed;" inside the #267 repair note.
# The class contrast goes; the repair note itself is history and stays.
_REPAIR_CLAUSE = re.compile(r",?\s*not\s+" + _CLASS + r"(?=[;,. )]|$)", re.I)


def _paren_spans(text: str) -> list[tuple[int, int]]:
    """Every outermost balanced `(...)` span, as [start, end) offsets."""
    spans, stack = [], []
    for i, ch in enumerate(text):
        if ch == "(":
            stack.append(i)
        elif ch == ")" and stack:
            spans.append((stack.pop(), i + 1))
    spans.sort()
    keep, last_end = [], 0
    for start, end in spans:
        if start >= last_end:
            keep.append((start, end))
            last_end = end
    return keep


def strip_report(report: str) -> str:
    """The report with class markers removed; everything it judged stays.

    Only hyphenated class markers go. A bare "single" or "multi" inside a
    silhouette sentence is prose about the picture and is left alone, so a
    report never ends up cut mid-sentence. A parenthetical that also describes
    the picture keeps the description.
    """
    label = ""
    opening = _PACK_ID.match(report)
    if opening:
        label = opening.group(1)
        # `opening` stops after the class word; the tag starts at its "(".
        report = report[opening.group(0).rfind("("):].lstrip()
        if not report.startswith("("):
            # Not a class tag after the pack id; keep the text as it was.
            return f"{label} {report}"
        close = report.find(")")
        if close < 0:
            return f"{label}."
        inner = report[1:close]
        m = re.match(r"(?:" + _CLASS + r")\b[^;:)]*[;:]\s*(.+)", inner)
        if m and m.group(1).strip():
            label = f"{label}: {m.group(1).strip()}"
        report = report[close + 1:].lstrip()
        if not report:
            return f"{label}."
    text = re.sub(r"\.\s*Subject class: [^.]+?\.", ".", report, flags=re.I)
    text = re.sub(r"\A\s*Subject class: [^.]+?\.?\s*", "", text, flags=re.I)
    text = _REPAIR_CLAUSE.sub("", text)
    # Remove class parentheticals by balanced span, keeping describing text.
    out, pos = [], 0
    for start, end in _paren_spans(text):
        if start < pos:
            continue
        out.append(text[pos:start])
        inner = text[start + 1:end - 1]
        if re.match(r"(?:" + _CLASS + r")\b", inner):
            m = re.match(r"(?:" + _CLASS + r")[^;:)]*[;:]\s*(.+)$", inner)
            out.append(m.group(1).strip() if m and m.group(1).strip() else "")
        else:
            out.append(text[start:end])
        pos = end
    out.append(text[pos:])
    text = "".join(out)
    text = re.sub(r"\s+([,.;:])", r"\1", text)
    text = re.sub(r"\s{2,}", " ", text).strip()
    # Only seams at the very start/end are artifacts of a removal.
    text = re.sub(r"^[.;]\s*", "", text)
    text = re.sub(r"\s+[;]\s*$", "", text)
    if label and text:
        return f"{label}. {text}" if not label.endswith(")") and ": " not in label else f"{label}. {text}"
    return f"{label}." if label else text


def trim_entry(data: dict, note: str | None = None) -> bool:
    """Rewrite one entry in place; True when anything changed.

    A rewritten report names the class it used to state and `note`, so the
    review record stays honest about what was judged before and after.
    """
    note = CLASSLESS_NOTE if note is None else note
    changed = False
    generation = data.get("generation")
    settings = generation.get("settings") if isinstance(generation, dict) else None
    was = settings.get(SETTINGS_KEY) if isinstance(settings, dict) else None
    if isinstance(settings, dict) and SETTINGS_KEY in settings:
        del settings[SETTINGS_KEY]
        changed = True
    review = data.get("review")
    if isinstance(review, dict) and isinstance(review.get("report"), str):
        original = review["report"]
        if note in original:
            # Already rewritten: the note is what makes this a no-op.
            return changed
        stripped = strip_report(original)
        if stripped != original:
            changed = True
            change = " Class tag removed on 2026-11-03." if was else ""
            review["report"] = f"{stripped.rstrip('. ')}. {note}{change}".strip()
    return changed


def restore_escapes(text: str, original: str) -> str:
    """Keep `\\uXXXX` escapes the file already used, so untouched bytes stay put."""
    for code in re.findall(r"\\u([0-9a-fA-F]{4})", original):
        text = text.replace(chr(int(code, 16)), f"\\u{code}")
    return text


def has_class(data: dict) -> bool:
    generation = data.get("generation") or {}
    settings = generation.get("settings") or {}
    if SETTINGS_KEY in settings:
        return True
    report = (data.get("review") or {}).get("report") or ""
    return bool(re.search(r"\bSubject class:|\b(?:single|multi)-subject\b", report))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", default=str(CATALOG_ROOT),
                        help="catalog root (default: assets/catalog from this repo)")
    parser.add_argument("--check", action="store_true",
                        help="report leftovers and exit 1 without writing")
    parser.add_argument("--dry-run", action="store_true",
                        help="report what would change without writing")
    args = parser.parse_args(argv)
    root = Path(args.root)
    if not root.is_dir():
        print(f"catalog root not found: {root}", file=sys.stderr)
        return 2

    rewritten = 0
    leftover: list[Path] = []
    for path in sorted(root.glob("*.json")):
        original = path.read_text(encoding="utf-8")
        data = json.loads(original)
        trimmed = json.loads(json.dumps(data))
        changed = trim_entry(trimmed)
        if changed:
            rewritten += 1
            if not (args.check or args.dry_run):
                text = json.dumps(trimmed, indent=2, ensure_ascii=False) + "\n"
                path.write_text(restore_escapes(text, original), encoding="utf-8")
            continue
        if has_class(data):
            leftover.append(path)
    action = "can rewrite" if args.check else "would rewrite" if args.dry_run else "rewrote"
    print(f"{action} {rewritten} entr{'y' if rewritten == 1 else 'ies'} under {root}")
    if leftover:
        print(f"{len(leftover)} entr{'y' if len(leftover) == 1 else 'ies'} still name a class",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Check the asset catalog's entry files against specs/assets/catalog.md.

Default format: one JSON object per asset in `<catalog-root>/<asset-id>.json`,
with the keys in specs/assets/catalog/fields.md. The catalog root, asset root,
and kind spec names come from specs/assets/assets.md. While the catalog root is
unset, every check is skipped; while the asset root is unset, the file checks
are skipped. A project whose Integration ADR sets another format replaces this
script.

Checks (catalog integrity IDs): I1 files, I2 asset IDs, I3 approval,
I4 kind specs and successors, I6 exemptions, I7 handles, I8 banned tools (the
Banned tools table in docs/asset-tools.md); plus required fields and value
shapes.

Usage: asset_catalog.py [--root DIR]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from new_asset_id import is_asset_id  # noqa: E402

HUB = "specs/assets/assets.md"
TOOLS_DOC = "docs/asset-tools.md"
TOUCHUP_PARTS = ("operation", "tool", "terms", "date", "reason", "run_by")
GENERATION_PARTS = ("prompt", "tool", "operation", "settings", "inputs", "seed")
SERIES_ID_PART = "id"
SERIES_HARD_BINDINGS = ("recraft_style_id", "elevenlabs_finetune_id", "elevenlabs_voice_id")
SERIES_BINDING_SETTINGS = ("input_style_id", "finetune_id", "voice_id")
STATES = {"draft", "approved", "deprecated"}
SOURCE_TYPES = {"ai-generation", "procedural-generation", "third-party", "human-made"}
GENERATED = {"ai-generation", "procedural-generation"}
ALWAYS = ("id", "handle", "kind_spec", "serves", "state", "version", "files", "source_type", "license")
ENGINE_SIDECARS = (".meta", ".import", ".uid")
KEBAB = r"[a-z0-9]+(?:-[a-z0-9]+)*"
HANDLE_RE = re.compile(rf"^({KEBAB})/{KEBAB}$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
CODE_RE = re.compile(r"`([^`]+)`")
KIND_LINK_RE = re.compile(rf"kinds/({KEBAB})\.md")


@dataclass(frozen=True)
class Finding:
    path: str
    check: str
    message: str

    def __str__(self) -> str:
        return f"{self.path} [{self.check}] {self.message}"


@dataclass(frozen=True)
class Hub:
    catalog_root: str | None
    asset_root: str | None
    kind_specs: frozenset[str]
    banned_tools: frozenset[str] = frozenset()


def _bullet_path(text: str, label: str) -> str | None:
    m = re.search(rf"^\s*-\s+\*\*{re.escape(label)}\*\*:\s*(.*)$", text, re.M)
    code = CODE_RE.search(m.group(1)) if m and not m.group(1).startswith("TBD") else None
    return code.group(1).strip().strip("/") or None if code else None


def _kind_specs(text: str) -> frozenset[str]:
    section = re.search(r"^## Asset kinds\s*$(.*?)(?=^## )", text, re.M | re.S)
    names: set[str] = set()
    for line in (section.group(1) if section else "").splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not line.lstrip().startswith("|") or len(cells) < 4:
            continue
        names.update(KIND_LINK_RE.findall(cells[-1]))
        names.update(t.strip() for t in CODE_RE.findall(cells[-1]) if re.fullmatch(KEBAB, t.strip()))
    return frozenset(names)


def _banned_tools(text: str) -> frozenset[str]:
    section = re.search(r"^## Banned tools\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    rows = [line for line in (section.group(1) if section else "").splitlines() if line.lstrip().startswith("|")]
    names = (row.strip().strip("|").split("|")[0].strip().strip("`*").lower() for row in rows[2:])
    return frozenset(name for name in names if name)


def _read(path: Path) -> str:
    return COMMENT_RE.sub("", path.read_text(encoding="utf-8")) if path.exists() else ""


def read_hub(root: Path) -> Hub:
    text = _read(root / HUB)
    banned = _banned_tools(_read(root / TOOLS_DOC))
    return Hub(_bullet_path(text, "Catalog root"), _bullet_path(text, "Asset root"), _kind_specs(text), banned)


def _non_empty(entry: dict[str, Any], key: str) -> bool:
    return entry.get(key) not in (None, "", [], {})


def _parts(rel: str, entry: dict[str, Any], key: str, parts: tuple[str, ...], check: str) -> list[Finding]:
    value = entry.get(key)
    if not isinstance(value, dict):
        return [Finding(rel, check, f"'{key}' must be an object with {', '.join(parts)}")]
    missing = [p for p in parts if not _non_empty(value, p)]
    findings = [Finding(rel, check, f"'{key}' is missing {', '.join(missing)}")] if missing else []
    if "date" in parts and value.get("date") and not DATE_RE.match(str(value["date"])):
        findings.append(Finding(rel, check, f"'{key}.date' must be YYYY-MM-DD"))
    return findings


def check_entry(rel: str, stem: str, entry: dict[str, Any], hub: Hub) -> list[Finding]:
    findings = [Finding(rel, "fields", f"missing '{k}'") for k in ALWAYS if not _non_empty(entry, k)]
    findings += [Finding(rel, "fields", f"'{k}' is null") for k, v in entry.items() if v is None]
    asset_id, handle = entry.get("id"), entry.get("handle")
    if asset_id is not None and not (isinstance(asset_id, str) and is_asset_id(asset_id)):
        findings.append(Finding(rel, "I2", "'id' is not a lowercase UUID version 7"))
    elif asset_id is not None and asset_id != stem:
        findings.append(Finding(rel, "I2", "file name must be '<id>.json'"))
    if handle is not None:
        m = HANDLE_RE.match(handle) if isinstance(handle, str) else None
        if not m:
            findings.append(Finding(rel, "I7", "'handle' must be '<kind>/<name>' in kebab-case"))
        elif m.group(1) not in hub.kind_specs:
            findings.append(Finding(rel, "I7", f"handle prefix '{m.group(1)}' is not a kind spec named in {HUB}"))
        elif entry.get("kind_spec") != f"AK-{m.group(1)}":
            findings.append(Finding(rel, "I4", f"'kind_spec' must be 'AK-{m.group(1)}' to match the handle"))
    if entry.get("state") is not None and entry["state"] not in STATES:
        findings.append(Finding(rel, "fields", f"'state' must be one of {sorted(STATES)}"))
    version = entry.get("version")
    if version is not None and (type(version) is not int or version < 1):
        findings.append(Finding(rel, "fields", "'version' must be an integer from 1"))
    source = entry.get("source_type")
    if source is not None and source not in SOURCE_TYPES:
        findings.append(Finding(rel, "fields", f"'source_type' must be one of {sorted(SOURCE_TYPES)}"))
    files = entry.get("files")
    if files is not None and not (isinstance(files, list) and all(isinstance(f, str) and f and not f.startswith("/") and ".." not in Path(f).parts for f in files)):
        findings.append(Finding(rel, "fields", "'files' must list paths relative to the asset root"))
    person_supplied = _non_empty(entry, "supplier")
    if not person_supplied and not _non_empty(entry, "coverage"):
        findings.append(Finding(rel, "fields", "missing 'coverage'"))
    if source in GENERATED:
        if not _non_empty(entry, "generation"):
            findings.append(Finding(rel, "fields", "generated asset is missing 'generation'"))
        elif not person_supplied:
            findings += _check_generation(rel, entry["generation"])
        if not person_supplied:
            findings += [Finding(rel, "fields", f"agent-generated asset is missing '{k}'") for k in ("tool_role", "recipe") if not _non_empty(entry, k)]
            if _non_empty(entry, "tool_role"):
                findings += _parts(rel, entry, "tool_role", ("role", "adr"), "fields")
    if _non_empty(entry, "exemption"):
        findings += _parts(rel, entry, "exemption", ("granted_by", "date", "reason"), "I6")
    if _non_empty(entry, "review"):
        findings += _parts(rel, entry, "review", ("verdict", "date", "reviewer", "report"), "fields")
    if entry.get("state") == "approved" and not _non_empty(entry, "exemption"):
        review = entry.get("review")
        if not (isinstance(review, dict) and review.get("verdict") == "Pass"):
            findings.append(Finding(rel, "I3", "approved entry needs a review with verdict 'Pass', or an exemption"))
    if entry.get("state") == "deprecated" and not _non_empty(entry, "deprecation_reason"):
        findings.append(Finding(rel, "fields", "deprecated entry is missing 'deprecation_reason'"))
    findings += _check_touchups(rel, entry, person_supplied)
    findings += _check_banned(rel, entry, hub.banned_tools)
    return findings


def _check_series(rel: str, series: Any) -> list[Finding]:
    if not isinstance(series, dict):
        return [Finding(rel, "fields", f"'series' must be an object with '{SERIES_ID_PART}' and a style binding")]
    findings: list[Finding] = []
    if not _non_empty(series, SERIES_ID_PART):
        findings.append(Finding(rel, "fields", f"'series' is missing {SERIES_ID_PART}"))
    hard = [k for k in SERIES_HARD_BINDINGS if _non_empty(series, k)]
    soft = series.get("soft_enforce") is True
    if soft and hard:
        findings.append(Finding(rel, "fields", "'series' cannot combine soft_enforce with a hard style binding"))
    elif soft:
        pass
    elif len(hard) == 1:
        pass
    elif len(hard) > 1:
        findings.append(Finding(rel, "fields", f"'series' must have exactly one of {', '.join(SERIES_HARD_BINDINGS)}"))
    else:
        findings.append(
            Finding(
                rel,
                "fields",
                f"'series' needs one of {', '.join(SERIES_HARD_BINDINGS)} or soft_enforce: true",
            )
        )
    return findings


def _check_generation(rel: str, generation: Any) -> list[Finding]:
    if not isinstance(generation, dict):
        return [Finding(rel, "fields", f"'generation' must be an object with {', '.join(GENERATION_PARTS)}")]
    findings = _parts(rel, {"generation": generation}, "generation", GENERATION_PARTS, "fields")
    settings = generation.get("settings")
    needs_series = _non_empty(generation, "series") or (
        isinstance(settings, dict) and any(_non_empty(settings, k) for k in SERIES_BINDING_SETTINGS)
    )
    if needs_series:
        findings += _check_series(rel, generation.get("series"))
    return findings


def _check_touchups(rel: str, entry: dict[str, Any], person_supplied: bool) -> list[Finding]:
    if "touchups" not in entry:
        return []
    touchups = entry["touchups"]
    if not (isinstance(touchups, list) and touchups):
        return [Finding(rel, "fields", "'touchups' must be a non-empty list")]
    parts = TOUCHUP_PARTS + (("agreed_by",) if person_supplied else ())
    findings: list[Finding] = []
    for i, touchup in enumerate(touchups):
        findings += _parts(rel, {f"touchups[{i}]": touchup}, f"touchups[{i}]", parts, "fields")
        if isinstance(touchup, dict) and str(touchup.get("run_by", "")).casefold() == "agent":
            findings += _parts(
                rel, {f"touchups[{i}]": touchup}, f"touchups[{i}]", ("prompt", "inputs"), "fields"
            )
    return findings


def _check_banned(rel: str, entry: dict[str, Any], banned: frozenset[str]) -> list[Finding]:
    generation, touchups = entry.get("generation"), entry.get("touchups")
    tools = [generation.get("tool")] if isinstance(generation, dict) else []
    tools += [t.get("tool") for t in touchups if isinstance(t, dict)] if isinstance(touchups, list) else []
    return [Finding(rel, "I8", f"tool '{tool}' is banned by {TOOLS_DOC}")
            for tool in tools if isinstance(tool, str) and any(name in tool.lower() for name in banned)]


def check_catalog(entries: dict[str, dict[str, Any]]) -> list[Finding]:
    findings: list[Finding] = []
    ids = {e.get("id") for e in entries.values()}
    seen: dict[str, str] = {}
    for rel, entry in entries.items():
        handle = entry.get("handle")
        if isinstance(handle, str):
            if handle in seen:
                findings.append(Finding(rel, "I7", f"handle '{handle}' is also used by {seen[handle]}"))
            seen.setdefault(handle, rel)
        successor = entry.get("successor")
        if successor is not None and (successor == entry.get("id") or successor not in ids):
            findings.append(Finding(rel, "I4", f"successor '{successor}' is not another cataloged asset"))
    return findings


def check_files(root: Path, hub: Hub, entries: dict[str, dict[str, Any]]) -> list[Finding]:
    asset_root = root / hub.asset_root
    if not asset_root.is_dir():
        return [Finding(hub.asset_root, "I1", "asset root does not exist")]
    findings: list[Finding] = []
    owner: dict[str, str] = {}
    for rel, entry in entries.items():
        files = entry.get("files")
        for f in files if isinstance(files, list) else []:
            if not isinstance(f, str):
                continue
            if not (asset_root / f).is_file():
                findings.append(Finding(rel, "I1", f"file '{f}' does not exist under {hub.asset_root}"))
            if f in owner:
                findings.append(Finding(rel, "I1", f"file '{f}' also belongs to {owner[f]}"))
            owner.setdefault(f, rel)
    catalog_root = (root / hub.catalog_root).resolve()
    for path in sorted(p for p in asset_root.rglob("*") if p.is_file()):
        if path.suffix in ENGINE_SIDECARS or catalog_root in path.resolve().parents:
            continue
        f = path.relative_to(asset_root).as_posix()
        if f not in owner:
            findings.append(Finding(f"{hub.asset_root}/{f}", "I1", "file belongs to no catalog entry"))
    return findings


def check(root: Path) -> tuple[list[Finding], list[str]]:
    hub = read_hub(root)
    if hub.catalog_root is None:
        return [], [f"catalog root not set in {HUB}; catalog checks skipped"]
    catalog = root / hub.catalog_root
    if not catalog.is_dir():
        return [Finding(hub.catalog_root, "catalog", "catalog root does not exist")], []
    findings: list[Finding] = []
    entries: dict[str, dict[str, Any]] = {}
    for path in sorted(p for p in catalog.iterdir() if p.is_file()):
        rel = path.relative_to(root).as_posix()
        if path.suffix in ENGINE_SIDECARS:
            continue
        if path.suffix != ".json":
            findings.append(Finding(rel, "catalog", "only entry files ('<id>.json') may live in the catalog root"))
            continue
        try:
            entry = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as exc:
            findings.append(Finding(rel, "catalog", f"not valid UTF-8 JSON: {exc}"))
            continue
        if not isinstance(entry, dict):
            findings.append(Finding(rel, "catalog", "entry file must hold one JSON object"))
            continue
        findings += check_entry(rel, path.stem, entry, hub)
        entries[rel] = entry
    findings += check_catalog(entries)
    notes: list[str] = []
    if hub.asset_root is None:
        notes.append(f"asset root not set in {HUB}; file checks skipped")
    else:
        findings += check_files(root, hub, entries)
    return findings, notes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2], help="repository root")
    findings, notes = check(parser.parse_args().root)
    for note in notes:
        print(f"NOTE: {note}")
    for finding in findings:
        print(f"ERROR: {finding}")
    print(f"Asset catalog: {len(findings)} error(s).")
    sys.exit(1 if findings else 0)


if __name__ == "__main__":
    main()

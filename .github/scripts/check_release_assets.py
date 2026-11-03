#!/usr/bin/env python3
"""Static release-asset check: what a release export would ship is complete.

Issue #499 / ADR-0008. Runs without an export, offline, on the committed tree:

1. Manifest scope: every path the root manifest lists is a `res://` path under the
   asset root, and its file or `.import` sidecar exists there. Only manifest-listed
   paths are walked — never the whole `game/` tree, which carries non-asset sidecars.
2. Catalog state: every listed ID has a catalog entry that is approved, not draft or
   deprecated (ACC.A3 / asset-access R3).
3. Shipped IDs: every asset ID a shipped file names (all of `game/` except `game/test`
   and `game/addons`) is listed by the manifest, so no unresolved ID ships.
4. Runtime reads: no shipped `.gd` file names `res://../`, which packs nothing
   (ADR-0008); the resolver's dev read is the only exception and lives in one file.
5. In-build copy: when the export script's copy exists, it matches the manifest.

Usage: check_release_assets.py [--root DIR]
Exit 0 when clean, 1 when any check finds a problem.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from asset_catalog import read_hub  # noqa: E402

MANIFEST = "assets/manifest.json"
CATALOG = "assets/catalog"
RES_PREFIX = "res://"
INBUILD = "game/release/asset_manifest.json"
SKIP_PARTS = {"addons", "test", ".godot"}
ASSET_ID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}")
RES_PARENT_READ = re.compile(r'res://\.\./')
# ADR-0008: the resolver and its tests are the only files that may name the dev read.
RES_PARENT_ALLOWED = {"game/presentation/asset_resolver.gd"}


def _text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return ""


def _res_path(game: Path, value: str) -> Path | None:
    """Map a `res://...` path to the file under `game/`, or None when it is outside."""
    if not value.startswith(RES_PREFIX):
        return None
    return game / value[len(RES_PREFIX) :]


def _shipped_files(game: Path) -> list[Path]:
    files: list[Path] = []
    for path in sorted(game.rglob("*")):
        if path.is_dir() or SKIP_PARTS & set(path.relative_to(game).parts):
            continue
        files.append(path)
    return files


def _rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def check_manifest(root: Path, manifest: dict[str, list[str]], asset_root: Path) -> list[str]:
    problems: list[str] = []
    if not manifest:
        return ["manifest lists no assets"]
    for asset_id, paths in manifest.items():
        if not paths:
            problems.append(f"{MANIFEST}: {asset_id} lists no path")
            continue
        for value in paths:
            path = _res_path(root / "game", str(value))
            if path is None:
                problems.append(f"{MANIFEST}: {asset_id} path is not res://: {value}")
                continue
            try:
                path.relative_to(asset_root)
            except ValueError:
                problems.append(f"{MANIFEST}: {asset_id} path is outside the asset root: {value}")
                continue
            sidecar = path.with_name(path.name + ".import")
            if not path.is_file() and not sidecar.is_file():
                problems.append(f"{MANIFEST}: {asset_id} has no file or .import sidecar: {value}")
    return problems


def check_catalog(root: Path, manifest: dict[str, list[str]]) -> list[str]:
    problems: list[str] = []
    for asset_id in manifest:
        entry_path = root / CATALOG / f"{asset_id}.json"
        entry = json.loads(_text(entry_path)) if entry_path.is_file() else None
        if not isinstance(entry, dict):
            problems.append(f"{CATALOG}: {asset_id} is in the manifest but has no catalog entry")
            continue
        state = entry.get("state")
        if state != "approved":
            problems.append(f"{CATALOG}: {asset_id} ships as '{state}', not approved")
    return problems


def check_shipped_ids(root: Path, manifest: dict[str, list[str]]) -> list[str]:
    problems: list[str] = []
    game = root / "game"
    for path in _shipped_files(game):
        for asset_id in sorted(set(ASSET_ID.findall(_text(path)))):
            if asset_id not in manifest:
                problems.append(f"{_rel(root, path)}: ships {asset_id}, which the manifest does not list")
    return problems


def check_runtime_reads(root: Path) -> list[str]:
    problems: list[str] = []
    game = root / "game"
    for path in _shipped_files(game):
        if path.suffix != ".gd":
            continue
        rel = _rel(root, path)
        if rel in RES_PARENT_ALLOWED:
            continue
        if RES_PARENT_READ.search(_text(path)):
            problems.append(f"{rel}: reads res://../ at runtime, which an export does not pack")
    return problems


def check_inbuild_copy(root: Path, manifest: dict[str, list[str]]) -> list[str]:
    copy_path = root / INBUILD
    if not copy_path.is_file():
        return []
    try:
        copy = json.loads(_text(copy_path))
    except json.JSONDecodeError:
        return [f"{INBUILD}: is not valid JSON"]
    if copy != manifest:
        return [f"{INBUILD}: differs from {MANIFEST}; re-run export_release.sh"]
    return []


def check(root: Path) -> list[str]:
    manifest_path = root / MANIFEST
    if not manifest_path.is_file():
        return [f"{MANIFEST}: is missing; run asset_manifest.py --write"]
    try:
        manifest = json.loads(_text(manifest_path))
    except json.JSONDecodeError:
        return [f"{MANIFEST}: is not valid JSON"]
    if not isinstance(manifest, dict):
        return [f"{MANIFEST}: is not a JSON object"]
    hub = read_hub(root)
    asset_root = root / hub.asset_root
    problems = check_manifest(root, manifest, asset_root)
    problems += check_catalog(root, manifest)
    problems += check_shipped_ids(root, manifest)
    problems += check_runtime_reads(root)
    problems += check_inbuild_copy(root, manifest)
    return problems


def main() -> None:
    parser = argparse.ArgumentParser(description="Check that a release export can ship every asset.")
    parser.add_argument("--root", default=Path(__file__).resolve().parents[2], type=Path)
    args = parser.parse_args()
    problems = check(args.root)
    for problem in problems:
        print(f"ERROR: {problem}")
    print(f"Release assets: {len(problems)} error(s).")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()

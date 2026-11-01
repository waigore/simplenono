#!/usr/bin/env python3
"""Generate or check assets/manifest.json from the asset catalog.

Reads the approved entries in the catalog root (specs/assets/assets.md) plus the
cataloged files under the asset root, and maps each approved asset ID to its
`res://` paths under the Godot project (ADR-0003, ADR-0006). Only approved
entries whose files all exist are emitted; the output is deterministic,
offline, and written as one whole file (assets/manifest.json).

The catalog root and asset root come from specs/assets/assets.md through
asset_catalog.read_hub; nothing here hardcodes them. While either root is
unset, generation is skipped with a NOTE and the manifest is left alone.

Usage: asset_manifest.py [--write | --check] [--root DIR]
  --write  regenerate assets/manifest.json (default)
  --check  regenerate in memory, never write, and exit 1 when the committed
           manifest differs; exit 0 when identical
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from asset_catalog import read_hub  # noqa: E402

MANIFEST = "assets/manifest.json"


def _res_prefix(asset_root: Path) -> str | None:
    """Return the asset root's path inside the Godot project, or None."""
    current = asset_root
    while True:
        if (current / "project.godot").is_file():
            relative = asset_root.relative_to(current).as_posix()
            return "" if relative == "." else relative
        if current.parent == current:
            return None
        current = current.parent


def _entry_paths(catalog: Path) -> list[Path]:
    return sorted(path for path in catalog.iterdir() if path.is_file() and path.suffix == ".json")


def build_manifest(root: Path) -> tuple[dict[str, list[str]] | None, list[str], list[str]]:
    """Return (manifest, errors, notes); manifest is None when skipped."""
    hub = read_hub(root)
    if hub.catalog_root is None or hub.asset_root is None:
        unset = "catalog root" if hub.catalog_root is None else "asset root"
        return None, [], [f"{unset} not set in specs/assets/assets.md; manifest generation skipped"]

    catalog = root / hub.catalog_root
    asset_root = root / hub.asset_root
    if not catalog.is_dir():
        return None, [f"{hub.catalog_root}: catalog root does not exist"], []
    if not asset_root.is_dir():
        return None, [f"{hub.asset_root}: asset root does not exist"], []

    prefix = _res_prefix(asset_root)
    if prefix is None:
        return None, [f"{hub.asset_root}: no project.godot above the asset root; res:// paths cannot be generated"], []

    manifest: dict[str, list[str]] = {}
    errors: list[str] = []
    for path in _entry_paths(catalog):
        rel = path.relative_to(root).as_posix()
        try:
            entry = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as exc:
            errors.append(f"{rel}: not valid UTF-8 JSON: {exc}")
            continue
        if not isinstance(entry, dict):
            errors.append(f"{rel}: entry file must hold one JSON object")
            continue
        if entry.get("state") != "approved":
            continue
        asset_id = entry.get("id")
        if not isinstance(asset_id, str) or not asset_id:
            errors.append(f"{rel}: approved entry has no 'id'")
            continue
        if asset_id in manifest:
            errors.append(f"{asset_id}: appears in more than one approved entry")
            continue
        files = entry.get("files")
        if not (isinstance(files, list) and files and all(isinstance(f, str) and f for f in files)):
            errors.append(f"{asset_id}: 'files' must be a non-empty list of paths")
            continue
        paths: list[str] = []
        for file in files:
            if not (asset_root / file).is_file():
                errors.append(f"{asset_id}: cataloged file '{file}' does not exist under {hub.asset_root}")
                continue
            paths.append(f"res://{prefix}/{file}" if prefix else f"res://{file}")
        manifest[asset_id] = paths

    return (None if errors else manifest), errors, []


def render(manifest: dict[str, list[str]]) -> str:
    return json.dumps(manifest, indent=2, sort_keys=True) + "\n"


def write(root: Path) -> int:
    manifest, errors, notes = build_manifest(root)
    for note in notes:
        print(f"NOTE: {note}")
    for error in errors:
        print(f"ERROR: {error}")
    if manifest is None:
        if errors:
            print(f"Asset manifest: {len(errors)} error(s); {MANIFEST} unchanged.")
            return 1
        print(f"Asset manifest: generation skipped; {MANIFEST} unchanged.")
        return 0
    (root / MANIFEST).write_text(render(manifest), encoding="utf-8")
    print(f"Asset manifest: wrote {MANIFEST} ({len(manifest)} asset(s)).")
    return 0


def check(root: Path) -> int:
    manifest, errors, notes = build_manifest(root)
    for note in notes:
        print(f"NOTE: {note}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        print(f"Asset manifest: {len(errors)} error(s).")
        return 1
    if manifest is None:
        print(f"Asset manifest: generation skipped; {MANIFEST} not compared.")
        return 0

    path = root / MANIFEST
    if not path.is_file():
        errors.append(f"{MANIFEST} is missing; regenerate it")
    else:
        try:
            committed = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as exc:
            errors.append(f"{MANIFEST}: not valid UTF-8 JSON: {exc}")
        else:
            if not isinstance(committed, dict):
                errors.append(f"{MANIFEST}: must hold one JSON object")
            else:
                errors += _differences(committed, manifest)

    for error in errors:
        print(f"ERROR: {error}")
    print(f"Asset manifest: {len(errors)} error(s).")
    return 1 if errors else 0


def _differences(committed: dict[str, Any], generated: dict[str, list[str]]) -> list[str]:
    findings: list[str] = []
    for asset_id in sorted(set(committed) | set(generated)):
        if asset_id not in committed:
            findings.append(f"{asset_id} is missing from {MANIFEST}")
        elif asset_id not in generated:
            findings.append(f"{asset_id} is not generated from the catalog")
        elif committed[asset_id] != generated[asset_id]:
            findings.append(
                f"{asset_id} paths differ: committed {committed[asset_id]}, regenerated {generated[asset_id]}"
            )
    return findings


def run(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--write", action="store_true", help="regenerate the manifest (default)")
    mode.add_argument("--check", action="store_true", help="fail when the committed manifest has drifted")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2], help="repository root")
    args = parser.parse_args(argv)
    return check(args.root) if args.check else write(args.root)


def main() -> None:
    sys.exit(run())


if __name__ == "__main__":
    main()

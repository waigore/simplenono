#!/usr/bin/env python3
"""Locked Cheaper Inference image generate / reference-anchor helper.

Agents must prefer this over ad-hoc curl. See docs/asset-tools-cheaperinference-steps.md.
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API_BASE = "https://api.cheaperinference.com/v1"
DEFAULT_MODEL = "flux-2-max"
DEFAULT_SIZE = "1024x1024"


def _die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    raise SystemExit(code)


def _api_key() -> str:
    key = os.environ.get("CHEAPERINFERENCE_API_KEY", "").strip()
    if not key:
        _die(
            "CHEAPERINFERENCE_API_KEY is not set in this shell. "
            "Set it in the agent/Cursor env (or source the profile); do not put it in the repo."
        )
    return key


def _data_url(path: Path) -> str:
    raw = path.read_bytes()
    if raw.startswith(b"\x89PNG\r\n\x1a\n"):
        mime = "image/png"
    elif raw[:3] == b"\xff\xd8\xff":
        mime = "image/jpeg"
    elif raw[:4] == b"RIFF" and raw[8:12] == b"WEBP":
        mime = "image/webp"
    else:
        _die(f"Unsupported reference image format: {path}")
    return f"data:{mime};base64,{base64.b64encode(raw).decode('ascii')}"


def _extension_for(raw: bytes, fallback: str) -> str:
    if raw.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if raw[:3] == b"\xff\xd8\xff":
        return ".jpg"
    if raw[:4] == b"RIFF" and raw[8:12] == b"WEBP":
        return ".webp"
    return fallback


def _post_generations(body: dict) -> dict:
    req = urllib.request.Request(
        f"{API_BASE}/images/generations",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {_api_key()}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        _die(f"Cheaper Inference HTTP {e.code}: {detail}")
    except urllib.error.URLError as e:
        _die(f"Cheaper Inference request failed: {e}")


def _save_image(payload: dict, out: Path) -> Path:
    data = payload.get("data") or []
    if not data:
        _die(f"No data in response: {json.dumps(payload)[:500]}")
    item = data[0]
    if "b64_json" in item:
        raw = base64.b64decode(item["b64_json"])
    elif "url" in item:
        with urllib.request.urlopen(item["url"], timeout=120) as resp:
            raw = resp.read()
    else:
        _die(f"No b64_json or url in data[0]: {list(item)}")

    ext = _extension_for(raw, out.suffix or ".png")
    if out.suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
        out = out.with_suffix(ext)
    elif ext == ".jpg" and out.suffix.lower() == ".png":
        # API often returns JPEG bytes; keep user path but warn via meta only.
        pass
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(raw)
    return out


def _meta(payload: dict, model: str, operation: str, out: Path) -> dict:
    return {
        "tool": "Cheaper Inference",
        "operation": operation,
        "model": model,
        "out": str(out),
        "request_id": payload.get("request_id"),
        "billing": payload.get("billing"),
        "created": payload.get("created"),
    }


def cmd_generate(args: argparse.Namespace) -> None:
    body = {
        "model": args.model,
        "prompt": args.prompt,
        "n": 1,
        "size": args.size,
    }
    payload = _post_generations(body)
    out = _save_image(payload, Path(args.out))
    print(json.dumps(_meta(payload, args.model, "images.generations", out), separators=(",", ":")))


def cmd_reference(args: argparse.Namespace) -> None:
    ref = Path(args.reference)
    if not ref.is_file():
        _die(f"Reference image not found: {ref}")
    body = {
        "model": args.model,
        "prompt": args.prompt,
        "n": 1,
        "input_image": _data_url(ref),
    }
    # size omitted: flux-2-max reference path is generations+input_image; do not use /edits.
    payload = _post_generations(body)
    out = _save_image(payload, Path(args.out))
    print(
        json.dumps(
            {
                **_meta(payload, args.model, "images.generations+input_image", out),
                "reference": str(ref),
            },
            separators=(",", ":"),
        )
    )


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Generate images via Cheaper Inference (locked project helper)."
    )
    sub = parser.add_subparsers(dest="command", required=True)

    g = sub.add_parser("generate", help="Text-to-image")
    g.add_argument("--prompt", required=True)
    g.add_argument("--out", required=True)
    g.add_argument("--model", default=DEFAULT_MODEL)
    g.add_argument("--size", default=DEFAULT_SIZE)
    g.set_defaults(func=cmd_generate)

    r = sub.add_parser("reference", help="Same-style follow-up with anchor image")
    r.add_argument("--prompt", required=True)
    r.add_argument("--reference", required=True)
    r.add_argument("--out", required=True)
    r.add_argument("--model", default=DEFAULT_MODEL)
    r.set_defaults(func=cmd_reference)

    args = parser.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()

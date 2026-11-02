#!/usr/bin/env python3
"""Print a Godot 4 `.import` sidecar for one PNG, matching the committed sidecars.

Fallback only: running `godot --headless --import` in game/ writes the real sidecar,
with Godot's own uid and cache name, and that is what ships (the puzzle-picture
slices commit Godot-written sidecars). Use this when Godot is unavailable; the game
rewrites the uid on its next editor import.

Usage:
  python3 .github/scripts/build_import.py game/assets/puzzle-pictures/pack-004-pixel.png
"""
from __future__ import annotations

import base64
import hashlib
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
RES_ROOT = REPO_ROOT / "game"
ALPHABET = "abcdefghijklmnopqrstuvwxyz0123456789"

TEMPLATE = """[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://{uid}"
path="res://.godot/imported/{stem}.png-{digest}.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://{source}"
dest_files=["res://.godot/imported/{stem}.png-{digest}.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""


def text_id(bits: int, digest: bytes) -> str:
    """ALPHABET digits of `bits` bits, most significant first."""
    value = int.from_bytes(digest, "big") >> (len(digest) * 8 - bits)
    out = []
    for _ in range(bits):
        out.append(ALPHABET[value & 0x1F])
        value >>= 5
    return "".join(reversed(out))


def sidecar(png: Path) -> str:
    data = png.read_bytes()
    digest = hashlib.md5(data).hexdigest()
    # the first character stands for the id kind; newer Godot uses 0 for a
    # resource uid, so set it instead of deriving it
    uid = "0" + text_id(31, hashlib.md5(b"uid:" + data).digest())
    return TEMPLATE.format(uid=uid, digest=digest, stem=png.stem,
                           source=png.resolve().relative_to(RES_ROOT).as_posix())


def main(argv: list[str]) -> int:
    for raw in argv:
        png = Path(raw).resolve()
        (png.parent / (png.name + ".import")).write_text(sidecar(png))
        print(f"wrote {png.name}.import")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

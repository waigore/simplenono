#!/usr/bin/env python3
"""Print new asset IDs: RFC 9562 UUID version 7 (time-ordered, random).

Asset IDs are defined in specs/assets/catalog.md. Generate them with this
script; never type, copy, or adapt one by hand.

Usage: new_asset_id.py [-n COUNT]
"""
from __future__ import annotations

import argparse
import os
import re
import time
import uuid

UUID7_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")


def uuid7(unix_ms: int | None = None, rand: bytes | None = None) -> uuid.UUID:
    """48-bit Unix time in ms, version 7, variant 10, and 74 random bits."""
    ms = time.time_ns() // 1_000_000 if unix_ms is None else unix_ms
    bits = int.from_bytes(os.urandom(10) if rand is None else rand, "big")
    value = (ms & ((1 << 48) - 1)) << 80 | bits
    value = (value & ~(0xF << 76)) | (0x7 << 76)
    value = (value & ~(0x3 << 62)) | (0x2 << 62)
    return uuid.UUID(int=value)


def is_asset_id(text: str) -> bool:
    return bool(UUID7_RE.match(text))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("-n", "--count", type=int, default=1, help="how many IDs to print")
    for _ in range(parser.parse_args().count):
        print(uuid7())


if __name__ == "__main__":
    main()

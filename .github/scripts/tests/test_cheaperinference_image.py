"""Unit tests for cheaperinference_image helpers (no network)."""

from __future__ import annotations

import base64
import importlib.util
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "cheaperinference_image.py"


def _load():
    spec = importlib.util.spec_from_file_location("cheaperinference_image", SCRIPT)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = mod
    spec.loader.exec_module(mod)
    return mod


class CheaperInferenceImageTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.ci = _load()

    def test_data_url_png(self) -> None:
        png = b"\x89PNG\r\n\x1a\n" + b"\x00" * 8
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "a.png"
            p.write_bytes(png)
            url = self.ci._data_url(p)
            self.assertTrue(url.startswith("data:image/png;base64,"))
            self.assertEqual(base64.b64decode(url.split(",", 1)[1]), png)

    def test_save_image_b64(self) -> None:
        raw = b"\xff\xd8\xff" + b"jpeg-bytes"
        payload = {"data": [{"b64_json": base64.b64encode(raw).decode()}]}
        with tempfile.TemporaryDirectory() as tmp:
            out = self.ci._save_image(payload, Path(tmp) / "out.png")
            self.assertEqual(out.read_bytes(), raw)

    def test_generate_requires_key(self) -> None:
        env = os.environ.copy()
        os.environ.pop("CHEAPERINFERENCE_API_KEY", None)
        try:
            with self.assertRaises(SystemExit) as ctx:
                self.ci.main(["generate", "--prompt", "x", "--out", "/tmp/x.png"])
            self.assertEqual(ctx.exception.code, 1)
        finally:
            os.environ.clear()
            os.environ.update(env)

    def test_meta_shape(self) -> None:
        meta = self.ci._meta(
            {"request_id": "r1", "billing": {"billed_cost_usd": "0.01"}, "created": 1},
            "flux-2-max",
            "images.generations",
            Path("o.png"),
        )
        self.assertEqual(meta["tool"], "Cheaper Inference")
        self.assertEqual(meta["operation"], "images.generations")
        self.assertEqual(meta["request_id"], "r1")
        json.dumps(meta)  # serializable


if __name__ == "__main__":
    unittest.main()

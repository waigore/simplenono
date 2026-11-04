#!/usr/bin/env python3
"""Serve specs/ux/mockups on 0.0.0.0 with a generated index. Writes nothing."""

from __future__ import annotations

import argparse
import html
import json
import re
import shutil
import socket
import subprocess
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlopen

PORT_START = 4173
PORT_TRIES = 10
IDENTITY_PATH = "/__serve_ux_mockups"
TITLE_RE = re.compile(r"<title>(.*?)</title>", re.IGNORECASE | re.DOTALL)
H1_RE = re.compile(r"<h1>(.*?)</h1>", re.IGNORECASE | re.DOTALL)
TAG_RE = re.compile(r"<[^>]+>")
TAILSCALE_BIN = "tailscale"


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "specs" / "ux" / "mockups").is_dir() and (parent / ".agents").is_dir():
            return parent
    raise SystemExit("Could not find specs/ux/mockups from the script path.")


def mockup_root(root: Path) -> Path:
    path = (root / "specs" / "ux" / "mockups").resolve()
    if not path.is_dir():
        raise SystemExit(f"Missing mockup directory: {path}")
    return path


def lan_ips() -> list[str]:
    found: list[str] = []
    probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        probe.connect(("8.8.8.8", 80))
        ip = probe.getsockname()[0]
        if ip and not ip.startswith("127."):
            found.append(ip)
    except OSError:
        pass
    finally:
        probe.close()
    return found


def tailscale_status() -> dict:
    if not shutil.which(TAILSCALE_BIN):
        raise RuntimeError(f"{TAILSCALE_BIN} CLI not found on PATH")
    try:
        completed = subprocess.run(
            [TAILSCALE_BIN, "status", "--json"],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as exc:
        detail = (exc.stderr or exc.stdout or str(exc)).strip()
        raise RuntimeError(detail or "tailscale status failed") from exc
    try:
        data = json.loads(completed.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError("tailscale status --json returned invalid JSON") from exc
    if data.get("BackendState") != "Running":
        state = data.get("BackendState") or "unknown"
        raise RuntimeError(f"Tailscale is not running (BackendState={state})")
    return data


def tailscale_https_base(status: dict) -> str:
    self_node = status.get("Self") or {}
    dns = (self_node.get("DNSName") or "").rstrip(".")
    if not dns:
        raise RuntimeError("Tailscale MagicDNS name missing from status")
    return f"https://{dns}/"


def enable_tailscale_serve(port: int) -> str:
    """Proxy the local port via Tailscale Serve (HTTPS on :443). Returns the base URL."""
    status = tailscale_status()
    base = tailscale_https_base(status)
    try:
        subprocess.run(
            [TAILSCALE_BIN, "serve", "--bg", "--yes", str(port)],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as exc:
        detail = (exc.stderr or exc.stdout or str(exc)).strip()
        raise RuntimeError(detail or "tailscale serve failed") from exc
    return base


def reset_tailscale_serve() -> None:
    if not shutil.which(TAILSCALE_BIN):
        return
    subprocess.run(
        [TAILSCALE_BIN, "serve", "reset"],
        check=False,
        capture_output=True,
        text=True,
    )


def page_label(path: Path) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    match = TITLE_RE.search(text) or H1_RE.search(text)
    if not match:
        return path.stem
    label = TAG_RE.sub("", match.group(1))
    label = " ".join(label.split())
    return label or path.stem


def list_pages(directory: Path) -> list[tuple[str, str]]:
    if not directory.is_dir():
        return []
    pages = []
    for path in sorted(directory.glob("*.html")):
        if path.name.startswith("_"):
            continue
        rel = path.relative_to(directory.parent).as_posix()
        pages.append((rel, page_label(path)))
    return pages


def render_index(root: Path) -> bytes:
    screens = list_pages(root / "screens")
    journeys = list_pages(root / "journeys")

    def items(pages: list[tuple[str, str]], empty: str) -> str:
        if not pages:
            return f"<li>{html.escape(empty)}</li>"
        return "\n".join(
            f'<li><a href="{html.escape(href)}">{html.escape(label)}</a></li>'
            for href, label in pages
        )

    body = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UX mockups</title>
  <style>
    :root {{ --fg: #1a1a1a; --bg: #f7f6f3; --accent: #0b57d0; --muted: #5c574e; }}
    body {{ margin: 0; font: 16px/1.4 system-ui, sans-serif; color: var(--fg); background: var(--bg); }}
    main {{ max-width: 40rem; margin: 0 auto; padding: 1rem; }}
    a {{ color: var(--accent); }}
    p {{ color: var(--muted); }}
  </style>
</head>
<body>
  <main>
    <h1>UX mockups</h1>
    <p>Generated index. Screen and journey files are served as static HTML.</p>
    <h2>Screens</h2>
    <ul>
      {items(screens, "No screen mockups yet.")}
    </ul>
    <h2>Journeys</h2>
    <ul>
      {items(journeys, "No journey mockups yet.")}
    </ul>
  </main>
</body>
</html>
"""
    return body.encode("utf-8")


def existing_server(port: int, root: Path) -> bool:
    try:
        with urlopen(f"http://127.0.0.1:{port}{IDENTITY_PATH}", timeout=0.5) as response:
            data = json.loads(response.read().decode("utf-8"))
    except (URLError, TimeoutError, OSError, json.JSONDecodeError, ValueError):
        return False
    return data.get("root") == str(root)


def make_handler(root: Path):
    index = render_index(root)

    class Handler(SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(root), **kwargs)

        def do_GET(self) -> None:  # noqa: N802
            path = self.path.split("?", 1)[0]
            if path in ("/", "/index.html"):
                self._send(200, "text/html; charset=utf-8", index)
                return
            if path == IDENTITY_PATH:
                payload = json.dumps({"ok": True, "root": str(root)}).encode("utf-8")
                self._send(200, "application/json", payload)
                return
            super().do_GET()

        def _send(self, status: int, content_type: str, body: bytes) -> None:
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, fmt: str, *args) -> None:
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    return Handler


def announce(
    status: str,
    port: int,
    target: str | None,
    *,
    tailscale_url: str | None = None,
    tailscale_error: str | None = None,
) -> None:
    print(f"status: {status}", flush=True)
    print(f"port: {port}", flush=True)
    print(f"localhost: http://127.0.0.1:{port}/", flush=True)
    ips = lan_ips()
    if ips:
        for ip in ips:
            print(f"lan: http://{ip}:{port}/", flush=True)
    else:
        print("lan: none", flush=True)
    if tailscale_url:
        print(f"tailscale: {tailscale_url}", flush=True)
    elif tailscale_error:
        print(f"tailscale: error: {tailscale_error}", flush=True)
    if target:
        print(f"target: http://127.0.0.1:{port}/{target.lstrip('/')}", flush=True)
        if tailscale_url:
            print(
                f"target-tailscale: {tailscale_url.rstrip('/')}/{target.lstrip('/')}",
                flush=True,
            )


def choose_port(root: Path, preferred: int) -> tuple[str, int]:
    for offset in range(PORT_TRIES):
        port = preferred + offset
        if existing_server(port, root):
            return "reused", port
        probe = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            probe.bind(("0.0.0.0", port))
        except OSError:
            continue
        finally:
            probe.close()
        return "serving", port
    raise SystemExit(f"No free port in {preferred}..{preferred + PORT_TRIES - 1}.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=PORT_START)
    parser.add_argument(
        "--target",
        help="Mockup path under specs/ux/mockups, such as screens/title.html",
    )
    parser.add_argument(
        "--tailscale",
        action="store_true",
        help="Expose via Tailscale Serve as https://<MagicDNS>/ (tailnet only)",
    )
    args = parser.parse_args()
    root = mockup_root(repo_root())
    status, port = choose_port(root, args.port)

    tailscale_url: str | None = None
    tailscale_error: str | None = None
    tailscale_owned = False
    if args.tailscale:
        try:
            tailscale_url = enable_tailscale_serve(port)
            tailscale_owned = True
        except RuntimeError as exc:
            tailscale_error = str(exc)

    announce(
        status,
        port,
        args.target,
        tailscale_url=tailscale_url,
        tailscale_error=tailscale_error,
    )
    if status == "reused":
        return
    server = ThreadingHTTPServer(("0.0.0.0", port), make_handler(root))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
    finally:
        if tailscale_owned:
            reset_tailscale_serve()


if __name__ == "__main__":
    main()

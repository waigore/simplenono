"""Image → binary nonogram pipeline (PoC)."""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter, ImageOps

from nonogram import (
    EMPTY,
    FILL,
    SolveResult,
    acceptable,
    clues_from_grid,
    fill_ratio,
    solve_and_judge,
)


@dataclass
class PuzzleArtifact:
    slug: str
    size: int
    fill_ratio: float
    unique: bool
    logic_solved: bool
    sweeps: int
    dfs_nodes: int
    acceptable: bool
    reason: str
    threshold: float
    row_clues: list[list[int]]
    col_clues: list[list[int]]
    adapt_flips: int


def to_greyscale(img: Image.Image) -> Image.Image:
    return ImageOps.autocontrast(img.convert("L"))


def area_resize_grey(grey: Image.Image, n: int) -> np.ndarray:
    """Area-average resize to n×n, float intensities 0..255."""
    small = grey.resize((n, n), Image.Resampling.BOX)
    return np.asarray(small, dtype=np.float32)


def threshold_grid(intensities: np.ndarray, t: float) -> np.ndarray:
    # dark → fill
    return (intensities <= t).astype(np.int8)


def morph_clean(grid: np.ndarray) -> np.ndarray:
    """Remove isolated fills/empties (4-neighbour)."""
    g = grid.copy()
    h, w = g.shape
    for _ in range(2):
        nxt = g.copy()
        for y in range(h):
            for x in range(w):
                neigh = []
                for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < h and 0 <= nx < w:
                        neigh.append(int(g[ny, nx]))
                if not neigh:
                    continue
                if sum(neigh) <= 1 and g[y, x] == FILL:
                    nxt[y, x] = EMPTY
                if sum(neigh) >= len(neigh) - 1 and g[y, x] == EMPTY and sum(neigh) >= 3:
                    nxt[y, x] = FILL
        g = nxt
    return g


def dilate(grid: np.ndarray, times: int = 1) -> np.ndarray:
    g = grid.copy()
    h, w = g.shape
    for _ in range(times):
        nxt = g.copy()
        for y in range(h):
            for x in range(w):
                if g[y, x] == FILL:
                    continue
                for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < h and 0 <= nx < w and g[ny, nx] == FILL:
                        nxt[y, x] = FILL
                        break
        g = nxt
    return g


def search_threshold(
    intensities: np.ndarray, lo: float = 0.28, hi: float = 0.42
) -> list[tuple[float, np.ndarray, float]]:
    """Return candidate (threshold, grid, ratio), preferring fill band."""
    tried: list[tuple[float, np.ndarray, float]] = []
    thresholds: list[float] = []
    thresholds.extend(float(t) for t in np.unique(intensities))
    thresholds.extend(float(np.percentile(intensities, p)) for p in range(5, 96, 1))
    # stable unique-ish order
    seen: set[float] = set()
    for t in thresholds:
        key = round(t, 4)
        if key in seen:
            continue
        seen.add(key)
        g = morph_clean(threshold_grid(intensities, t))
        r = fill_ratio(g)
        if r <= 0.02 or r >= 0.85:
            continue
        tried.append((t, g, r))

    in_band = [c for c in tried if lo <= c[2] <= hi]
    if in_band:
        # prefer closer to 35% fill
        in_band.sort(key=lambda c: abs(c[2] - 0.35))
        return in_band
    # fallback: closest to 35%
    tried.sort(key=lambda c: abs(c[2] - 0.35))
    return tried[:12]


def adapt_unique(grid: np.ndarray, intensities: np.ndarray, max_flips: int = 24) -> tuple[np.ndarray, SolveResult, int]:
    """Flip EMPTY→FILL preferring darkest cells until unique or budget exhausted."""
    g = grid.copy()
    result = solve_and_judge(g)
    flips = 0
    if result.unique:
        return g, result, flips

    # candidates: empty cells, darkest first
    order = np.argsort(intensities, axis=None)
    h, w = g.shape
    for flat in order:
        if flips >= max_flips:
            break
        y, x = divmod(int(flat), w)
        if g[y, x] != EMPTY:
            continue
        # only flip if reasonably dark
        if intensities[y, x] > np.percentile(intensities, 55):
            continue
        trial = g.copy()
        trial[y, x] = FILL
        trial = morph_clean(trial)
        # keep fill band soft check
        r = fill_ratio(trial)
        if r > 0.48:
            continue
        jr = solve_and_judge(trial)
        flips += 1
        g = trial
        result = jr
        if jr.unique:
            break
    return g, result, flips


def grid_to_png(grid: np.ndarray, path: Path, scale: int = 32) -> None:
    h, w = grid.shape
    img = Image.new("L", (w, h))
    pixels = img.load()
    for y in range(h):
        for x in range(w):
            pixels[x, y] = 0 if grid[y, x] == FILL else 255
    img.resize((w * scale, h * scale), Image.Resampling.NEAREST).save(path)


def build_puzzle_from_image(
    source_path: Path,
    out_dir: Path,
    slug: str,
    size: int = 15,
) -> PuzzleArtifact:
    out_dir.mkdir(parents=True, exist_ok=True)
    img = Image.open(source_path)
    grey = to_greyscale(img)
    # slight blur before box resize to reduce alias noise
    grey = grey.filter(ImageFilter.BoxBlur(1))
    intensities = area_resize_grey(grey, size)

    best: PuzzleArtifact | None = None
    best_grid: np.ndarray | None = None

    bases: list[tuple[float, np.ndarray]] = []
    for t, base, ratio in search_threshold(intensities):
        bases.append((t, base))
        if ratio < 0.28:
            for d in (1, 2):
                thick = morph_clean(dilate(base, d))
                bases.append((t, thick))

    seen_grids: set[bytes] = set()
    for t, base in bases:
        key = base.tobytes()
        if key in seen_grids:
            continue
        seen_grids.add(key)
        grid, result, flips = adapt_unique(base, intensities)
        ok, reason = acceptable(result, grid)
        rows, cols = clues_from_grid(grid)
        art = PuzzleArtifact(
            slug=slug,
            size=size,
            fill_ratio=fill_ratio(grid),
            unique=result.unique,
            logic_solved=result.logic_solved,
            sweeps=result.sweeps,
            dfs_nodes=result.dfs_nodes,
            acceptable=ok,
            reason=reason,
            threshold=t,
            row_clues=rows,
            col_clues=cols,
            adapt_flips=flips,
        )
        if ok:
            best = art
            best_grid = grid
            break
        if best is None or (art.unique and not best.unique) or (
            art.unique == best.unique
            and abs(art.fill_ratio - 0.35) < abs(best.fill_ratio - 0.35)
        ):
            best = art
            best_grid = grid

    assert best is not None and best_grid is not None

    if not best.acceptable and size == 15:
        return build_puzzle_from_image(source_path, out_dir, slug, size=10)

    grid_to_png(best_grid, out_dir / "grid.png")
    payload = {
        **asdict(best),
        "grid": best_grid.tolist(),
    }
    (out_dir / "puzzle.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    # copy/link source name
    return best

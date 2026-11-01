"""Image → pixel-colour solution + binary nonogram pipeline (PoC)."""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

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


def pixelate_rgb(img: Image.Image, n: int) -> np.ndarray:
    """Area-average to n×n RGB uint8 — one colour per nonogram cell (morph target)."""
    rgb = img.convert("RGB")
    small = rgb.resize((n, n), Image.Resampling.BOX)
    return np.asarray(small, dtype=np.uint8)


def luminance(rgb: np.ndarray) -> np.ndarray:
    """Rec. 601 luma, float 0..255."""
    r = rgb[:, :, 0].astype(np.float32)
    g = rgb[:, :, 1].astype(np.float32)
    b = rgb[:, :, 2].astype(np.float32)
    return 0.299 * r + 0.587 * g + 0.114 * b


def flatten_background(rgb: np.ndarray, edge: int = 1) -> np.ndarray:
    """Snap near-border cells toward median border colour to kill vignette fills."""
    out = rgb.copy()
    h, w, _ = out.shape
    border = np.concatenate(
        [
            out[:edge, :, :].reshape(-1, 3),
            out[-edge:, :, :].reshape(-1, 3),
            out[:, :edge, :].reshape(-1, 3),
            out[:, -edge:, :].reshape(-1, 3),
        ],
        axis=0,
    )
    bg = np.median(border, axis=0)
    bg_lum = float(0.299 * bg[0] + 0.587 * bg[1] + 0.114 * bg[2])
    # Only snap cells that are already bright-ish (background candidates)
    lum = luminance(out)
    for y in range(h):
        for x in range(w):
            on_edge = y < edge or y >= h - edge or x < edge or x >= w - edge
            if on_edge and lum[y, x] >= bg_lum - 40:
                out[y, x] = bg.astype(np.uint8)
            elif lum[y, x] >= bg_lum - 12 and abs(float(lum[y, x]) - bg_lum) < 18:
                # near-bg interior noise → bg
                out[y, x] = bg.astype(np.uint8)
    return out


def threshold_grid(intensities: np.ndarray, t: float) -> np.ndarray:
    return (intensities <= t).astype(np.int8)


def morph_clean(grid: np.ndarray) -> np.ndarray:
    """Despeckle only: remove isolated fills. Do not close holes (keeps interior empties)."""
    g = grid.copy()
    h, w = g.shape
    for _ in range(2):
        nxt = g.copy()
        for y in range(h):
            for x in range(w):
                if g[y, x] != FILL:
                    continue
                neigh = []
                for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < h and 0 <= nx < w:
                        neigh.append(int(g[ny, nx]))
                if neigh and sum(neigh) <= 1:
                    nxt[y, x] = EMPTY
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
    tried: list[tuple[float, np.ndarray, float]] = []
    thresholds: list[float] = []
    thresholds.extend(float(t) for t in np.unique(intensities))
    thresholds.extend(float(np.percentile(intensities, p)) for p in range(5, 96, 1))
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
        in_band.sort(key=lambda c: abs(c[2] - 0.35))
        return in_band
    tried.sort(key=lambda c: abs(c[2] - 0.35))
    return tried[:12]


def adapt_line_logic(
    grid: np.ndarray, intensities: np.ndarray, max_flips: int = 40
) -> tuple[np.ndarray, SolveResult, int]:
    """Add dark fills until clues are uniquely solvable by line logic alone."""
    g = grid.copy()
    result = solve_and_judge(g)
    flips = 0
    if result.unique and result.logic_solved:
        return g, result, flips

    order = np.argsort(intensities, axis=None)  # darkest first
    h, w = g.shape
    for flat in order:
        if flips >= max_flips:
            break
        if result.unique and result.logic_solved:
            break
        y, x = divmod(int(flat), w)
        if g[y, x] != EMPTY:
            continue
        # Prefer subject pixels; allow slightly lighter than before for stubborn grids
        if intensities[y, x] > np.percentile(intensities, 65):
            continue
        trial = g.copy()
        trial[y, x] = FILL
        trial = morph_clean(trial)
        if fill_ratio(trial) > 0.48:
            continue
        jr = solve_and_judge(trial)
        # Keep flip only if it does not worsen uniqueness / contradiction
        if jr.solution_count == 0 and not jr.logic_solved and not jr.unique:
            # skip destructive flips that break clues consistency (shouldn't happen)
            continue
        flips += 1
        g = trial
        result = jr
        if jr.unique and jr.logic_solved:
            break
    return g, result, flips


def save_pixel_colour(rgb: np.ndarray, path: Path, scale: int = 64) -> None:
    """Nearest upscale so each cell is a flat colour block (morph-friendly)."""
    h, w, _ = rgb.shape
    img = Image.fromarray(rgb, mode="RGB")
    img.resize((w * scale, h * scale), Image.Resampling.NEAREST).save(path)


def grid_to_png(grid: np.ndarray, path: Path, scale: int = 32) -> None:
    h, w = grid.shape
    img = Image.new("L", (w, h))
    pixels = img.load()
    for y in range(h):
        for x in range(w):
            pixels[x, y] = 0 if grid[y, x] == FILL else 255
    img.resize((w * scale, h * scale), Image.Resampling.NEAREST).save(path)


def overlay_preview(rgb: np.ndarray, grid: np.ndarray, path: Path, scale: int = 64) -> None:
    """Colour cells where filled; light checker where empty — morph preview."""
    h, w, _ = rgb.shape
    out = np.full_like(rgb, 245)
    for y in range(h):
        for x in range(w):
            if grid[y, x] == FILL:
                out[y, x] = rgb[y, x]
            else:
                out[y, x] = (230, 230, 230) if (x + y) % 2 == 0 else (245, 245, 245)
    save_pixel_colour(out, path, scale=scale)


def build_puzzle_from_image(
    source_path: Path,
    out_dir: Path,
    slug: str,
    size: int = 15,
) -> PuzzleArtifact:
    out_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(source_path)
    # Keep Flux original for comparison
    raw.convert("RGB").save(out_dir / "source_raw.png")

    rgb = flatten_background(pixelate_rgb(raw, size))
    intensities = luminance(rgb)
    # gentle autocontrast on luma for threshold search only
    lum_img = Image.fromarray(intensities.astype(np.uint8), mode="L")
    intensities = np.asarray(ImageOps.autocontrast(lum_img), dtype=np.float32)

    best: PuzzleArtifact | None = None
    best_grid: np.ndarray | None = None

    bases: list[tuple[float, np.ndarray]] = []
    for t, base, ratio in search_threshold(intensities):
        bases.append((t, base))
        if ratio < 0.28:
            for d in (1, 2):
                bases.append((t, morph_clean(dilate(base, d))))

    seen_grids: set[bytes] = set()
    for t, base in bases:
        key = base.tobytes()
        if key in seen_grids:
            continue
        seen_grids.add(key)
        grid, result, flips = adapt_line_logic(base, intensities)
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
        # Prefer line-logic unique, then closer to 35% fill
        def rank(a: PuzzleArtifact) -> tuple:
            return (
                0 if (a.unique and a.logic_solved) else 1,
                0 if a.logic_solved else 1,
                0 if a.unique else 1,
                abs(a.fill_ratio - 0.35),
            )

        if best is None or rank(art) < rank(best):
            best = art
            best_grid = grid

    assert best is not None and best_grid is not None

    if not best.acceptable and size == 15:
        return build_puzzle_from_image(source_path, out_dir, slug, size=10)

    # Solution picture = pixel colour map (1 cell = 1 colour), nearest-scaled
    save_pixel_colour(rgb, out_dir / "source.png", scale=64)
    np.save(out_dir / "pixels.npy", rgb)
    grid_to_png(best_grid, out_dir / "grid.png")
    overlay_preview(rgb, best_grid, out_dir / "morph_preview.png")
    payload = {
        **asdict(best),
        "grid": best_grid.tolist(),
        "pixels_rgb": rgb.tolist(),
    }
    (out_dir / "puzzle.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return best

"""Nonogram clues, line-logic solver, uniqueness, and difficulty heuristics."""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache

import numpy as np

UNKNOWN = -1
EMPTY = 0
FILL = 1


def runs_from_line(line) -> list[int]:
    runs: list[int] = []
    count = 0
    for v in line:
        if int(v) == FILL:
            count += 1
        elif count:
            runs.append(count)
            count = 0
    if count:
        runs.append(count)
    return runs


def clues_from_grid(grid: np.ndarray) -> tuple[list[list[int]], list[list[int]]]:
    rows = [runs_from_line(row) for row in grid]
    cols = [runs_from_line(grid[:, c]) for c in range(grid.shape[1])]
    return rows, cols


@lru_cache(maxsize=None)
def _placements_cached(n: int, clues: tuple[int, ...]) -> tuple[tuple[int, ...], ...]:
    results: list[tuple[int, ...]] = []

    def build(idx: int, cursor: int, acc: list[int]) -> None:
        if idx == len(clues):
            results.append(tuple(acc + [EMPTY] * (n - len(acc))))
            return
        run = clues[idx]
        remaining = clues[idx + 1 :]
        min_tail = sum(remaining) + len(remaining)
        last_start = n - run - min_tail
        for s in range(cursor, last_start + 1):
            gap = [EMPTY] * (s - len(acc))
            block = [FILL] * run
            nxt = acc + gap + block
            if idx + 1 < len(clues):
                build(idx + 1, len(nxt) + 1, nxt + [EMPTY])
            else:
                build(idx + 1, len(nxt), nxt)

    build(0, 0, [])
    return tuple(results)


def placements(n: int, clues: list[int]) -> list[np.ndarray]:
    raw = _placements_cached(n, tuple(clues))
    return [np.array(p, dtype=np.int8) for p in raw]


def _consistent(placement: np.ndarray, known: np.ndarray) -> bool:
    mask = known != UNKNOWN
    return bool(np.all(placement[mask] == known[mask]))


def line_deduce(known: np.ndarray, clues: list[int]) -> np.ndarray | None:
    opts = [p for p in placements(len(known), clues) if _consistent(p, known)]
    if not opts:
        return None
    stacked = np.stack(opts)
    out = known.copy()
    for i in range(len(known)):
        if out[i] != UNKNOWN:
            continue
        col = stacked[:, i]
        if np.all(col == FILL):
            out[i] = FILL
        elif np.all(col == EMPTY):
            out[i] = EMPTY
    return out


def propagate(
    state: np.ndarray, row_clues: list[list[int]], col_clues: list[list[int]]
) -> tuple[np.ndarray | None, int]:
    work = state.copy()
    sweeps = 0
    h, w = work.shape
    while True:
        sweeps += 1
        changed = False
        for r in range(h):
            updated = line_deduce(work[r], row_clues[r])
            if updated is None:
                return None, sweeps
            if not np.array_equal(updated, work[r]):
                work[r] = updated
                changed = True
        for c in range(w):
            updated = line_deduce(work[:, c], col_clues[c])
            if updated is None:
                return None, sweeps
            if not np.array_equal(updated, work[:, c]):
                work[:, c] = updated
                changed = True
        if not changed:
            return work, sweeps
        if sweeps > h * w * 4:
            return work, sweeps


@dataclass
class SolveResult:
    unique: bool
    logic_solved: bool
    sweeps: int
    dfs_nodes: int
    solution_count: int


def solve_and_judge(solution: np.ndarray) -> SolveResult:
    solution = solution.astype(np.int8)
    row_clues, col_clues = clues_from_grid(solution)
    h, w = solution.shape
    blank = np.full((h, w), UNKNOWN, dtype=np.int8)

    prop, sweeps = propagate(blank, row_clues, col_clues)
    if prop is None:
        return SolveResult(False, False, sweeps, 0, 0)

    if np.all(prop != UNKNOWN):
        ok = bool(np.array_equal(prop, solution))
        return SolveResult(ok, ok, sweeps, 0, 1 if ok else 0)

    nodes = 0
    found_grids: list[np.ndarray] = []

    def dfs(state: np.ndarray) -> None:
        nonlocal nodes
        if len(found_grids) >= 2:
            return
        nodes += 1
        advanced, _ = propagate(state, row_clues, col_clues)
        if advanced is None:
            return
        if np.all(advanced != UNKNOWN):
            found_grids.append(advanced.copy())
            return
        r, c = map(int, np.argwhere(advanced == UNKNOWN)[0])
        for val in (FILL, EMPTY):
            nxt = advanced.copy()
            nxt[r, c] = val
            dfs(nxt)
            if len(found_grids) >= 2:
                return

    dfs(prop)
    count = len(found_grids)
    unique = count == 1 and bool(np.array_equal(found_grids[0], solution))
    return SolveResult(unique, False, sweeps, nodes, min(count, 2))


def fill_ratio(grid: np.ndarray) -> float:
    return float(np.mean(grid == FILL))


def acceptable(result: SolveResult, grid: np.ndarray) -> tuple[bool, str]:
    ratio = fill_ratio(grid)
    if not result.unique:
        return False, f"not unique (count>={result.solution_count})"
    if ratio < 0.25 or ratio > 0.45:
        return False, f"fill {ratio:.0%} outside 25–45%"
    # Trivial: fully solved in one sweep with very sparse/dense edge cases already excluded
    if result.logic_solved and result.sweeps <= 1 and grid.shape[0] <= 10:
        return False, f"too easy (logic sweeps={result.sweeps} on {grid.shape[0]}²)"
    if not result.logic_solved and result.dfs_nodes > 80:
        return False, f"too hard (dfs_nodes={result.dfs_nodes})"
    return True, "ok"

"""Independent line-logic solver and enumerator for the #610 acceptance run.

Copy of the #565 acceptance `nonogram565.py` with the size made a parameter: this run
judges rows at 10x10, 15x15, and 20x20. Not imported from
`.github/scripts/puzzle_derive.py`: acceptance must not reuse the tool it is judging.
Used by `expectations_610.py` (offline) and by nothing under `game/`.
"""


def _placements_cache():
    return {}


_CACHE = _placements_cache()


def placements(clue, length):
    """Every mask (tuple of bool) matching one clue on a line of `length`."""
    key = (tuple(clue), length)
    cached = _CACHE.get(key)
    if cached is not None:
        return cached
    if clue == [] or clue == [0]:
        result = [tuple([False] * length)]
        _CACHE[key] = result
        return result
    out = []

    def rec(i, pos, acc):
        if i == len(clue):
            out.append(tuple(acc + [False] * (length - len(acc))))
            return
        rest = sum(clue[i:]) + (len(clue) - i - 1)
        for start in range(pos, length - rest + 1):
            line = acc + [False] * (start - len(acc)) + [True] * clue[i]
            if i < len(clue) - 1:
                line = line + [False]
            rec(i + 1, len(line), line)

    rec(0, 0, [])
    _CACHE[key] = out
    return out


def line_completions(clue, known):
    """Placements consistent with `known` (None = unknown)."""
    return [p for p in placements(clue, len(known))
            if all(k is None or k == v for k, v in zip(known, p))]


def line_logic(row_clues, col_clues, size):
    """Fixed-point unit propagation over rows and columns; None on a contradiction."""
    grid = [[None] * size for _ in range(size)]
    changed = True
    while changed:
        changed = False
        for r in range(size):
            opts = line_completions(row_clues[r], grid[r])
            if not opts:
                return None
            for c in range(size):
                vals = {o[c] for o in opts}
                if len(vals) == 1 and grid[r][c] is None:
                    grid[r][c] = vals.pop()
                    changed = True
        for c in range(size):
            opts = line_completions(col_clues[c], [grid[r][c] for r in range(size)])
            if not opts:
                return None
            for r in range(size):
                vals = {o[r] for o in opts}
                if len(vals) == 1 and grid[r][c] is None:
                    grid[r][c] = vals.pop()
                    changed = True
    return grid


def count_solutions(row_clues, col_clues, size, cap=2):
    """Number of solutions, capped: 1 means unique as far as a judge needs to know."""
    grid = [[None] * size for _ in range(size)]
    found = [0]

    def feasible(r, c):
        return bool(line_completions(row_clues[r], grid[r])) and \
            bool(line_completions(col_clues[c], [grid[i][c] for i in range(size)]))

    def rec(r, c):
        if found[0] >= cap:
            return
        if r == size:
            found[0] += 1
            return
        if c == size:
            rec(r + 1, 0)
            return
        for value in (True, False):
            grid[r][c] = value
            if feasible(r, c):
                rec(r, c + 1)
        grid[r][c] = None

    rec(0, 0)
    return found[0]

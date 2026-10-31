# Spatial Model

Authoring rules: [`.agents/specs/rules/view/spatial-model.md`](../../.agents/specs/rules/view/spatial-model.md).

- **Serves**: Calm tactile grid, Snappy solve — positions resolve on the open puzzle grid ([`view.md`](view.md), [`entities/cell.md`](../design/entities/cell.md)).

## Coordinate frame

| ID | Convention | Statement |
|----|------------|-----------|
| A1 | Axes | x = column index increasing right; y = row index increasing down |
| A2 | Origin | Top-left cell of the open puzzle (column 0, row 0) |
| A3 | Angles | N/A — flat grid; facing unused |

## Units and scale

| ID | Measure | Statement |
|----|---------|-----------|
| U1 | Length | 1 world unit = 1 cell |
| U2 | Time | Rates use seconds |

## Placement

| ID | Rule | Statement |
|----|------|-----------|
| P1 | Snap | Marks resolve to cell centers on the integer grid |
| P2 | Occupancy | Exactly one mark state per cell (clear, fill, or cross) |

## Object extents

| ID | Object | Extent (units) | Anchor | Facing |
|----|--------|----------------|--------|--------|
| E1 | Cell | 1 × 1 | Center | N/A — cells have no facing |

Clue chrome sits in UI margin outside this world body list.

## Layers and depth

| ID | Layer | Holds | Depth order | Parallax |
|----|-------|-------|-------------|----------|
| L1 | Board | Open puzzle grid | Fixed | 1 (no camera motion) |

## Bounds

| ID | Stage | Extent (units) | Edge |
|----|-------|----------------|------|
| B1 | Open puzzle | `size` × `size` cells | Board edge; no wrap or fall-out |

class_name PresentationPalette
extends RefCounted
## Palette swatches for presentation drawing ([code]PAL.S1[/code],
## specs/aesthetics/palette.md C1-C10).
##
## The swatches are the only colors the board and chrome use ([code]PAL.S1[/code]),
## C1-C10 in specs/aesthetics/palette.md. Solution pictures keep their own pixels and
## sit outside this set ([code]PER.R4[/code]); no screen in this module draws them yet.

## C1 Paper: clear cells and the ground behind the board and chrome.
const PAPER := Color("#F4F7F8")

## C2 Ink: filled cells and active text.
const INK := Color("#1B2833")

## C3 Cross: cross marks only.
const CROSS := Color("#5C6B78")

## C4 Rule: cell and panel borders.
const RULE := Color("#C5D0D6")

## C5 Dim: a clue line whose fills already satisfy its runs.
const DIM := Color("#6E7F8C")

## C6 Contradiction: the line-error signal only.
const CONTRADICTION := Color("#3A6F8F")

## C7 Major: major grid lines every 5 cells on the open board.
const MAJOR := Color("#B0BBC3")

## C8 Hint overlay: the single- and multi-line fill-hint ghosts only
## ([code]PER.R8[/code], specs/design/features/fill-hints.md R3).
const HINT := Color("#8FA2AF")

## C9 Fillable shade: the line-level fillable region only; lighter than C8
## ([code]PAL.K7[/code], [code]PER.R8[/code]).
const FILLABLE_SHADE := Color("#C2CDD4")

## C10 Gold: the hint-free gallery star only ([code]UIS.I1[/code]); the single warm
## chrome exception to the cool-neutral set ([code]PAL.K5[/code], [code]PAL.K8[/code]).
const GOLD := Color("#A67C00")

class_name PresentationPalette
extends RefCounted
## Palette swatches for presentation drawing ([code]PAL.S1[/code],
## specs/aesthetics/palette.md C1-C6).
##
## The six swatches are the only colors the board and chrome use. Solution
## pictures keep their own pixels and sit outside this set ([code]PER.R4[/code]);
## no screen in this module draws them yet.

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

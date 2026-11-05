# Issue #610 — K5 closing review notes

## What was judged

The pack as built on `main@4421dee`: 200 approved `V1` pairs, 400 picture files, and the
look of the 200 pictures as a pack. The judgement is the amended `K5` row in
[`specs/assets/kinds/puzzle-pictures.md`](../../../../../specs/assets/kinds/puzzle-pictures.md):
no two pairs deliver the same `N×N` picture (equal under any rotation or flip), and each
named scene is used by at most one pair per size band. `V2` stays a `Ban`; no class,
quota, or per-puzzle tag was added.

## How it was read

- `tools/pack_look_audit.py` reads the tree: catalog and manifest resolution, the `TL.2`
  derive re-run from every committed square with an independent implementation, an
  independent line-logic solver, duplicate-picture grouping under the 8 dihedral
  transforms, named-scene grouping from the generation prompts, near-twin square
  correlation, and per-band colour statistics.
- `tools/contact_sheet.py` renders one thumbnail sheet per size band and one for the
  replaced pairs; the sheets are on the wiki page (media does not live in git).
- The 17 replaced pairs were generated with `.github/scripts/picture_slice.py` from
  attempt plans that name a distinct scene per pair; the accepted prompt, request id,
  flatten background, fill count and judge facts are in each catalog `generation` record.

## Limitation of this run

This unattended run has no image input, so the `K4` look sentence in each regenerated
catalog entry is composed from the accepted generation prompt and corroborated by
measurement (mean saturation, 5–95% hue span, fill count, absence of dihedral symmetry),
not by opening the picture. The contact sheets are on the wiki page for the verification's
`review-asset` pass, which should open the 17 replaced pairs and confirm the look before
acceptance. Nothing else in the record depends on that: the duplicate-picture,
named-scene, resolution, derive and judge facts are all measured.

## Per-pair state after the change

`Version` is the square's catalog version; `Symmetric fill` is true when the `N×N` fill
equals a rotation or flip of itself (`K4` asymmetry).

| Puzzle | Size | Version | Filled | Band | Solutions | Symmetric fill |
|---|---|---|---|---|---|---|
| pack-000 | 10x10 | 2 | 41 | in | 1 | no |
| pack-001 | 10x10 | 2 | 42 | in | 1 | no |
| pack-002 | 10x10 | 3 | 33 | in | 1 | no |
| pack-003 | 10x10 | 2 | 40 | in | 1 | no |
| pack-004 | 10x10 | 2 | 40 | in | 1 | no |
| pack-005 | 10x10 | 2 | 38 | in | 1 | no |
| pack-006 | 10x10 | 2 | 37 | in | 1 | no |
| pack-007 | 10x10 | 2 | 35 | in | 1 | no |
| pack-008 | 10x10 | 2 | 31 | in | 1 | no |
| pack-009 | 10x10 | 2 | 45 | in | 1 | no |
| pack-010 | 15x15 | 1 | 59 | in | 1 | yes |
| pack-011 | 15x15 | 1 | 100 | in | 1 | yes |
| pack-012 | 15x15 | 1 | 77 | in | 1 | no |
| pack-013 | 15x15 | 1 | 70 | in | 1 | no |
| pack-014 | 15x15 | 1 | 67 | in | 1 | no |
| pack-015 | 15x15 | 1 | 66 | in | 1 | no |
| pack-016 | 15x15 | 1 | 70 | in | 1 | yes |
| pack-017 | 15x15 | 1 | 63 | in | 1 | no |
| pack-018 | 15x15 | 2 | 91 | in | 1 | no |
| pack-019 | 15x15 | 1 | 89 | in | 1 | no |
| pack-020 | 15x15 | 1 | 56 | in | 1 | no |
| pack-021 | 15x15 | 1 | 90 | in | 1 | yes |
| pack-022 | 15x15 | 1 | 72 | in | 1 | yes |
| pack-023 | 15x15 | 1 | 76 | in | 1 | no |
| pack-024 | 15x15 | 1 | 80 | in | 1 | no |
| pack-025 | 15x15 | 1 | 80 | in | 1 | no |
| pack-026 | 15x15 | 1 | 59 | in | 1 | no |
| pack-027 | 15x15 | 1 | 66 | in | 1 | no |
| pack-028 | 15x15 | 1 | 100 | in | 1 | yes |
| pack-029 | 15x15 | 1 | 86 | in | 1 | no |
| pack-030 | 15x15 | 1 | 71 | in | 1 | no |
| pack-031 | 15x15 | 1 | 64 | in | 1 | no |
| pack-032 | 15x15 | 1 | 81 | in | 1 | yes |
| pack-033 | 15x15 | 1 | 62 | in | 1 | yes |
| pack-034 | 15x15 | 1 | 60 | in | 1 | no |
| pack-035 | 15x15 | 2 | 94 | in | 1 | no |
| pack-036 | 15x15 | 1 | 61 | in | 1 | yes |
| pack-037 | 15x15 | 1 | 56 | in | 1 | yes |
| pack-038 | 15x15 | 1 | 97 | in | 1 | no |
| pack-039 | 15x15 | 1 | 91 | in | 1 | no |
| pack-040 | 15x15 | 1 | 57 | in | 1 | no |
| pack-041 | 15x15 | 1 | 70 | in | 1 | no |
| pack-042 | 15x15 | 1 | 56 | in | 1 | no |
| pack-043 | 15x15 | 1 | 61 | in | 1 | no |
| pack-044 | 15x15 | 1 | 62 | in | 1 | yes |
| pack-045 | 15x15 | 1 | 80 | in | 1 | no |
| pack-046 | 15x15 | 1 | 81 | in | 1 | yes |
| pack-047 | 15x15 | 1 | 60 | in | 1 | no |
| pack-048 | 15x15 | 1 | 99 | in | 1 | no |
| pack-049 | 15x15 | 2 | 93 | in | 1 | no |
| pack-050 | 15x15 | 1 | 94 | in | 1 | no |
| pack-051 | 15x15 | 1 | 93 | in | 1 | no |
| pack-052 | 15x15 | 2 | 71 | in | 1 | no |
| pack-053 | 15x15 | 1 | 72 | in | 1 | no |
| pack-054 | 15x15 | 1 | 63 | in | 1 | yes |
| pack-055 | 15x15 | 1 | 58 | in | 1 | no |
| pack-056 | 15x15 | 1 | 76 | in | 1 | yes |
| pack-057 | 15x15 | 1 | 60 | in | 1 | no |
| pack-058 | 15x15 | 2 | 78 | in | 1 | no |
| pack-059 | 15x15 | 1 | 70 | in | 1 | no |
| pack-060 | 15x15 | 1 | 57 | in | 1 | no |
| pack-061 | 15x15 | 1 | 73 | in | 1 | no |
| pack-062 | 15x15 | 1 | 71 | in | 1 | no |
| pack-063 | 15x15 | 1 | 57 | in | 1 | yes |
| pack-064 | 15x15 | 1 | 59 | in | 1 | no |
| pack-065 | 15x15 | 1 | 93 | in | 1 | no |
| pack-066 | 15x15 | 1 | 97 | in | 1 | no |
| pack-067 | 15x15 | 1 | 56 | in | 1 | no |
| pack-068 | 15x15 | 1 | 62 | in | 1 | no |
| pack-069 | 15x15 | 2 | 68 | in | 1 | no |
| pack-070 | 15x15 | 1 | 85 | in | 1 | no |
| pack-071 | 15x15 | 1 | 92 | in | 1 | yes |
| pack-072 | 15x15 | 1 | 68 | in | 1 | no |
| pack-073 | 15x15 | 1 | 62 | in | 1 | no |
| pack-074 | 15x15 | 1 | 60 | in | 1 | no |
| pack-075 | 15x15 | 1 | 79 | in | 1 | yes |
| pack-076 | 15x15 | 1 | 61 | in | 1 | no |
| pack-077 | 15x15 | 1 | 58 | in | 1 | no |
| pack-078 | 15x15 | 1 | 84 | in | 1 | no |
| pack-079 | 15x15 | 1 | 91 | in | 1 | no |
| pack-080 | 15x15 | 1 | 72 | in | 1 | no |
| pack-081 | 15x15 | 2 | 67 | in | 1 | no |
| pack-082 | 15x15 | 1 | 56 | in | 1 | yes |
| pack-083 | 15x15 | 2 | 101 | in | 1 | no |
| pack-084 | 15x15 | 1 | 68 | in | 1 | no |
| pack-085 | 15x15 | 1 | 74 | in | 1 | no |
| pack-086 | 15x15 | 2 | 81 | in | 1 | no |
| pack-087 | 15x15 | 1 | 69 | in | 1 | yes |
| pack-088 | 15x15 | 1 | 66 | in | 1 | no |
| pack-089 | 15x15 | 1 | 81 | in | 1 | yes |
| pack-090 | 15x15 | 1 | 57 | in | 1 | no |
| pack-091 | 15x15 | 1 | 75 | in | 1 | yes |
| pack-092 | 15x15 | 2 | 89 | in | 1 | no |
| pack-093 | 15x15 | 1 | 60 | in | 1 | no |
| pack-094 | 15x15 | 1 | 64 | in | 1 | no |
| pack-095 | 15x15 | 1 | 65 | in | 1 | no |
| pack-096 | 15x15 | 1 | 57 | in | 1 | no |
| pack-097 | 15x15 | 1 | 56 | in | 1 | yes |
| pack-098 | 15x15 | 2 | 87 | in | 1 | no |
| pack-099 | 15x15 | 1 | 67 | in | 1 | no |
| pack-100 | 15x15 | 1 | 92 | in | 1 | no |
| pack-101 | 15x15 | 1 | 57 | in | 1 | no |
| pack-102 | 15x15 | 1 | 89 | in | 1 | no |
| pack-103 | 15x15 | 2 | 94 | in | 1 | no |
| pack-104 | 15x15 | 1 | 61 | in | 1 | no |
| pack-105 | 15x15 | 1 | 93 | in | 1 | no |
| pack-106 | 15x15 | 1 | 56 | in | 1 | no |
| pack-107 | 15x15 | 1 | 79 | in | 1 | no |
| pack-108 | 15x15 | 1 | 56 | in | 1 | no |
| pack-109 | 15x15 | 1 | 78 | in | 1 | no |
| pack-110 | 15x15 | 1 | 76 | in | 1 | no |
| pack-111 | 15x15 | 2 | 64 | in | 1 | no |
| pack-112 | 15x15 | 1 | 89 | in | 1 | no |
| pack-113 | 15x15 | 1 | 57 | in | 1 | no |
| pack-114 | 15x15 | 1 | 68 | in | 1 | no |
| pack-115 | 15x15 | 1 | 69 | in | 1 | no |
| pack-116 | 15x15 | 1 | 60 | in | 1 | no |
| pack-117 | 15x15 | 1 | 71 | in | 1 | no |
| pack-118 | 15x15 | 1 | 62 | in | 1 | no |
| pack-119 | 15x15 | 1 | 79 | in | 1 | no |
| pack-120 | 15x15 | 2 | 99 | in | 1 | no |
| pack-121 | 15x15 | 1 | 73 | in | 1 | no |
| pack-122 | 15x15 | 1 | 61 | in | 1 | no |
| pack-123 | 15x15 | 1 | 84 | in | 1 | no |
| pack-124 | 15x15 | 1 | 85 | in | 1 | yes |
| pack-125 | 15x15 | 1 | 61 | in | 1 | no |
| pack-126 | 15x15 | 1 | 72 | in | 1 | no |
| pack-127 | 15x15 | 1 | 61 | in | 1 | yes |
| pack-128 | 15x15 | 1 | 100 | in | 1 | no |
| pack-129 | 15x15 | 1 | 90 | in | 1 | no |
| pack-130 | 15x15 | 1 | 62 | in | 1 | no |
| pack-131 | 15x15 | 1 | 74 | in | 1 | no |
| pack-132 | 15x15 | 1 | 71 | in | 1 | no |
| pack-133 | 15x15 | 1 | 71 | in | 1 | no |
| pack-134 | 15x15 | 1 | 62 | in | 1 | no |
| pack-135 | 15x15 | 1 | 75 | in | 1 | no |
| pack-136 | 15x15 | 1 | 72 | in | 1 | no |
| pack-137 | 15x15 | 3 | 89 | in | 1 | no |
| pack-138 | 15x15 | 1 | 66 | in | 1 | no |
| pack-139 | 15x15 | 1 | 97 | in | 1 | no |
| pack-140 | 15x15 | 2 | 75 | in | 1 | no |
| pack-141 | 15x15 | 1 | 91 | in | 1 | no |
| pack-142 | 15x15 | 1 | 65 | in | 1 | no |
| pack-143 | 15x15 | 1 | 71 | in | 1 | no |
| pack-144 | 15x15 | 2 | 88 | in | 1 | no |
| pack-145 | 15x15 | 1 | 66 | in | 1 | no |
| pack-146 | 15x15 | 2 | 88 | in | 1 | no |
| pack-147 | 15x15 | 1 | 59 | in | 1 | yes |
| pack-148 | 15x15 | 1 | 95 | in | 1 | no |
| pack-149 | 15x15 | 1 | 80 | in | 1 | yes |
| pack-150 | 15x15 | 1 | 70 | in | 1 | no |
| pack-151 | 15x15 | 2 | 90 | in | 1 | no |
| pack-152 | 15x15 | 1 | 82 | in | 1 | no |
| pack-153 | 15x15 | 1 | 84 | in | 1 | no |
| pack-154 | 15x15 | 2 | 90 | in | 1 | no |
| pack-155 | 15x15 | 1 | 56 | in | 1 | no |
| pack-156 | 15x15 | 1 | 65 | in | 1 | no |
| pack-157 | 15x15 | 1 | 76 | in | 1 | yes |
| pack-158 | 15x15 | 1 | 82 | in | 1 | no |
| pack-159 | 15x15 | 1 | 83 | in | 1 | no |
| pack-160 | 15x15 | 2 | 89 | in | 1 | no |
| pack-161 | 15x15 | 1 | 75 | in | 1 | no |
| pack-162 | 15x15 | 1 | 71 | in | 1 | no |
| pack-163 | 15x15 | 1 | 74 | in | 1 | no |
| pack-164 | 15x15 | 1 | 95 | in | 1 | no |
| pack-165 | 15x15 | 1 | 74 | in | 1 | yes |
| pack-166 | 15x15 | 1 | 71 | in | 1 | yes |
| pack-167 | 15x15 | 2 | 82 | in | 1 | no |
| pack-168 | 15x15 | 1 | 90 | in | 1 | yes |
| pack-169 | 15x15 | 1 | 61 | in | 1 | no |
| pack-170 | 15x15 | 1 | 56 | in | 1 | no |
| pack-171 | 15x15 | 2 | 62 | in | 1 | no |
| pack-172 | 15x15 | 1 | 98 | in | 1 | no |
| pack-173 | 15x15 | 1 | 62 | in | 1 | no |
| pack-174 | 15x15 | 1 | 88 | in | 1 | yes |
| pack-175 | 15x15 | 1 | 68 | in | 1 | no |
| pack-176 | 15x15 | 1 | 73 | in | 1 | no |
| pack-177 | 15x15 | 1 | 64 | in | 1 | no |
| pack-178 | 15x15 | 1 | 67 | in | 1 | no |
| pack-179 | 15x15 | 1 | 69 | in | 1 | yes |
| pack-180 | 20x20 | 2 | 163 | in | 1 | no |
| pack-181 | 20x20 | 1 | 137 | in | 1 | no |
| pack-182 | 20x20 | 2 | 135 | in | 1 | no |
| pack-183 | 20x20 | 1 | 105 | in | 1 | no |
| pack-184 | 20x20 | 3 | 113 | in | 1 | no |
| pack-185 | 20x20 | 1 | 144 | in | 1 | no |
| pack-186 | 20x20 | 2 | 161 | in | 1 | no |
| pack-187 | 20x20 | 1 | 129 | in | 1 | no |
| pack-188 | 20x20 | 3 | 139 | in | 1 | no |
| pack-189 | 20x20 | 1 | 119 | in | 1 | no |
| pack-190 | 20x20 | 2 | 166 | in | 1 | no |
| pack-191 | 20x20 | 1 | 138 | in | 1 | no |
| pack-192 | 20x20 | 2 | 105 | in | 1 | no |
| pack-193 | 20x20 | 1 | 126 | in | 1 | no |
| pack-194 | 20x20 | 2 | 180 | in | 1 | no |
| pack-195 | 20x20 | 1 | 118 | in | 1 | no |
| pack-196 | 20x20 | 2 | 164 | in | 1 | no |
| pack-197 | 20x20 | 1 | 139 | in | 1 | no |
| pack-198 | 20x20 | 2 | 169 | in | 1 | no |
| pack-199 | 20x20 | 1 | 148 | in | 1 | no |

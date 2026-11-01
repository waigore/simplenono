# Criteria — issue #105 graphical acceptance run

Build `main@effca0a`. Story/protocol rows are the playtest half; numbered rows are the issue's
acceptance criteria.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | O8 yields one `SCH-puzzle-def` per accepted entry with F1–F7 from pack data | **Pass** | `accepted=200 rejected=0`; three opened ids render size, clues, solved fills; `test_field_mapping_from_pack_data` |
| 2 | I1, I2, I3 hold; F2 ∈ {10,15,20} | **Pass** | [`audit`](logs/independent-pack-audit.log): runs recomputed for all 200 entries, 0 errors; `00`/`04`/`05` |
| 3 | O8 returns accepted count and rejected entries | **Pass** | `PackLoadResult`: 200 accepted, `rejected == []`; `test_rejected_entries_carry_their_raw_entry_and_reason` |
| 4 | Bad entry logged and skipped; rest loads; never reaches O3 | **Pass** | GUT: one case per class (missing field, size, I1/I2/I3, duplicate F1/F6/F7, F6 = F7); [`suite`](logs/gut-suite.log) |
| 5 | Bad file → empty pack, error logged **with the path** | **Pass** | GUT: missing / invalid JSON / not-an-array asserted against the captured log |
| 6 | O3 serves the record; unknown id changes nothing (G2) | **Pass** | `DBG.2` per id; clue bars equal F3/F4; `no-such-puzzle` opens nothing |
| 7 | GUT covers the minimum set; suite exits 0 | **Pass** | [`suite`](logs/gut-suite.log): 11 scripts, 139/139, 29 204 asserts, exit 0 |
| 8 | No L1/L2 import; no operation beyond O8 and O3 | **Pass** | `grep` over `game/records/`: no `presentation`/`play` import; public surface is `load_pack`, `definition`, plus `#108`'s accessors |
| 9 | No progress/commit/record-solve/reset/`user://` code added here | **Pass** | `git diff 4c8d1e5 HEAD` over the loader files: only `#108`/`#132` additions and `#127` formatting |

## Playtest

| Story or protocol | Verdict | Evidence |
|---|---|---|
| `E-puzzle` PS1.1 P1/P2/P3/P4 | **Pass** | 10/15/20 boards; solve from the entry's fills (`03`); clue bars match; served id |
| `PTD-ready-and-marks` S1–S4, P1–P3 | **Pass** | `00`–`07`, [`notes.md`](notes.md), `TEL.*` in [`console`](logs/capture-console.log) |

No `F1`/`F2` condition triggered: no playtest fail, no defect.

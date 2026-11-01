# Playtest gap — issue #105

Why this issue cannot pass the `accept-project-issue` playtest gate at its own layer.

## What `playtest.md` asks

> Required at `status:pending-acceptance` … when the issue's deliverables change playable behavior
> (game or code).

`playtest.md` **Gate** conflates "code" with playable behavior. #105 is code (`CMP-pack` R5 / `CTR-pack`
O8 + O3), so the gate fires. But the deliverable is L3 records loading, with no screen and no caller:
`CMP-shell` and `CMP-attempt` — the consumers of [`CTR-pack`](../../../../../specs/technical/contracts/pack.md)
— land in #108–#111.

## What the evidence rules then require

[`evidence.md`](../../../../../specs/playtest/evidence.md) requires, before acceptance, ≥1 screenshot of
each pass state from a **graphical run of the same build**. The only shipped protocol that cites
`E-puzzle` is `PTD-ready-and-marks`, and it says "Default evidence rules" (not "none"). Its steps need
`DBG.3`, a gallery, and a board. This build has none of those, so:

- the run cannot drive the protocol;
- the run cannot produce the judged state;
- every accept dispatch of #105 lands on the same "waiting on screenshots" outcome with nothing new to
  say, which is the deadlock already recorded for #106/#107 in
  [`../../accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md).

## Options, all owned by a human or the planner

1. **Scope the gate to playable deliverables.** `playtest.md` **Gate** reads "change playable behavior
  (game or code)" and exempts only spec-only, docs-only, and other non-playable deliverables. A task whose
  deliverable is records or domain code with no shipped caller (no screen, no gallery, no attempt — the
  `CMP-shell` / `CMP-attempt` consumers of `CTR-pack` land in #108–#111) is not "playable" in any sense a
  player can observe. Say so explicitly, and route its acceptance to seam evidence
  (`verification.md` S6/S7) with playtesting judged at the leaf that ships the screen (#110/#111/#112).
  `playtest.md` has no code-only path today: the gate fires on "code" alone.
2. **A protocol-level clause.** Add a "no screenshots" clause to `PTD-ready-and-marks` for the
  `E-puzzle` PS1.1 row when the deliverable is the load path only. That would let this run accept from
  the headless evidence (GUT seam, O8/O3 probe, independent audit) alone.
3. **Parse the gate differently.** Read "playable behavior (game or code)" as "code that changes what a
  player can do", so #105 does not fire the gate at all. This needs a sentence in `playtest.md`, not an
  agent decision: `procedures.md` "Prep" also assumes a runnable build with `DBG.*`/`TEL.*`.
4. **Workflow edge.** Give `pending-acceptance` a real waiting/blocked state so a structurally
  un-acceptable leaf leaves the dispatch filter until #110/#111 lands (option 2 of the #106/#107 deadlock note).

Until one of these lands, this agent re-picks #105 on every dispatch and re-records this gap.

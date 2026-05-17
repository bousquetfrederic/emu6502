# Phase 3 — Real keyboard

Goal: replace the Port B bit-3 "no key" stub with a working Atmos
keyboard, so the user can type at the BASIC prompt.

## Why this is bigger than a stub

The Atmos keyboard is an 8×8 matrix the ROM scans *indirectly*:

1. **Row select** — ROM writes bits 0–2 of VIA Port B (selects 1 of 8
   rows).
2. **Column mask** — ROM writes a column byte to **AY-3-8912 register
   14** (the AY's I/O port A). The AY is not memory-mapped; it is driven
   *through* the VIA: Port A is the AY data bus, and the AY's BDIR/BC1
   control lines come from VIA CA2/CB2 (configured via the PCR).
3. **Sense read** — ROM reads **VIA Port B bit 3**, active-high
   (1 = a key in the selected row ∩ column is down).

So adding a keyboard requires a minimal AY and the VIA CA2/CB2
handshake, because the column mask only reaches the matrix through the
AY. Today bit 3 is hard-forced to 0 at
`connectables-versatile_interface_adapter.adb:116` (`and 16#F7#`).

## Build order

1. **`Keyboard` package** — owns the 8×8 `Key_Down (Row, Col)` matrix
   plus a Win32 virtual-key → (row, col) map. Self-contained, unit-
   testable without any wiring. Keeps the Oric matrix layout out of
   `Screen`, matching the existing decoupled-presenter architecture.

2. **Minimal AY-3-8912 model** — address latch + register 14 write
   only. No sound generation (that is Phase 4). Reachable from the VIA.

3. **VIA CA2/CB2 ↔ AY BDIR/BC1** — the VIA currently routes PCR writes
   through the `when others` catch-all
   (`connectables-versatile_interface_adapter.adb:184`) and ignores
   CA2/CB2 entirely. Decode the PCR manual-output modes → BDIR/BC1 →
   AY latch-address vs data-write. **Riskiest step.** Verify with a
   `log_bus` trace that the ROM's column byte actually lands in AY
   register 14.

4. **Real sense computation** — replace the bit-3 stub: row = Port B
   bits 0–2, column = AY register 14, sense = OR of matched matrix
   cells, mixed back into Port B bit 3.

5. **Win32 key capture** — handle `WM_KEYDOWN` / `WM_KEYUP` in
   `Wnd_Proc` (`screen.adb:184`), forwarding raw VK events to the
   `Keyboard` object. Needs a new `Screen` → emulation seam; today
   `Screen` has zero Oric awareness.

6. **Wire it in `emulation.adb`** — give the VIA references to the AY
   model and the `Keyboard` matrix.

## Must verify against Oricutron (not secondary docs)

CLAUDE.md is explicit that Oric internals defy documentation; confirm
each of these from Oricutron source or empirical capture before
committing the corresponding step:

- Exact PCR bit patterns the Atmos ROM uses for CA2/CB2, and which
  line is BDIR vs BC1.
- Column-mask polarity (active-low vs active-high) and whether the ROM
  ever *reads* the AY (BC1 read mode) or only writes the column latch.
- Modifier-key positions (CTRL / SHIFT / FUNCT) in the matrix.

## Definition of done

Typing at the BASIC prompt in the running window produces the correct
characters, including shifted symbols and at least CTRL/FUNCT. Per the
workflow rule, verify the running result with the user before
committing each hardware-behavior step.

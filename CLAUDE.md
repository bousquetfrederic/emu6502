# emu6502 / Oric emulator

A MOS 6502 emulator written in Ada, being grown into an **Oric‑1 / Atmos**
home‑computer emulator. The CPU core is complete and validated against the
SingleStepTests 65x02 suite; the machine layer (VIA, ULA video, window) is
under construction.

## Build & run

Toolchain: **Alire** (`alr`, 2.1.x) with the bundled GNAT mingw‑w64 compiler.
No external libraries — the display uses Win32 (`user32`/`gdi32`) via
`pragma Linker_Options`, which the mingw linker resolves with nothing to
install.

```
alr build                       # build to bin/emu6502
alr run -- binary <rom>         # run a 16 KB raw Oric ROM image (mapped at $C000)
alr run -- text   <rom>         # load a hex-text ROM
alr run -- json   <files...>    # run the 6502 JSON test suite (results.txt)
```

Optional trailing args on `binary`/`text`: `log_cpu`, `log_bus`, `log_video`
(write traces to `debug.txt`). A real Oric needs the genuine Atmos BASIC ROM;
it carries its own reset/IRQ/NMI vectors and the character set in‑image.

The window: a 720×672 Win32 window (240×224 native, ×3). Closing it exits.

## Architecture

The machine is a **bus + connectable devices** model:

- `Data_Bus` — owns up to 16 `Connectables.T_Connectable'Class` devices, each
  self‑describing its address space; routes `Read_Byte`/`Write_Byte`;
  dispatches `Tick` to every device once per CPU clock cycle.
- `Connectables.T_Connectable` — abstract device. `Tick` is a **dispatching
  primitive** (default no‑op) so devices like the VIA advance their timers
  every cycle via `Data_Bus.Tick`.
  - `Connectables.Memory` — RAM/ROM, optional write‑protect, file loaders.
  - `Connectables.Versatile_Interface_Adapter` — 6522 VIA.
  - `Connectables.Video` — **legacy/unused**, kept only so `emu6502.adb`'s
    `log_video` flag still compiles. The screen is plain RAM now (see below).
- `Cpu` — cycle‑stepped FSM. `Cpu.Tick` decrements the current
  instruction's cycle count and executes on 0; opcode→instruction table in
  `cpu-instruction_from_op_code.adb`; operations split across
  `cpu-operations`, `cpu-arithmetic`, `cpu-data_access`, etc.
  `Cpu.Interrupt` latches an IRQ/NMI request serviced at the next
  instruction boundary. `Cpu.Debug` exposes register get/set + single step.
- `Ticker` — timing. The 6502 runs 1 MHz, the Oric refreshes at 50 Hz, so
  one frame = `Cycles_Per_Frame` = 20000 cycles. The emulation runs a whole
  frame flat‑out then `End_Of_Frame` sleeps to the 20 ms boundary. (Do **not**
  reintroduce per‑cycle real‑time delay — no OS scheduler does 1 MHz.)
- `Oric_Display` — software **ULA** for TEXT mode (40×28). Reads screen RAM
  and the character generator out of plain RAM via the bus once per frame,
  producing a colour‑index `Framebuffer`. Decoupled from any presenter; also
  has `Write_PPM` (a headless test oracle).
- `Screen` — thin **Win32/GDI** presenter (same spec a future SDL presenter
  could implement). Pure Ada Win32 bindings: `CreateWindowExA`, a `Stdcall`
  `WndProc`, `PeekMessage` pump, `StretchDIBits` of a top‑down 32‑bpp DIB.
- `Emulation.Run_Rom` — wires the memory map, loads the ROM, then runs the
  frame loop: cycles → `Data_Bus.Tick` → VIA‑driven IRQ → render → present.
- `Emu6502` — entry point / CLI parsing.

### Oric memory map (`emulation.adb`)

| Range            | Device                                            |
|------------------|---------------------------------------------------|
| `$0000–$02FF`    | low RAM (zero page + stack)                       |
| `$0300–$030F`    | 6522 VIA                                           |
| `$0310–$03FF`    | page‑3 RAM                                         |
| `$0400–$BFFF`    | one plain RAM block                                |
| └ `$B400/$B800`  | character set (std / alternate), inside that RAM   |
| └ `$BB80–$BFDF`  | 40×28 text screen, inside that RAM                 |
| `$C000–$FFFF`    | ROM (carries its own `$FFFA–$FFFF` vectors)       |

The ULA *scans* RAM; the screen is **not** a special device.

## Hardware facts established (verified against Oricutron source — trust it over secondary docs)

- **VIA register map** is standard 6522: `$..D = IFR`, `$..E = IER`,
  `$..2 = DDRB`, `$..3 = DDRA`. (An earlier version had IFR/IER and the DDRs
  swapped — that breaks the ROM's interrupt handling.)
- **VIA Timer 1** free‑run drives the maskable IRQ; the ROM programs the
  latch (~10000 → ~100 Hz on Atmos). Reading `T1C‑L` acknowledges the T1
  interrupt. IRQ asserted while `(IFR and IER and 16#7F#) /= 0`.
- **Keyboard sense = VIA Port B bit 3**, active‑high (1 = key down). Not yet
  emulated; `Read_Byte` for `PORT_B` masks `and 16#F7#` so the ROM always
  sees "no key" (otherwise ROW/AY bits the ROM writes read back as a phantom
  held key). This stub is replaced by the real matrix in Phase 3.
- **ULA TEXT decoding** (`Oric_Display`):
  - A byte is a serial attribute iff `(b and 16#60#) = 0` (bits 5,6 clear).
  - Attribute decode: `attr = b and 16#7F#`; `attr and 16#18#` selects
    `0`=ink, `1`=text‑attrs (bit2 = blink), `2`=paper, `3`=video mode;
    value = `attr and 7`.
  - **Bit 7 inverts the cell** — for *both* character and attribute cells.
    Oric "inverse" is colour **complement (XOR 7)**, NOT an ink/paper swap
    (they coincide only for white‑on‑black, which once hid a bug).
  - An attribute cell is still **drawn**: a solid block of the (updated)
    background colour, complemented if bit 7.
  - The **cursor** is a serial‑attribute byte whose bit 7 the ROM toggles
    (~2 Hz via the T1 IRQ) at the cursor cell — so correct attribute‑cell +
    bit‑7 rendering is what makes it appear.
  - Palette: 3‑bit RGB, 0=black 1=red 2=green 3=yellow 4=blue 5=magenta
    6=cyan 7=white. Per‑line reset: ink=7, paper=0.

## Conventions & gotchas

- **`Data_Types` custom operators.** It defines `"+"`/`"-"` for
  `(T_Address, T_Byte)` etc. A `use type Data_Types.T_Address;` (or
  `T_Byte`) makes these visible and then collides with predefined integer
  `-`/`+` ("ambiguous expression"). In new code do arithmetic in plain
  `Integer` and convert (`Data_Types.T_Address (expr)`) only at the bus
  boundary — see `Oric_Display`. Or qualify literals (`T_Address'(1)`).
- **VIA read side effects.** The `Connectables` interface makes `Read_Byte`
  an `in`‑mode function, but the 6522 mutates on read (T1C‑L ack). So the
  VIA's mutable timer/flag state lives behind an access (`T_VIA_State_Ptr`)
  reachable through the `in` parameter.
- **Win32 bindings.** Win32 names clash with Ada case‑insensitivity
  (param `LParam` vs subtype `LPARAM` is the *same* identifier). Subtypes
  are `W_Param`/`L_Param`/`L_Result`. `System.Address` comparison needs
  `use type System.Address;`.
- **Workflow.** Commit on `master` (the user works there in VS Code).
  One focused commit per change; messages explain the *why*; co‑author
  trailer. For hardware behaviour, **verify the running result with the
  user before committing** — Oric internals have repeatedly defied
  secondary documentation; the reliable sources are Oricutron source and
  empirical capture.
- **Debugging video/timing.** Sampling RAM once per second *aliases* the
  2–5 Hz cursor blink into looking frozen. Use an alias‑free per‑frame
  screen‑RAM diff and capture the exact toggling cell/value.

## Current state & known approximations

Boots the Atmos ROM to a stable BASIC screen with a blinking cursor in a
real window. Keyboard is a "no key" stub (can't type yet). Approximations
to revisit: T1 period ~N+1 vs hardware N+2; IRQ re‑asserted every cycle
while pending (level‑trigger approximation); simplified double‑height glyph
mapping; video‑mode codes 24–31 consumed but ignored (HIRES is Phase 4).

## Roadmap

- **Phase 1 — DONE.** VIA Timer‑1 free‑run + IFR/IER IRQ; real‑ROM vectors
  (synthetic vectors/hack removed); frame‑paced `Ticker`.
- **Phase 2 — DONE.** `$0400–$BFFF` plain RAM; `Oric_Display` ULA TEXT
  renderer; Win32 window; correct inverse/attribute/cursor rendering.
- **Phase 3 — NEXT: real keyboard.** VIA Port B bits 0–2 row select +
  AY‑3‑8912 register 14 column mask (driven through the VIA BDIR/BC1) +
  8×8 matrix; feed Win32 key events into it; replace the bit‑3 stub.
- **Phase 4 — later.** HIRES (240×200 @ `$A000`); AY‑3‑8912 sound; `.tap`
  cassette; Oric‑1 vs Atmos ROM selection; save states. A cross‑platform
  SDL presenter behind the existing `Screen` seam is an option (the old
  SDLAda implementation is in git history at commit `b2c1479`).

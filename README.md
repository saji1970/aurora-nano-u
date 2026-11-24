# Aurora-Nano-U

A teaching-scale tapeout of the Aurora-Nano language-model accelerator for
**IHP SG13G2 (130 nm)**, the open process IHP fabricates for universities.
It runs the core operation of a small language model, a matrix-vector
multiply y = W·x with INT8 or INT4 weights, on a 2.0 × 2.0 mm die.

Design documents: [Aurora-1 GPU architecture](docs/aurora-1-architecture.md) (the full design this
comes from) and [Aurora-Nano for glasses](docs/aurora-nano-glasses.md) (the 2 × 2 mm language-model
chip this package scales down). The [glasses main board](docs/glasses-board.md) shows the
Android SoC, memory, displays, 5G and power around it, and the
[packaging plan](docs/glasses-packaging.md) shows how it fits in the frame. The [cost and sourcing estimate](docs/glasses-cost-and-sourcing.md)
covers development cost, unit cost, suppliers and manufacturers.

## What the chip does

A host (microcontroller or FPGA) loads weights and an activation vector over
SPI, starts the engine, and reads the results back.

| Item | Value |
| --- | --- |
| Process | IHP SG13G2, 130 nm, 1.2 V core, 3.3 V I/O |
| Die | 2.0 × 2.0 mm, 16 pads (8 signal, 8 power) |
| Clock | 50 MHz target |
| Engine | 8 multiply-accumulates per clock, 3-stage pipeline |
| Weights | 1 KB on chip: 1,024 INT8 or 2,048 INT4 weights |
| One run | up to 32 rows × 64 columns, 32-bit accumulators |
| Post-processing | rounding right shift, optional ReLU, saturation to INT8 |
| Host interface | SPI mode 0, system clock at least 8 × SPI clock |
| Logic area | 0.95 mm² of standard cells (about 38,700 cells) |

Memory map and SPI commands are documented at the top of
`rtl/aurora_nano_u.v`.

## Status

| Step | Status |
| --- | --- |
| RTL | done |
| RTL simulation vs Python golden model | pass: 20 tests, 690 results, 2 seeds |
| Bug-detection check (a ReLU bug planted on purpose) | caught: 48 errors |
| Full-chip simulation through IHP pad models | pass |
| Synthesis to IHP SG13G2 cells (Yosys) | done, 0.95 mm² |
| Gate-level simulation of the synthesized netlist | pass: 3 configurations, 80 results (1 × 8 INT8, 32 × 32 INT8, 7 × 24 INT4 with ReLU) |
| Logic timing estimate, slow corner (1.08 V, 125 °C) | 7.3 ns worst path, no wires, vs 20 ns clock |
| Place and route, GDSII | **to run**: config in `flow/` (not run yet) |
| Seal ring, DRC, LVS, metal fill | **to run** with IHP's KLayout decks |

Place and route could not be run where this package was built; the flow
configuration follows OpenROAD-flow-scripts' own IHP pad-ring example
(`ihp-sg13g2/i2c-gpio-expander`), but expect to iterate on it.

## Files

| Path | Contents |
| --- | --- |
| `rtl/an_spi_slave.v` | SPI slave, oversampled in the system clock domain |
| `rtl/an_mv_engine.v` | matrix-vector engine |
| `rtl/aurora_nano_u.v` | core: memories, registers, command decoder |
| `rtl/aurora_nano_u_chip.v` | chip top: core + IHP I/O pad ring |
| `tb/gen_vectors.py` | golden model and test vectors |
| `tb/tb_aurora_nano_u.v`, `tb/tb_chip.v` | testbenches (core, whole chip) |
| `syn/synth.ys`, `syn/timing.ys` | Yosys synthesis and timing-estimate scripts |
| `syn/aurora_nano_u_netlist.v` | synthesized gate-level netlist |
| `scripts/lib2models.py` | functional cell models for gate-level simulation |
| `scripts/glasses_board_diagram.py` | draws the glasses main-board block diagram |
| `scripts/glasses_packaging_diagram.py` | draws the glasses packaging plan |
| `flow/aurora_nano_u/` | OpenROAD-flow-scripts config: `config.mk`, SDC, power grid |
| `results/` | logs from the runs above |
| `docs/` | design documents and block diagrams |

## Reproduce the checks

```
git clone https://github.com/IHP-GmbH/IHP-Open-PDK ~/IHP-Open-PDK
make sim sim_chip synth gl IHP_PDK=~/IHP-Open-PDK
```

Needs `iverilog`, `yosys` and `python3`.

## Steps to tapeout

1. **Place and route.** Install OpenROAD-flow-scripts (its Docker image is the
   easiest route). Copy `flow/aurora_nano_u/` to
   `flow/designs/ihp-sg13g2/aurora_nano_u/` and `rtl/` into that folder, then from
   `flow/` run `make DESIGN_CONFIG=./designs/ihp-sg13g2/aurora_nano_u/config.mk`.
   Check `reports/` for setup and hold timing at the slow and fast corners.
2. **Seal ring.** Generate a 2000 × 2000 µm seal ring with the SG13G2 sealring
   PCell in KLayout, set `SEAL_GDS` in `config.mk`, and rerun the final step.
3. **Fill, DRC and LVS.** Run IHP's KLayout DRC deck (in the PDK under
   `ihp-sg13g2/libs.tech/klayout`) and LVS against the final netlist. Fix any
   violations in the flow, not by hand.
4. **Post-layout check.** Simulate the routed netlist with extracted delays
   (SDF) using the testbenches here.
5. **Submit.** Follow the submission rules of the shuttle you join: IHP's
   research and university MPW runs, or a programme your university uses.
   Confirm the allowed die size, pad and bond-pad rules and deadline first.

## Sizing it differently

The core is parameterised: `WAW` (weight words), `KW` (column chunks) and `RW`
(rows). Smaller values shrink the memories, which are most of the area. The
testbench assumes the default sizes.

## Bring-up on the bench

1. Power 1.2 V core and 3.3 V I/O, hold `rst_n` low, start a 50 MHz clock.
2. Release reset and read address `0x0F0F` over SPI: it must return `0xA5`.
3. Load weights, activations and registers, write `START`, wait for `irq_done`,
   read results. Compare against `tb/gen_vectors.py`.

## Licence

Apache-2.0 for the files in this package.

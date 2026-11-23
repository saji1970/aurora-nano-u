# Aurora-Nano-U: simulation and synthesis with open-source tools.
# Needs: iverilog, yosys, python3. IHP_PDK must point at a checkout of
# https://github.com/IHP-GmbH/IHP-Open-PDK (for the cell and pad libraries).

IHP_PDK ?= $(HOME)/IHP-Open-PDK
STDCELL  = $(IHP_PDK)/ihp-sg13g2/libs.ref/sg13g2_stdcell
IOCELL   = $(IHP_PDK)/ihp-sg13g2/libs.ref/sg13g2_io
RTL      = rtl/an_spi_slave.v rtl/an_mv_engine.v rtl/aurora_nano_u.v
SEED    ?= 1

.PHONY: all sim sim_chip synth gl clean

all: sim sim_chip synth gl

tb/tests.hex: tb/gen_vectors.py
	cd tb && python3 gen_vectors.py $(SEED)

# RTL simulation of the core against the Python golden model
sim: tb/tests.hex
	iverilog -g2005 -o tb/sim tb/tb_aurora_nano_u.v $(RTL)
	cd tb && vvp -n sim | tail -3

# whole chip, through IHP's I/O pad models
sim_chip: tb/tests.hex
	iverilog -g2005 -o tb/sim_chip tb/tb_chip.v $(RTL) rtl/aurora_nano_u_chip.v $(IOCELL)/verilog/sg13g2_io.v
	cd tb && vvp -n sim_chip | tail -3

# synthesis to IHP SG13G2 standard cells (area report in syn/synth.log)
synth:
	cp $(STDCELL)/lib/sg13g2_stdcell_typ_1p20V_25C.lib $(STDCELL)/lib/sg13g2_stdcell_slow_1p08V_125C.lib syn/
	cd syn && yosys -q -l synth.log synth.ys
	grep -E "Chip area|Number of cells" syn/synth.log | tail -2
	cd syn && yosys -q -l timing.log timing.ys
	grep "Delay =" syn/timing.log | tail -1

# gate-level simulation of the synthesized netlist (functional cell models
# generated from the liberty file). Slow: about 6 minutes per test, so pick a
# few tests, e.g. edit tests.hex or run gen_vectors.py with a max_tests value.
gl: synth tb/tests.hex
	python3 scripts/lib2models.py syn/sg13g2_stdcell_typ_1p20V_25C.lib syn/aurora_nano_u_netlist.v tb/sg13g2_cells_functional.v
	iverilog -g2005 -o tb/sim_gl tb/tb_aurora_nano_u.v syn/aurora_nano_u_netlist.v tb/sg13g2_cells_functional.v
	cd tb && vvp -n sim_gl | tail -3

clean:
	rm -f tb/sim tb/sim_chip tb/sim_gl tb/tests.hex tb/sg13g2_cells_functional.v syn/*.lib

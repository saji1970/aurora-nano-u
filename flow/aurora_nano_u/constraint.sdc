# Aurora-Nano-U timing constraints: 50 MHz core clock from the clk pad.
current_design aurora_nano_u_chip
set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_fanout 8 [current_design]
set_max_capacitance 0.5 [current_design]
set_max_transition 3 [current_design]
set_max_area 0
set clk_period 20.0

set_ideal_network [get_pins sg13g2_IOPad_clk/p2c]
create_clock [get_pins sg13g2_IOPad_clk/p2c] -name clk_core -period $clk_period \
  -waveform [list 0 [expr { $clk_period / 2.0 }]]
set clk_io_name vclk_core
create_clock -name $clk_io_name -period $clk_period
set_clock_latency 0.480 [get_clocks clk_core]
set_clock_latency 0.480 [get_clocks $clk_io_name]
set_clock_uncertainty 0.25 [get_clocks clk_core]
set_clock_transition 0.25 [get_clocks clk_core]

set_driving_cell -lib_cell sg13g2_IOPadIn -pin pad [get_ports clk_PAD]

# SPI and reset are asynchronous to clk and are synchronised inside the core
# (2-3 flip-flop synchronisers), so their pad-to-core paths are not timed.
set async_inputs [get_ports {rst_n_PAD spi_sck_PAD spi_cs_n_PAD spi_mosi_PAD}]
set_driving_cell -lib_cell sg13g2_IOPadIn -pin pad $async_inputs
set_input_delay 5.0 -clock $clk_io_name $async_inputs
set_false_path -from $async_inputs

set outputs [get_ports {spi_miso_PAD irq_done_PAD busy_PAD}]
set_driving_cell -lib_cell sg13g2_IOPadOut4mA -pin pad $outputs
set_output_delay 5.0 -clock $clk_io_name $outputs

set_load -pin_load 5 [all_inputs]
set_load -pin_load 5 [all_outputs]

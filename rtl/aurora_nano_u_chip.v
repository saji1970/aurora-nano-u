// Aurora-Nano-U chip top: the core plus the IHP SG13G2 I/O pad ring.
// 2.0 x 2.0 mm die, 16 pads (8 signal, 8 power), 4 per side.
// Core supply 1.2 V (VDD/VSS), pad supply 3.3 V (IOVDD/IOVSS).
`default_nettype none

module aurora_nano_u_chip (
    inout wire clk_PAD,
    inout wire rst_n_PAD,
    inout wire spi_sck_PAD,
    inout wire spi_cs_n_PAD,
    inout wire spi_mosi_PAD,
    inout wire spi_miso_PAD,
    inout wire irq_done_PAD,
    inout wire busy_PAD
);
    wire clk, rst_n, spi_sck, spi_cs_n, spi_mosi;
    wire spi_miso, irq_done, busy;

    // ---------------- input pads ----------------
    sg13g2_IOPadIn sg13g2_IOPad_clk      (.pad(clk_PAD),      .p2c(clk));
    sg13g2_IOPadIn sg13g2_IOPad_rst_n    (.pad(rst_n_PAD),    .p2c(rst_n));
    sg13g2_IOPadIn sg13g2_IOPad_spi_sck  (.pad(spi_sck_PAD),  .p2c(spi_sck));
    sg13g2_IOPadIn sg13g2_IOPad_spi_cs_n (.pad(spi_cs_n_PAD), .p2c(spi_cs_n));
    sg13g2_IOPadIn sg13g2_IOPad_spi_mosi (.pad(spi_mosi_PAD), .p2c(spi_mosi));

    // ---------------- output pads ----------------
    sg13g2_IOPadOut4mA sg13g2_IOPad_spi_miso (.pad(spi_miso_PAD), .c2p(spi_miso));
    sg13g2_IOPadOut4mA sg13g2_IOPad_irq_done (.pad(irq_done_PAD), .c2p(irq_done));
    sg13g2_IOPadOut4mA sg13g2_IOPad_busy     (.pad(busy_PAD),     .c2p(busy));

    // ---------------- power pads (two of each, one pair per side) ----------------
    (* keep *) sg13g2_IOPadVdd   sg13g2_IOPadVdd_0   ();
    (* keep *) sg13g2_IOPadVdd   sg13g2_IOPadVdd_1   ();
    (* keep *) sg13g2_IOPadVss   sg13g2_IOPadVss_0   ();
    (* keep *) sg13g2_IOPadVss   sg13g2_IOPadVss_1   ();
    (* keep *) sg13g2_IOPadIOVdd sg13g2_IOPadIOVdd_0 ();
    (* keep *) sg13g2_IOPadIOVdd sg13g2_IOPadIOVdd_1 ();
    (* keep *) sg13g2_IOPadIOVss sg13g2_IOPadIOVss_0 ();
    (* keep *) sg13g2_IOPadIOVss sg13g2_IOPadIOVss_1 ();

    // ---------------- core ----------------
    aurora_nano_u u_core (
        .clk(clk), .rst_n(rst_n),
        .spi_sck(spi_sck), .spi_cs_n(spi_cs_n), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
        .irq_done(irq_done), .busy(busy)
    );
endmodule

`default_nettype wire

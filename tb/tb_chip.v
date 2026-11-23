// Chip-level testbench (through the IHP pad models). Drives Aurora-Nano-U over SPI exactly as a host would and
// checks every result against the Python golden model (tests.hex).
`timescale 1ns/1ps
`default_nettype none

module tb;
    reg clk = 0, rst_n = 0;
    reg sck = 0, cs_n = 1, mosi = 0;
    wire miso, irq_done, busy;

    always #5 clk = ~clk;              // 100 MHz system clock
    localparam HALF = 50;              // SPI half period: 10 MHz SPI clock

    wire p_clk = clk, p_rst_n = rst_n, p_sck = sck, p_cs_n = cs_n, p_mosi = mosi;
    aurora_nano_u_chip dut (
        .clk_PAD(p_clk), .rst_n_PAD(p_rst_n),
        .spi_sck_PAD(p_sck), .spi_cs_n_PAD(p_cs_n), .spi_mosi_PAD(p_mosi), .spi_miso_PAD(miso),
        .irq_done_PAD(irq_done), .busy_PAD(busy)
    );

    // ---------------- SPI master (mode 0) ----------------
    reg [7:0] rx;
    task spi_byte(input [7:0] tx);
        integer b;
        begin
            for (b = 7; b >= 0; b = b - 1) begin
                mosi = tx[b];
                #HALF sck = 1; rx = {rx[6:0], miso};
                #HALF sck = 0;
            end
        end
    endtask

    task cs_begin; begin cs_n = 0; #HALF; end endtask
    task cs_end;   begin #HALF cs_n = 1; #(4*HALF); end endtask

    task wr8(input [15:0] a, input [7:0] d);
        begin cs_begin; spi_byte(8'h02); spi_byte(a[15:8]); spi_byte(a[7:0]); spi_byte(d); cs_end; end
    endtask

    task rd8(input [15:0] a, output [7:0] d);
        begin cs_begin; spi_byte(8'h0B); spi_byte(a[15:8]); spi_byte(a[7:0]); spi_byte(8'h00);
              spi_byte(8'h00); d = rx; cs_end; end
    endtask

    // ---------------- vectors ----------------
    reg [31:0] vec [0:200000];
    integer p, t, ntests, i, errors, checked;
    reg [31:0] pi4, prl, prows, pch, psh, pwb;
    reg [7:0]  d, st;
    reg [31:0] acc;

    initial begin
        $readmemh("tests.hex", vec);
        errors = 0; checked = 0;
        #100 rst_n = 1;
        #200;

        rd8(16'h0F0F, d);
        if (d !== 8'hA5) begin $display("FAIL: ID read %h, expected a5", d); errors = errors + 1; end
        else $display("ID register reads a5");

        ntests = vec[0]; p = 1;
        for (t = 0; t < ntests; t = t + 1) begin
            pi4 = vec[p]; prl = vec[p+1]; prows = vec[p+2]; pch = vec[p+3]; psh = vec[p+4]; pwb = vec[p+5];
            p = p + 6;

            // weights: one burst write of 1024 bytes
            cs_begin; spi_byte(8'h02); spi_byte(8'h00); spi_byte(8'h00);
            for (i = 0; i < 1024; i = i + 1) spi_byte(vec[p+i][7:0]);
            cs_end; p = p + 1024;
            // activations: one burst of 64 bytes
            cs_begin; spi_byte(8'h02); spi_byte(8'h08); spi_byte(8'h00);
            for (i = 0; i < 64; i = i + 1) spi_byte(vec[p+i][7:0]);
            cs_end; p = p + 64;

            // spot-check a weight byte read-back
            rd8(16'h0123, d);
            if (d !== vec[p - 64 - 1024 + 16'h0123][7:0]) begin
                $display("FAIL test %0d: weight read-back %h", t, d); errors = errors + 1;
            end

            // configuration burst at 0x0F01: ROWS, CHUNKS, SHIFT, (STATUS skipped), WBASE
            cs_begin; spi_byte(8'h02); spi_byte(8'h0F); spi_byte(8'h01);
            spi_byte(prows[7:0]); spi_byte(pch[7:0]); spi_byte(psh[7:0]); spi_byte(8'h00); spi_byte(pwb[7:0]);
            cs_end;
            wr8(16'h0F00, {5'd0, prl[0], pi4[0], 1'b1});    // START

            // wait for DONE
            st = 0;
            while (!st[1]) rd8(16'h0F04, st);
            if (!irq_done) begin $display("FAIL test %0d: irq_done low after DONE", t); errors = errors + 1; end

            // INT8 results: one burst read
            cs_begin; spi_byte(8'h0B); spi_byte(8'h0C); spi_byte(8'h00); spi_byte(8'h00);
            for (i = 0; i < 32; i = i + 1) begin
                spi_byte(8'h00);
                if (i < prows) begin
                    checked = checked + 1;
                    if (rx !== vec[p+i][7:0]) begin
                        $display("FAIL test %0d row %0d: q=%h expected %h", t, i, rx, vec[p+i][7:0]);
                        errors = errors + 1;
                    end
                end
            end
            cs_end; p = p + 32;

            // INT32 accumulators: one burst read, little endian
            cs_begin; spi_byte(8'h0B); spi_byte(8'h0D); spi_byte(8'h00); spi_byte(8'h00);
            for (i = 0; i < 32; i = i + 1) begin
                spi_byte(8'h00); acc[7:0]   = rx;
                spi_byte(8'h00); acc[15:8]  = rx;
                spi_byte(8'h00); acc[23:16] = rx;
                spi_byte(8'h00); acc[31:24] = rx;
                if (i < prows) begin
                    checked = checked + 1;
                    if (acc !== vec[p+i]) begin
                        $display("FAIL test %0d row %0d: acc=%h expected %h", t, i, acc, vec[p+i]);
                        errors = errors + 1;
                    end
                end
            end
            cs_end; p = p + 32;

            $display("test %0d: int4=%0d relu=%0d rows=%0d cols=%0d shift=%0d wbase=%0d done",
                     t, pi4, prl, prows, 8*pch, psh, pwb);
        end

        if (errors == 0) $display("PASS: %0d tests, %0d results checked, 0 errors", ntests, checked);
        else             $display("FAIL: %0d errors in %0d results", errors, checked);
        $finish;
    end

    initial begin
        #2000000000;
        $display("FAIL: timeout");
        $finish;
    end
endmodule

`default_nettype wire

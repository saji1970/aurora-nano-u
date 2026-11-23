// Aurora-Nano-U: teaching-scale version of the Aurora-Nano language-model
// accelerator, for a university MPW run on IHP SG13G2 (130 nm).
//
// A host (microcontroller or FPGA) loads INT8 or INT4 weights and an INT8
// activation vector over SPI, starts the engine, and reads back the INT8
// results (or the raw 32-bit accumulators). One run computes y = W x for
// up to 32 rows and 64 columns.
//
// SPI commands (mode 0, MSB first, system clock >= 8x SPI clock):
//   0x02 ADDR_H ADDR_L DATA...         write, address auto-increments
//   0x0B ADDR_H ADDR_L DUMMY DATA...   read,  address auto-increments
//
// Memory map (byte addresses):
//   0x0000 - 0x03FF  weights, 1 KB (1024 INT8 or 2048 INT4 weights)
//   0x0800 - 0x083F  activation vector x, 64 x INT8
//   0x0C00 - 0x0C1F  results, 32 x INT8 (after shift / ReLU / saturate)
//   0x0D00 - 0x0D7F  results, 32 x INT32 accumulators, little endian
//   0x0F00 CTRL    bit0 START (write 1), bit1 INT4 weights, bit2 ReLU
//   0x0F01 ROWS    1..32
//   0x0F02 CHUNKS  columns / 8, 1..8
//   0x0F03 SHIFT   rounding right shift, 0..31
//   0x0F04 STATUS  bit0 BUSY, bit1 DONE (read only)
//   0x0F05 WBASE   first weight word (8-byte words), 0..127
//   0x0F0F ID      0xA5 (read only)
`default_nettype none

module aurora_nano_u #(
    parameter WAW = 7,    // weight words = 2^WAW (64-bit each)
    parameter KW  = 3,    // max column chunks = 2^KW (8 columns each)
    parameter RW  = 5     // max rows = 2^RW
) (
    input  wire clk,
    input  wire rst_n,
    input  wire spi_sck,
    input  wire spi_cs_n,
    input  wire spi_mosi,
    output wire spi_miso,
    output wire irq_done,
    output wire busy
);
    localparam NW    = (1 << WAW);
    localparam NX    = (8 << KW);       // activation bytes
    localparam NR    = (1 << RW);       // result rows

    // ---------------- storage ----------------
    reg [63:0] wmem [0:NW-1];
    reg [7:0]  xmem [0:NX-1];
    reg [31:0] racc [0:NR-1];
    reg [7:0]  rq   [0:NR-1];

    // control registers
    reg            c_int4, c_relu;
    reg [RW:0]     c_rows;
    reg [KW:0]     c_chunks;
    reg [4:0]      c_shift;
    reg [WAW-1:0]  c_wbase;
    reg            start_pulse;

    // ---------------- SPI ----------------
    wire       rx_valid, selected, cs_start;
    wire [7:0] rx_byte;
    reg  [7:0] tx_next;

    an_spi_slave u_spi (
        .clk(clk), .rst_n(rst_n),
        .spi_sck(spi_sck), .spi_cs_n(spi_cs_n), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
        .rx_valid(rx_valid), .rx_byte(rx_byte), .selected(selected), .cs_start(cs_start),
        .tx_next(tx_next)
    );

    // command decoder
    localparam S_CMD = 3'd0, S_AH = 3'd1, S_AL = 3'd2, S_DUMMY = 3'd3, S_WDATA = 3'd4, S_RDATA = 3'd5, S_IGNORE = 3'd6;
    reg [2:0]  st;
    reg        is_read;
    reg [15:0] addr;

    // ---------------- engine ----------------
    wire [WAW-1:0] e_waddr;
    wire [KW-1:0]  e_xchunk;
    wire           e_busy, e_done, e_res_we;
    wire [RW-1:0]  e_res_row;
    wire [31:0]    e_res_acc;
    wire [7:0]     e_res_q;

    wire [63:0] e_xdata;
    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : gx
            assign e_xdata[8*g +: 8] = xmem[{e_xchunk, g[2:0]}];
        end
    endgenerate

    an_mv_engine #(.WAW(WAW), .KW(KW), .RW(RW)) u_eng (
        .clk(clk), .rst_n(rst_n), .start(start_pulse),
        .int4(c_int4), .relu(c_relu), .rows(c_rows), .chunks(c_chunks),
        .shift(c_shift), .wbase(c_wbase),
        .w_addr(e_waddr), .w_data(wmem[e_waddr]),
        .x_chunk(e_xchunk), .x_data(e_xdata),
        .busy(e_busy), .done(e_done),
        .res_we(e_res_we), .res_row(e_res_row), .res_acc(e_res_acc), .res_q(e_res_q)
    );

    assign busy     = e_busy;
    assign irq_done = e_done;

    // ---------------- address decode ----------------
    wire in_w   = (addr[15:WAW+3] == 0);                          // 0x0000 .. 8*NW-1
    wire in_x   = (addr[15:KW+3] == (16'h0800 >> (KW+3)));        // 0x0800 .. 0x0800+NX-1
    wire in_rq  = (addr[15:8] == 8'h0C) && (addr[7:0] < NR);
    wire in_ra  = (addr[15:8] == 8'h0D) && (addr[7:2] < NR);
    wire in_reg = (addr[15:8] == 8'h0F);

    wire [WAW-1:0] w_word = addr[WAW+2:3];
    wire [2:0]     w_lane = addr[2:0];
    wire [63:0]    w_rd   = wmem[w_word];
    wire [31:0]    ra_rd  = racc[addr[RW+1:2]];

    // read mux (what the host sees)
    reg [7:0] rd_byte;
    always @(*) begin
        rd_byte = 8'h00;
        if (in_w)
            rd_byte = w_rd[8*w_lane +: 8];
        else if (in_x)
            rd_byte = xmem[addr[KW+2:0]];
        else if (in_rq)
            rd_byte = rq[addr[RW-1:0]];
        else if (in_ra)
            rd_byte = ra_rd[8*addr[1:0] +: 8];
        else if (in_reg) begin
            case (addr[7:0])
                8'h00: rd_byte = {5'd0, c_relu, c_int4, 1'b0};
                8'h01: rd_byte = c_rows;
                8'h02: rd_byte = c_chunks;
                8'h03: rd_byte = {3'd0, c_shift};
                8'h04: rd_byte = {6'd0, e_done, e_busy};
                8'h05: rd_byte = c_wbase;
                8'h0F: rd_byte = 8'hA5;
                default: rd_byte = 8'h00;
            endcase
        end
    end

    // ---------------- SPI command handling + host writes ----------------
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= S_CMD; is_read <= 1'b0; addr <= 16'd0; tx_next <= 8'd0;
            c_int4 <= 1'b0; c_relu <= 1'b0; c_rows <= 1; c_chunks <= 1; c_shift <= 5'd0; c_wbase <= 0;
            start_pulse <= 1'b0;
        end else begin
            start_pulse <= 1'b0;
            if (cs_start || !selected) begin
                st <= S_CMD;
            end else if (rx_valid) begin
                case (st)
                    S_CMD: begin
                        if (rx_byte == 8'h02)      begin is_read <= 1'b0; st <= S_AH; end
                        else if (rx_byte == 8'h0B) begin is_read <= 1'b1; st <= S_AH; end
                        else                       st <= S_IGNORE;
                    end
                    S_AH: begin addr[15:8] <= rx_byte; st <= S_AL; end
                    S_AL: begin addr[7:0]  <= rx_byte; st <= is_read ? S_DUMMY : S_WDATA; end
                    S_DUMMY: begin
                        // the read byte for addr is latched now, then the address moves on
                        st <= S_RDATA;
                    end
                    S_WDATA: begin
                        if (in_reg && !e_busy) begin
                            case (addr[7:0])
                                8'h00: begin c_int4 <= rx_byte[1]; c_relu <= rx_byte[2]; start_pulse <= rx_byte[0]; end
                                8'h01: c_rows   <= rx_byte[RW:0];
                                8'h02: c_chunks <= rx_byte[KW:0];
                                8'h03: c_shift  <= rx_byte[4:0];
                                8'h05: c_wbase  <= rx_byte[WAW-1:0];
                                default: ;
                            endcase
                        end
                        addr <= addr + 16'd1;
                    end
                    S_RDATA: addr <= addr + 16'd1;
                    default: ;
                endcase
            end
            // byte to send next: the current address while reading
            if (st == S_DUMMY || st == S_RDATA)
                tx_next <= rd_byte;
        end
    end

    // memory writes from the host (blocked while the engine runs) and results from the engine
    always @(posedge clk) begin
        if (rx_valid && selected && st == S_WDATA && !e_busy) begin
            if (in_w) begin
                for (i = 0; i < 8; i = i + 1)
                    if (w_lane == i) wmem[w_word][8*i +: 8] <= rx_byte;
            end
            if (in_x)
                xmem[addr[KW+2:0]] <= rx_byte;
        end
        if (e_res_we) begin
            racc[e_res_row] <= e_res_acc;
            rq[e_res_row]   <= e_res_q;
        end
    end
endmodule

`default_nettype wire

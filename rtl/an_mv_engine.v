// Aurora-Nano-U: matrix-vector engine.
// y[r] = sum_c W[r][c] * x[c], INT8 activations, INT8 or INT4 weights,
// 32-bit accumulation, then rounding right shift, optional ReLU and
// saturation to INT8. 8 multiply-accumulates per clock, 3-stage pipeline.
//
// Weight layout (word = 64 bits, byte j of a word = bits [8j+7:8j]):
//   INT8: row r, chunk k (columns 8k..8k+7) is word  WBASE + r*K + k,
//         column 8k+j is byte j.
//   INT4: index i = r*K + k lives in word WBASE + i/2, half h = i%2,
//         column 8k+j is the signed nibble at bits [32h+4j+3 : 32h+4j].
`default_nettype none

module an_mv_engine #(
    parameter WAW  = 7,   // weight word address width
    parameter KW   = 3,   // column-chunk counter width (max K = 2^KW)
    parameter RW   = 5    // row counter width (max rows = 2^RW)
) (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,     // one-cycle pulse
    input  wire               int4,
    input  wire               relu,
    input  wire [RW:0]        rows,      // 1 .. 2^RW
    input  wire [KW:0]        chunks,    // 1 .. 2^KW  (columns / 8)
    input  wire [4:0]         shift,
    input  wire [WAW-1:0]     wbase,
    // weight memory read port (combinational data, registered here)
    output wire [WAW-1:0]     w_addr,
    input  wire [63:0]        w_data,
    // activation chunk read port
    output wire [KW-1:0]      x_chunk,
    input  wire [63:0]        x_data,
    // results
    output reg                busy,
    output reg                done,      // level, cleared by start
    output reg                res_we,
    output reg  [RW-1:0]      res_row,
    output reg  [31:0]        res_acc,
    output reg  [7:0]         res_q
);
    // ---------------- issue counters ----------------
    reg            issuing;
    reg [RW-1:0]   r_cnt;
    reg [KW-1:0]   k_cnt;
    reg [WAW:0]    idx;        // r*K + k, one extra bit for INT4 halves

    wire last_k = (k_cnt == chunks[KW:0] - 1'b1);
    wire last_r = (r_cnt == rows[RW:0] - 1'b1);

    assign w_addr  = int4 ? (wbase + idx[WAW:1]) : (wbase + idx[WAW-1:0]);
    assign x_chunk = k_cnt;

    // ---------------- stage A: fetch ----------------
    reg            a_v, a_last, a_half;
    reg [RW-1:0]   a_row;
    reg [63:0]     a_w, a_x;

    // ---------------- stage B: multiply + add tree ----------------
    reg            b_v, b_last;
    reg [RW-1:0]   b_row;
    reg signed [19:0] b_sum;

    // ---------------- stage C: accumulate ----------------
    reg signed [31:0] acc;

    // weight select (combinational from stage A registers)
    function signed [7:0] wsel;
        input [63:0] w;
        input        is4;
        input        half;
        input [2:0]  j;
        reg   [3:0]  nib;
        begin
            if (is4) begin
                nib  = w[(half ? 32 : 0) + 4*j +: 4];
                wsel = {{4{nib[3]}}, nib};
            end else begin
                wsel = w[8*j +: 8];
            end
        end
    endfunction

    integer j;
    reg signed [19:0] tree;
    always @(*) begin
        tree = 20'sd0;
        for (j = 0; j < 8; j = j + 1)
            tree = tree + $signed(wsel(a_w, int4, a_half, j[2:0])) * $signed(a_x[8*j +: 8]);
    end

    // requantise the finished accumulator
    function [7:0] requant;
        input signed [31:0] a;
        input [4:0]         sh;
        input               rl;
        reg signed [32:0]   rounded;
        reg signed [32:0]   shifted;
        begin
            rounded = (sh == 5'd0) ? {a[31], a} : ({a[31], a} + (33'sd1 <<< (sh - 1'b1)));
            shifted = rounded >>> sh;
            if (rl && shifted < 0)
                requant = 8'd0;
            else if (shifted > 33'sd127)
                requant = 8'd127;
            else if (shifted < -33'sd128)
                requant = 8'h80;
            else
                requant = shifted[7:0];
        end
    endfunction

    wire signed [31:0] acc_next = acc + {{12{b_sum[19]}}, b_sum};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            issuing <= 1'b0; busy <= 1'b0; done <= 1'b0;
            r_cnt <= 0; k_cnt <= 0; idx <= 0;
            a_v <= 1'b0; a_last <= 1'b0; a_half <= 1'b0; a_row <= 0; a_w <= 64'd0; a_x <= 64'd0;
            b_v <= 1'b0; b_last <= 1'b0; b_row <= 0; b_sum <= 20'sd0;
            acc <= 32'sd0;
            res_we <= 1'b0; res_row <= 0; res_acc <= 32'd0; res_q <= 8'd0;
        end else begin
            res_we <= 1'b0;

            // start
            if (start && !busy) begin
                issuing <= 1'b1; busy <= 1'b1; done <= 1'b0;
                r_cnt <= 0; k_cnt <= 0; idx <= 0;
                acc <= 32'sd0;
            end

            // issue one chunk per cycle
            a_v <= issuing;
            if (issuing) begin
                a_w    <= w_data;
                a_x    <= x_data;
                a_half <= idx[0];
                a_row  <= r_cnt;
                a_last <= last_k;
                idx    <= idx + 1'b1;
                if (last_k) begin
                    k_cnt <= 0;
                    if (last_r) issuing <= 1'b0;
                    else        r_cnt   <= r_cnt + 1'b1;
                end else begin
                    k_cnt <= k_cnt + 1'b1;
                end
            end

            // stage B
            b_v    <= a_v;
            b_last <= a_last;
            b_row  <= a_row;
            b_sum  <= tree;

            // stage C
            if (b_v) begin
                if (b_last) begin
                    res_we  <= 1'b1;
                    res_row <= b_row;
                    res_acc <= acc_next;
                    res_q   <= requant(acc_next, shift, relu);
                    acc     <= 32'sd0;
                end else begin
                    acc <= acc_next;
                end
            end

            // finished when nothing is left in flight
            if (busy && !issuing && !a_v && !b_v && !(start)) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
endmodule

`default_nettype wire

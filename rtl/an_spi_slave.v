// Aurora-Nano-U: SPI slave, mode 0 (CPOL=0, CPHA=0), MSB first.
// SCK, CS_N and MOSI are oversampled in the system clock domain, so the
// system clock must be at least 8x the SPI clock.
`default_nettype none

module an_spi_slave (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       spi_sck,
    input  wire       spi_cs_n,
    input  wire       spi_mosi,
    output wire       spi_miso,
    // byte interface (system clock domain)
    output reg        rx_valid,   // one-cycle pulse: a full byte arrived
    output reg  [7:0] rx_byte,
    output wire       selected,   // CS_N is low (synchronised)
    output wire       cs_start,   // one-cycle pulse when CS_N falls
    input  wire [7:0] tx_next     // byte to shift out next
);
    reg [2:0] sck_s;
    reg [2:0] cs_s;
    reg [1:0] mosi_s;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sck_s  <= 3'b000;
            cs_s   <= 3'b111;
            mosi_s <= 2'b00;
        end else begin
            sck_s  <= {sck_s[1:0], spi_sck};
            cs_s   <= {cs_s[1:0], spi_cs_n};
            mosi_s <= {mosi_s[0], spi_mosi};
        end
    end

    wire sck_rise = (sck_s[2:1] == 2'b01);
    wire sck_fall = (sck_s[2:1] == 2'b10);
    assign selected = ~cs_s[1];
    assign cs_start = (cs_s[2:1] == 2'b10);

    reg [2:0] bitcnt;
    reg [6:0] rx_shift;
    reg [7:0] tx_shift;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bitcnt   <= 3'd0;
            rx_shift <= 7'd0;
            rx_byte  <= 8'd0;
            rx_valid <= 1'b0;
            tx_shift <= 8'd0;
        end else begin
            rx_valid <= 1'b0;
            if (!selected) begin
                bitcnt   <= 3'd0;
                tx_shift <= 8'd0;
            end else begin
                if (sck_rise) begin
                    if (bitcnt == 3'd7) begin
                        rx_byte  <= {rx_shift, mosi_s[1]};
                        rx_valid <= 1'b1;
                    end else begin
                        rx_shift <= {rx_shift[5:0], mosi_s[1]};
                    end
                    bitcnt <= bitcnt + 3'd1;
                end
                if (sck_fall) begin
                    // bitcnt == 0 means a byte just finished: present the next byte's MSB
                    if (bitcnt == 3'd0)
                        tx_shift <= tx_next;
                    else
                        tx_shift <= {tx_shift[6:0], 1'b0};
                end
            end
        end
    end

    assign spi_miso = tx_shift[7];
endmodule

`default_nettype wire

// Bit Error Rate
// Author: Lev Kurilenko
// Date: 10/12/2017
// Email: levkur@uw.edu

// Description:
// Bit Error Rate test module used in the
// custom Aurora Rx. A scrambler is instantiated
// to generate the expected scrambled data
// once lock is achieved. Lock is achieved by looking
// at the descrambled data and checking if it
// matches the expected output. If this is the case, the we know the lane is
// properly up and bit error rate testing may commence.
// The scrambler is prepared for the next frame and
// the module begins tracking bit errors.

module ber (
    input rst,
    input clk40,
    input blocksync_out,
    input data_valid,
    input gearbox_rdy_rx,
    input [65:0] data66_gb_rx,
    input [63:0] data64_rx_uns,
    
    //output [65:0] data66_rx_scr,
    output reg [63:0] ber_cnt,
    output ber_sync,
    output sync_init
);

localparam ber_char = 64'hB0B5_C0CA_C01A_CAFE;   // From Memory may need to be changed
localparam cb_char = 64'hc0ff_ee00_c0ca_c01a;   // From Memory may need to be changed
localparam sync_char = 2'b01;   // From Memory may need to be changed

// Scrambler Signals
reg valid_frame;

// BER Signals
integer i;
//wire ber_sync;
//wire sync_init;
wire [65:0] data66_rx_scr;
reg [63:0] ber_cnt_next;

always @(posedge clk40) begin
    if (rst) begin
        valid_frame <= 0;
        ber_cnt <= 0;
    end
    else begin
        if (blocksync_out) begin
            ber_cnt <= ber_cnt_next;
        end
        else begin
            ber_cnt <= 0;
        end
        
        if (blocksync_out && (data64_rx_uns == ber_char)) begin
            valid_frame <= 1;
        end
        else if (!blocksync_out || (data64_rx_uns != ber_char)) begin
            valid_frame <= 0;
        end
    end
end

// Compare Bit Errors
always @(*) begin
    ber_cnt_next = ber_cnt;
    
    if (blocksync_out&data_valid&gearbox_rdy_rx&sync_init) begin
        for (i=0;i<=63;i=i+1) begin
            if (data66_gb_rx[i] != data66_rx_scr[i]) begin
                ber_cnt_next = ber_cnt_next + 1;
            end
        end
    end
end

//============================================================================
//                            Module Instantiation
//============================================================================

ber_scrambler ber_scr
(
    .clk(clk40),
    .rst(rst),
    .data_in_rx_uns(data64_rx_uns),
    .data_in(ber_char),
    .data_out(data66_rx_scr),
    .enable(blocksync_out&data_valid&gearbox_rdy_rx),
    .sync_info(sync_char),
    
    // BER Signals
    .blocksync_out(blocksync_out),
    .valid_frame(valid_frame),
    .ber_poly(data66_gb_rx[57:0]), // 58 bit wide input polynomial
    .ber_sync(ber_sync),
    .sync_init(sync_init)
);

endmodule

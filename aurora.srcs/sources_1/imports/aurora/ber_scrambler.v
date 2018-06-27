// Bit Error Rate Scrambler
// Author: Lev Kurilenko
// Date: 10/12/2017
// Email: levkur@uw.edu

// Description:
// Specialized Scrambler for the Rx side Bit Error Rate module

//========================================================================================
//===================        Bit Error Rate SCRAMLBER           ==========================
//========================================================================================

module ber_scrambler #
( 
    parameter TX_DATA_WIDTH = 64
)
(
    input [(TX_DATA_WIDTH-1):0] data_in_rx_uns,
    input [0:(TX_DATA_WIDTH-1)] data_in,
    output [(TX_DATA_WIDTH+1):0] data_out,
    input enable,
    input [1:0] sync_info,
    input clk,
    input rst,
    
    // BER Signals
    input blocksync_out,
    input valid_frame,
    input [57:0] ber_poly, // 58 bit wide input polynomial
    output reg ber_sync,
    output reg sync_init    // Signal used to indicate that the BER module has synced at least once.
    
);
    localparam cb_char = 64'hc0ff_ee00_c0ca_c01a;   // From Memory may need to be changed

    integer i;
    reg [((TX_DATA_WIDTH*2)-7):0] poly;
    //reg [((TX_DATA_WIDTH*2)-7):0] scrambler;
    reg [57:0] scrambler;
    reg [0:(TX_DATA_WIDTH-1)] tempData = {TX_DATA_WIDTH{1'b0}};
    reg xorBit;
    
    always @(scrambler,data_in)
    begin
        poly = scrambler;
        for (i=0;i<=(TX_DATA_WIDTH-1);i=i+1)
        begin
            xorBit = data_in[i] ^ poly[38] ^ poly[57];
            poly = {poly[((TX_DATA_WIDTH*2)-8):0],xorBit};
            tempData[i] = xorBit;
        end
    end

    always @(posedge clk)
    begin
        if (rst) begin
            //scrambler        <= 122'h155_5555_5555_5555_5555_5555_5555_5555;
            scrambler      <= 122'hFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
            ber_sync       <= 1'b0;
            sync_init      <= 1'b0;
        end
        else if (enable) begin
            // If a valid frame has come through, and the Bit-Error-Rate is not
            // synced, change the scrambler value to the Bit-Error-Rate polynomial
            if (valid_frame & (!ber_sync)) begin
                ber_sync <= 1'b1;
                scrambler <= {poly[63:0], ber_poly};
                sync_init <= 1'b1;
            end
            else if (!blocksync_out||!valid_frame) begin
                ber_sync <= 1'b0;
                scrambler <= poly;
            end
            // else if (blocksync_out&&ber_sync&&(data_in_rx_uns == cb_char)) begin
            //     $display("cb_char detected!");
            //     scrambler <= {poly[63:0], ber_poly};
            //     sync_init <= 1'b0;
            // end
            else begin
                // if (ber_sync)
                //     sync_init <= 1'b1;
                
                scrambler <= poly;
            end
        end    
    end
    
    assign data_out = {sync_info, tempData};

endmodule

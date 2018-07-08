// Engineer: Lev Kurilenko
// Email: levkur@uw.edu
// Date: 11/28/2017
// Module: Aurora Rx Top w/ Support for multiple Aurora Lanes

module aurora_8_pair_top (
    input sysclk_in_p,
    input sysclk_in_n,
    input rst_in,
    
    input [num_lanes-1:0] data_in_p,
    input [num_lanes-1:0] data_in_n,
   
    output [num_lanes-1:0] data_out_p,
    output [num_lanes-1:0] data_out_n,
 
    output latch,
    output clk_io,
    output ser_in
    
    //output USER_SMA_CLOCK_P,
    //output USER_SMA_CLOCK_N
);

localparam num_lanes = 8;       // Specify number of desired lanes. Needs further modifications to make this general purpose.
//integer i;

// Resets
wire rst;

// Clocks
wire clk40;
wire clk160;
wire clk640;
wire clk400;
wire mmcm_locked;

// Aurora Rx Core Signals
wire [63:0] data_out[num_lanes];
wire [1:0]  sync_out[num_lanes];
wire [3:0]  blocksync_out;
wire [3:0]  gearbox_rdy_rx;
wire [3:0]  data_valid;

// Aurora Tx Core Signals
wire [num_lanes-1:0] gearbox_rdy;
wire [num_lanes-1:0] data_next;
reg [63:0] data_in[num_lanes];
reg [1:0] sync[num_lanes];


// Aurora Channel Bonding Signals
//wire [63:0] data_out_cb[num_lanes];
//wire [1:0]  sync_out_cb[num_lanes];
//wire data_valid_cb;
//wire channel_bonded;

// Debug/Monitoring Signals
wire        vio_rst;
wire        vio_en;
wire [63:0]  vio_data;
wire [7:0] vio_sync;
wire vio_en_counting;


assign rst = !mmcm_locked;

integer i;

// Data Driver
always @(posedge clk40) begin
    if (rst|vio_rst) begin
        for (i=0; i<num_lanes; i=i+1) begin
        data_in[i] <= 64'h0000_0000_0000_0000;
        sync[i] <= 2'b00;
        end
    end
    else if ((&gearbox_rdy) & (&data_next)) begin
        if (vio_en) begin
            if (vio_en_counting) begin
                for (i=0; i<num_lanes; i=i+1) begin
                    data_in[i] <= data_in[i] + 1;
                    sync[i] <= 2'b01;
                end
            end
            else begin
                for (i=0; i<num_lanes; i=i+1) begin
                    data_in[i] <= vio_data;
                    sync[i] <= 2'b01;
                end
            end
        end    
        else begin
            for (int i=0; i<num_lanes; i=i+1) begin
                data_in[i] <= 64'hC0CA_C01A_CAFE_0000;
                sync[i] <= 2'b01;
            end
        end
    end
end


//==========================
//  Clock Generation MMCM
//==========================

/**
* Depending on what bitrate the lanes are running at, different PLL and OBUFDS instantiations are needed.
* Uncomment pll_slow and clk160_obufds_slow blocks for a bitrate of 320 Mbps.
* Uncomment pll_fast and clk160_obufds_fast blocks for a bitrate of 1.28 Gbps.
**/

//// Frequencies
//// clk640: 640 MHz
//// clk160: 160 MHz
//// clk40:  40  MHz
//// clk400: 400 MHz

//clk_wiz_3 pll_fast(
//   .clk_in1_p(sysclk_in_p),
//   .clk_in1_n(sysclk_in_n),
//   .clk_out1(clk640),
//   .clk_out2(clk160),
//   .clk_out3(clk40),
//   .clk_out4(clk400),
//   .reset(rst_in),
//   .locked(mmcm_locked)
//);

//// Frequencies
//// clk640: 160 MHz
//// clk160: 40 MHz
//// clk40:  10  MHz
//// clk400: 400 MHz
//// 
//// WARNING: If this PLL is instantiated the clocks
//// will run at slower frequencies, despite
//// having names such as clk640, clk160, clk40.
//clk_wiz_0 pll_mid(
//   .clk_in1_p(sysclk_in_p),
//   .clk_in1_n(sysclk_in_n),
//   .clk_out1(clk640),
//   .clk_out2(clk160),
//   .clk_out3(clk40),
//   .clk_out4(clk400),
//   .reset(rst_in),
//   .locked(mmcm_locked)
//);

// Frequencies
// clk640: 320 MHz
// clk160: 80 MHz
// clk40:  20  MHz
// clk400: 300 MHz
//
// WARNING: If this PLL is instantiated the clocks
// will run at slower frequencies, despite
// having names such as clk640, clk160, clk40.
//wire clk160_forward;

clk_wiz_2 pll_mid_high(
   .clk_in1_p(sysclk_in_p),
   .clk_in1_n(sysclk_in_n),
   .clk_out1(clk640),
   .clk_out2(clk160),
   .clk_out3(clk40),
   .clk_out4(clk400),
   .reset(rst_in),
   .locked(mmcm_locked)
);

//// Frequencies
//// clk640: 80 MHz
//// clk160: 20 MHz
//// clk40:  5  MHz
//// clk400: 400 MHz
//// 
//// WARNING: If this PLL is instantiated the clocks
//// will run at slower frequencies, despite
//// having names such as clk640, clk160, clk40.
//wire clk160_forward;

//clk_wiz_1 pll_slow(
//   .clk_in1_p(sysclk_in_p),
//   .clk_in1_n(sysclk_in_n),
//   .clk_out1(clk640),
//   .clk_out2(clk160),
//   .clk_out3(clk40),
//   .clk_out4(clk160_forward),
//   .reset(rst_in),
//   .locked(mmcm_locked)
//);

// OBUFDS Slow
//OBUFDS #(
//    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//    .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
//) clk160_obufds_slow (
//    .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//    .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//    .I(clk160_forward)              // Buffer input
//);

//// OBUFDS Mid
//OBUFDS #(
//    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//    .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
//) clk160_obufds_mid (
//    .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//    .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//    .I(clk640)              // Buffer input
//);

// OBUFDS Fast - COMMENTED OUT FROM ORIGINAL
//OBUFDS #(
//    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//    .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
//) clk160_obufds_fast (
//    .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//    .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//    .I(clk160)              // Buffer input
//);

//======================================
//              Aurora Rx
//======================================

/**
* The generate block will generate a variable amount of lanes based off the num_lanes variable.
* Uncomment aurora_rx_top      block in generate loop for bitrates less than 640 Mbps.
* Uncomment aurora_rx_top_xapp block in generate loop for bitrates more than 640 Mbps.
**/

wire ref_clk_bufg;
wire idelay_rdy;

BUFG
 ref_clock_bufg (
    .I (clk400),
    .O (ref_clk_bufg)
);

(* IODELAY_GROUP = "xapp_idelay" *)
IDELAYCTRL
 delayctrl (
    .RDY    (idelay_rdy),
    .REFCLK (ref_clk_bufg),
    .RST    (rst|vio_rst)
);

genvar j;

generate
    for (j=0; j < num_lanes; j=j+1)
        begin : rx_core
            //aurora_rx_top rx_lane (
            //    .rst(rst|vio_rst),
            //    .clk40(clk40),
            //    .clk160(clk160),
            //    .clk640(clk640),
            //    .data_in_p(data_in_p[i]),
            //    .data_in_n(data_in_n[i]),
            //    .blocksync_out(blocksync_out[i]),
            //    .gearbox_rdy(gearbox_rdy_rx[i]),
            //    .data_valid(data_valid[i]),
            //    .sync_out(sync_out[i]),
            //    .data_out(data_out[i])
            //);
            
            //aurora_rx_top_xapp rx_lane (
            //    .rst(rst|vio_rst),
            //    .clk40(clk40),
            //    .clk160(clk160),
            //    .clk640(clk640),
            //    .data_in_p(data_in_p[i]),
            //    .data_in_n(data_in_n[i]),
            //    .idelay_rdy(idelay_rdy),
            //    .blocksync_out(blocksync_out[i]),
            //    .gearbox_rdy(gearbox_rdy_rx[i]),
            //    .data_valid(data_valid[i]),
            //    .sync_out(sync_out[i]),
            //    .data_out(data_out[i])
            //);
            
            fmc_one_lane aurora_lane (
                            .rst(rst|vio_rst),
                            .clk40(clk40),
                            .clk160(clk160),
                            .clk640(clk640),
                            .data_in_p(data_in_p[j]),
                            .data_in_n(data_in_n[j]),
                            .idelay_rdy(idelay_rdy),
                            .blocksync_out(blocksync_out[j]),
                            .gearbox_rdy(gearbox_rdy_rx[j]),
                            .data_valid(data_valid[j]),
                            .sync_out(sync_out[j]),
                            .data_out(data_out[j]),
                            .data_in(data_in[j]),
                            .sync(sync[j]),
                            .gearbox_rdy(gearbox_rdy[j]),
                            .data_next(data_next[j]),
                            .data_out_p(data_out_p[j]),
                            .data_out_n(data_out_n[j])

             );
    end
endgenerate


/**

//======================================
//      Aurora Channel Bonding
//======================================
//channel_bond cb (
    .rst(rst|vio_rst),
    .clk40(clk40),
    .data_in(data_out),
    .sync_in(sync_out),
    .blocksync_out(blocksync_out),
    .gearbox_rdy_rx(gearbox_rdy_rx),
    .data_valid(data_valid),
    .data_out_cb(data_out_cb),
    .sync_out_cb(sync_out_cb),
    .data_valid_cb(data_valid_cb),
    .channel_bonded(channel_bonded)
);

//============================================================================
//                       IO Buffer Configuration Driver
//============================================================================
reg [31:0] io_config;
reg start;
reg [3:0] io_rst_cnt;
wire [31:0] vio_io_config;
wire vio_start;
wire vio_io_en;

always @(posedge clk160) begin
    if (rst|vio_rst) begin
        io_config <= 32'h0000_0000;
        start <= 1'b0;
        io_rst_cnt <= 4'h0;
    end
    else begin
        if (vio_io_en) begin
            io_config <= vio_io_config;
            start <= vio_start; 
        end
        else begin
            if (io_rst_cnt <= 15) begin
                io_rst_cnt <= io_rst_cnt + 1;
            end
            
            if (io_rst_cnt == 10) begin
                start <= 1'b1;
            end
            else begin
                start <= 1'b0;
            end
            
            io_config <= 32'hFFFF_FFFF;
        end
    end
end

io_buf_config_driver io_buf_config(
    .rst(rst|vio_rst),
    .clk160(clk160),
    .io_config(io_config),
    .start(start),
    .latch(latch),
    .clk_io(clk_io),
    .ser_in(ser_in)
);

**/

//============================================================================
//                          Debugging & Monitoring
//============================================================================

// ILA
ila_1 ila_slim (
    .clk(clk160),
    .probe0(rst|vio_rst),       // output wire [0 : 0] probe_out0
    .probe1(blocksync_out),     // output wire [3 : 0] probe_out1
    .probe2(data_out),          // output wire [255 : 0] probe_out2
    .probe3(data_out_cb),       // output wire [255 : 0] probe_out3
    .probe4(sync_out_cb),       // output wire [7 : 0] probe_out4
    .probe5(gearbox_rdy_rx),    // output wire [3 : 0] probe_out5
    .probe6(data_valid_cb),     // output wire [0 : 0] probe_out6
    .probe7(channel_bonded),     // output wire [0 : 0] probe_out7
    .probe8(latch),
    .probe9(clk_io),
    .probe10(ser_in)
);

// VIO
vio_0 vio (
  .clk(clk40),                 // input wire clk
  .probe_out0(vio_rst),         // output wire [0 : 0] probe_out0
  .probe_out1(vio_io_config),   // output wire [31:0]  probe_out1
  .probe_out2(vio_start),       // output wire [0:0]  probe_out2
  .probe_out3(vio_io_en)        // output wire [0:0]  probe_out3
);

endmodule

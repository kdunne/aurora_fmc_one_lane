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
    output [num_lanes-1:0] data_out_n
 
    // IO BUF CONFIG 
    //output latch,
    //output clk_io,
    //output ser_in
    
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
wire clk50;
wire mmcm_locked;

// Aurora Rx Core Signals
wire [63:0] data_out[num_lanes];
wire [1:0]  sync_out[num_lanes];
wire [num_lanes-1:0]  blocksync_out;
wire [num_lanes-1:0]  gearbox_rdy_rx;
wire [num_lanes-1:0]  data_valid;
reg [9:0] sync_header_invalid_count_i[num_lanes];
reg sync_done_r[num_lanes];
reg rxgearboxslip_out[num_lanes];

// Aurora Tx Core Signals
wire [num_lanes-1:0] gearbox_rdy;
wire [num_lanes-1:0] data_next;
reg [63:0] data_in[num_lanes];
reg [1:0] sync[num_lanes];
reg  [31:0] data32_iserdes[num_lanes];
wire [7:0]  sipo[num_lanes];

// Blocksync Signals
reg         next_begin_c[num_lanes];
reg         next_sh_invalid_c[num_lanes];
reg         next_sh_valid_c[num_lanes];
reg         next_slip_c[num_lanes];
reg         next_sync_done_c[num_lanes];
reg         next_test_sh_c[num_lanes];
wire        sh_count_equals_max_i[num_lanes];
wire        sh_invalid_cnt_equals_max_i[num_lanes];
wire        sh_invalid_cnt_equals_zero_i[num_lanes];
wire        slip_done_i[num_lanes];
wire        sync_found_i[num_lanes];
reg         sh_invalid_r[num_lanes];
reg         sh_valid_r[num_lanes];
reg  [99:0] slip_count_i[num_lanes];
reg  [15:0] sync_header_count_i[num_lanes];


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
wire [4:0]  vio_tap_value;
wire        vio_tap_en;
wire        vio_tap_set;

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
///// CHANGED TO clk_wiz_2 from wlk_wiz_0
clk_wiz_2 pll_mid(
   .clk_in1_p(sysclk_in_p),
   .clk_in1_n(sysclk_in_n),
   .clk_out1(clk640),
   .clk_out2(clk160),
   .clk_out3(clk40),
   .clk_out4(clk400),
   .clk_out5(clk50),
   .reset(rst_in),
   .locked(mmcm_locked)
);

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

//clk_wiz_2 pll_mid_high(
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

/** COMMENTED OUT SHOULD BE UNQUE TO EACH CORE - NOT CB'd**/
wire ref_clk_bufg;
//wire idelay_rdy;


BUFG
 ref_clock_bufg (
    .I (clk400),
    .O (ref_clk_bufg)
);

/**
(* IODELAY_GROUP = "xapp_idelay" *)
IDELAYCTRL
 delayctrl (
    .RDY    (idelay_rdy),
    .REFCLK (ref_clk_bufg),
    .RST    (rst|vio_rst)
);
**/

genvar j;

generate
    for (j=0; j < num_lanes; j=j+1)
        begin : aurora_core
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
            
            fmc_one_lane aurora_fmc_one_lane (
                            .rst(rst|vio_rst),
                            .clk40(clk40),
                            .clk160(clk160),
                            .clk640(clk640),
                            .clk400(clk400),
                            .clk50(clk50),
                            .data_in_p(data_in_p[j]),
                            .data_in_n(data_in_n[j]),
                            .blocksync_out(blocksync_out[j]),
                            .data_valid(data_valid[j]),
                            .sync_out(sync_out[j]),
                            .data_out(data_out[j]),
                            .data_in(data_in[j]),
                            .sync(sync[j]),
                            .gearbox_rdy_rx(gearbox_rdy_rx[j]),
                            .gearbox_rdy(gearbox_rdy[j]),
                            .data_next(data_next[j]),
                            .data_out_p(data_out_p[j]),
                            .data_out_n(data_out_n[j]),
                            .idelay_ref_clock(ref_clk_bufg),
                            .sync_header_invalid_count_i(sync_header_invalid_count_i[j]),
                            .sync_done_r(sync_done_r[j]),
                            .rxgearboxslip_out(rxgearboxslip_out[j]),
                            .data32_iserdes(data32_iserdes[j]),
                            .sipo(sipo[j]),
                            .next_begin_c(next_begin_c[j]),
                            .next_sh_invalid_c(next_sh_invalid_c[j]),
                            .next_sh_valid_c(next_sh_valid_c[j]),
                            .next_slip_c(next_slip_c[j]),
                            .next_sync_done_c(next_sync_done_c[j]),
                            .next_test_sh_c(next_test_sh_c[j]),
                            .sh_count_equals_max_i(sh_count_equals_max_i[j]),
                            .sh_invalid_cnt_equals_max_i(sh_invalid_cnt_equals_max_i[j]),
                            .sh_invalid_cnt_equals_zero_i(sh_invalid_cnt_equals_zero_i[j]),
                            .slip_done_i(slip_done_i[j]),
                            .sync_found_i(sync_found_i[j]),
                            .sh_invalid_r(sh_invalid_r[j]),
                            .sh_valid_r(sh_valid_r[j]),
                            .slip_count_i(slip_count_i[j]),
                            .sync_header_count_i(sync_header_count_i[j])

             );
    end
endgenerate


//============================================================================
//                          Debugging & Monitoring
//============================================================================


// ILA
ila_1 ila_slim (
    .clk(clk160),
    .probe0(rst|vio_rst),       // output wire [0 : 0] probe_out0
    .probe1(mmcm_locked),     // output wire [3 : 0] probe_out1
    .probe2(data_in[5]),          // output wire [63 : 0] probe_out2
    .probe3(data_out[5]),       // output wire [63 : 0] probe_out3
    .probe4(blocksync_out[5]),       // output wire [7 : 0] probe_out4
    .probe5(gearbox_rdy_rx[5]),    // output wire [3 : 0] probe_out5
    .probe6(gearbox_rdy[5]),     // output wire [0 : 0] probe_out6
    .probe7(data_valid[5]),     // output wire [0 : 0] probe_out7
    .probe8(sync[5]),
    .probe9(data_next[5]),
    .probe10(data_in[2]), 
    .probe11(data_out[2]),
    .probe12(sync_header_invalid_count_i[5]),
    .probe13(sync_done_r[5]),
    .probe14(rxgearboxslip_out[5]),
    .probe15(sipo[5]),
    .probe16(next_sync_done_c[5]),
    .probe17(sh_invalid_cnt_equals_zero_i[5]),
    .probe18(sh_count_equals_max_i[5]),
    .probe19(sh_invalid_cnt_equals_max_i[5]),
    .probe20(next_begin_c[5]),
    .probe21(next_sh_invalid_c[5]),
    .probe22(next_sh_valid_c[5]),
    .probe23(next_slip_c[5]),
    .probe24(slip_done_i[5]),
    .probe25(sync_found_i[5]),
    .probe26(sh_invalid_r[5]),
    .probe27(sh_valid_r[5]),
    .probe28(slip_count_i[5]),
    .probe29(sync_header_count_i[5])
);


// VIO
vio_0 vio (
  .clk(clk160),                 // input wire clk
  .probe_out0(vio_rst),         // output wire [0 : 0] probe_out0
  .probe_out1(vio_en),
  .probe_out2(vio_data),
  .probe_out3(vio_en_counting),
  .probe_out4(vio_tap_value),
  .probe_out5(vio_tap_en),
  .probe_out6(vio_tap_set)
);


endmodule

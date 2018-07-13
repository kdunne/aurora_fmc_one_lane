// Engineer: Lev Kurilenko
// Date: 8/7/2017
// Module: Aurora Rx Top
// 
// Changelog: 
// (Lev Kurilenko) 8/7/2017 - Created top module

 module fmc_one_lane(

    // Rx Signals
    input rst,
    //input sysclk_in_p,
    //input sysclk_in_n,
    input clk40,
    input clk160,
    input clk640,
    input clk400,
    input clk50,
    input idelay_ref_clock,

    input data_in_p,
    input data_in_n,
    
    output blocksync_out,
    output data_valid,
    output reg [1:0] sync_out,
    output [63:0] data_out,
    output gearbox_rdy_rx,
    output reg [9:0] sync_header_invalid_count_i,
    output reg sync_done_r,
    output reg rxgearboxslip_out,
    output reg  [31:0] data32_iserdes,
    output wire [7:0]  sipo,
    //input rst_in,
    
    output LCD_DB4_LS,
    output LCD_DB5_LS,
    output LCD_DB6_LS,
    output LCD_DB7_LS,
    output LCD_E_LS,
    output LCD_RS_LS,
    output LCD_RW_LS,
    
   // output USER_SMA_CLOCK_P, // Rx->Tx clock internal
   // output USER_SMA_CLOCK_N

    // Tx Signals
    input [63:0] data_in,
    input [1:0] sync,
    output data_next,
    output data_out_p,
    output data_out_n,
    output gearbox_rdy,
    
    //Blocksync Signals
    output reg         next_begin_c,
    output reg         next_sh_invalid_c,
    output reg         next_sh_valid_c,
    output reg         next_slip_c,
    output reg         next_sync_done_c,
    output reg         next_test_sh_c,
    output wire        sh_count_equals_max_i,
    output wire        sh_invalid_cnt_equals_max_i,
    output wire        sh_invalid_cnt_equals_zero_i,
    output wire        slip_done_i,
    output wire        sync_found_i,
    output reg         sh_invalid_r,
    output reg         sh_valid_r,
    output reg  [99:0] slip_count_i,
    output reg  [15:0] sync_header_count_i
);

localparam ber_char = 64'hB0B5_C0CA_C01A_CAFE;

// Resets
//wire rst;

// Clocks
//wire clk40;
//wire clk50; // For LCD
//wire clk160;
//wire clk640;
//wire clk200;
//wire clk300;
//wire clk400;
wire mmcm_locked; 
//wire mmcm_locked_a, mmcm_locked_b, mmcm_locked;
//assign mmcm_locked = mmcm_locked_a & mmcm_locked_b; 

// ISERDES Signals
//reg  [31:0] data32_iserdes;
//wire [7:0]  sipo;
wire ref_clk_bufg;
wire idelay_rdy;

// OSERDES Signals
wire [7:0] piso;
reg [63:0] tx_buffer;
reg [2:0] tx_buf_cnt;

// Rx Gearbox Signals
//wire        gearbox_rdy_rx;
wire [65:0] data66_gb_rx;
//wire        data_valid;

// Tx Gearbox Signals
wire [31:0] data32_gb_tx;
//wire        data_next;
//wire        gearbox_rdy;

// Scrambler Signals
//reg [63:0] data_in;
//reg [1:0] sync;
wire [65:0] data66_tx_scr;

// Descrambler Signals
//wire [1:0]  sync_out;
//wire [63:0] data_out;

// Block Sync Signals
//wire        blocksync_out;
//wire        rxgearboxslip_out;

// Bit Error Rate Signals
wire [63:0] data64_rx_uns;
wire [63:0] ber_cnt;
wire        ber_sync;
wire        sync_init;

// Bitslip FSM Signals
wire        iserdes_slip;
wire        gearbox_slip;

// VIO Signals
//wire        vio_rst;
//wire        vio_en;
//wire [63:0] vio_data;
//wire        vio_en_counting;
//wire [4:0]  vio_tap_value;
//wire        vio_tap_en;
//wire        vio_tap_set;

//Resets
//assign rst = !mmcm_locked;

// Serializer 32 to 8 bits
always @(posedge clk160) begin
    if (rst) begin
        tx_buf_cnt <= 3'h0;
    end
    else begin
        tx_buf_cnt <= tx_buf_cnt + 1;

        if ((tx_buf_cnt == 0) || (tx_buf_cnt == 4)) begin
            tx_buffer <= {data32_gb_tx, tx_buffer[39:8]};
        end
        else begin
            tx_buffer <= {8'h00, tx_buffer >> 8};
        end
    end
end

assign piso = tx_buffer[7:0];


// Data Reception (8 bits to 32 bits)
always @(posedge clk160) begin
    if (rst) begin
        data32_iserdes <= 32'h0000_0000;
    end
    else begin
        data32_iserdes[31:24] <= sipo;
        data32_iserdes[23:16] <= data32_iserdes[31:24];
        data32_iserdes[15:8]  <= data32_iserdes[23:16];
        data32_iserdes[7:0]   <= data32_iserdes[15:8];
    end
end

reg [31:0] data32_iserdes_r;
reg [31:0] data32_iserdes_r_r;

always @(posedge clk40) begin
    if (rst) begin
        data32_iserdes_r <= 32'h0000_0000;
        data32_iserdes_r_r <= 32'h0000_0000;
    end
    else begin
        data32_iserdes_r <= data32_iserdes;
        data32_iserdes_r_r <= data32_iserdes_r;
    end
end

wire [1:0] sync_out_i;
// Delay sync_out by one 40 Mhz clock cycle to align with data_out
// Needed for proper channel bonding.
always @(posedge clk40) begin
    if (rst) begin
        sync_out <= 2'b00;
    end
    else begin
        sync_out <= sync_out_i;
    end
end


//==========================
//  Clock Generation MMCM
//==========================
// Frequencies
// clk40:  40  MHz
// clk160: 160 MHz
// clk640: 640 MHz
// 
// clk_wiz_0 pll_fast(
//    .clk_in1_p(sysclk_in_p),
//    .clk_in1_n(sysclk_in_n),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .reset(rst_in),
//    .locked(mmcm_locked)
// );

// // Frequencies - EDITED
// // clk40:  5  MHz
// // clk160: 20 MHz
// // clk400: 300 MHz
// // clk640: 80 MHz
// // 
// // If this PLL is instantiated the clocks
// // will run at slower frequencies, despite
// // having names such as clk40, clk160, clk640.
//clk_wiz_1 pll_slow(
//    .clk_in1_p(sysclk_in_p),
//    .clk_in1_n(sysclk_in_n),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .clk_out4(clk50),
//    .clk_out5(clk200),
//    .reset(rst_in),
//    .locked(mmcm_locked)
//);
// 
// OBUFDS #(
//     .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//     .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
// ) clk160_obufds (
//     .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//     .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//     .I(clk200)              // Buffer input
// );


/** COMMENTED OUT MOVED TO TOP

// Frequencies
// clk40:  10  MHz
// clk160: 40 MHz
// clk640: 160 MHz
// clk200: 200 MHz
// clk50:  50 MHZ
// Internal clocks generated from incoming clk sent over SMA
 clk_wiz_2 pll_inc_clk(
    .clk_in1_p(sysclk_in_p),
    .clk_in1_n(sysclk_in_n),
    .clk_out1(clk640),
    .clk_out2(clk160),
    .clk_out3(clk40),
    .clk_out4(clk200),
    .reset(rst_in),
    .locked(mmcm_locked)
 );
 **/
 

// Frequencies
// clk40:  39.0625  MHz
// clk160: 156.25 MHz
// clk640: 625 MHz
// clk200: 312.5 MHz
// clk50:  50 MHZ
// 
// If this PLL is instantiated the clocks
// will run at slower frequencies, despite
// having names such as clk40, clk160, clk640.

//clk_wiz_3 pll_fast_a(
//   .clk_in1_p(sysclk_in_p),
//   .clk_in1_n(sysclk_in_n),
//   .clk_out1(clk640),
//   .clk_out2(clk160),
//   .clk_out3(clk40),
   ////.clk_out4(clk200),
   //.clk_out4(clk300),
  // .clk_out4(clk400),
   //.clk_out4(clk50),
   //.clk_out5(clk50),
//   .reset(rst_in),
//   .locked(mmcm_locked_a)
//);

//clk_wiz_5 pll_fast_b(
//    .clk_in1(clk160),
//    .clk_out1(clk400),     
//    .reset(rst_in),
//    .locked(mmcm_locked_b)      
//);      

// Rx->Tx clock internal don't need diff output to Tx
//OBUFDS #(
//    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//    .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
//) clk160_obufds (
//    .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//    .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//    .I(clk160)              // Buffer input
//);

// TX PLL_FAST


//reg tri_en;
//wire clk640buf;

//IOBUF data_out_p_buffer (
//    .O(clk640buf),         // Buffer output
//    .IO(clk640inout),    // Buffer inout port (connect directly to top-level port)
//    .I(clk640),             // Buffer input
//    .T(tri_en)                // 3-state enable input, high=input, low=output
//);

//always @(posedge clk160) begin
//    if (rst|vio_rst) begin
//        tri_en <= 1'b0;
//    end
//end

// // Frequencies
// // clk40:  20 MHz
// // clk160: 80 MHz
// // clk640: 320 MHz
// // clk200: 200 MHz
// // clk50:  50 MHZ
// // 
// // If this PLL is instantiated the clocks
// // will run at slower frequencies, despite
// // having names such as clk40, clk160, clk640.
// clk_wiz_4 pll_mid(
//    .clk_in1_p(sysclk_in_p),
//    .clk_in1_n(sysclk_in_n),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .clk_out4(clk200),
//    .clk_out5(clk50),
//    .reset(rst_in),
//    .locked(mmcm_locked)
// );
// 
// OBUFDS #(
//     .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
//     .SLEW("FAST")           // Specify the output slew rate (Changed from "SLOW" [default])
// ) clk160_obufds (
//     .O(USER_SMA_CLOCK_P),   // Diff_p output (connect directly to top-level port)
//     .OB(USER_SMA_CLOCK_N),  // Diff_n output (connect directly to top-level port)
//     .I(clk200)              // Buffer input
// );

//==================================
//            Aurora Tx
//==================================

// Scrambler
scrambler scr (
    .clk(clk40),
    .rst(rst),
    .data_in(data_in),
    .sync_info(sync),
    .enable(data_next&gearbox_rdy),
    .data_out(data66_tx_scr)
);

// Gearbox
gearbox66to32 tx_gb (
    .rst(rst),
    .clk(clk40),
    //.data66(data66_tx_scr),
    .data66({sync,data_in}),    // Use this to bypass Scrambler
    .gearbox_rdy(gearbox_rdy),
    .data32(data32_gb_tx),
    .data_next(data_next)
);

// OSERDES Interface
cmd_oserdes piso0_1280 (
    .io_reset(rst),
    .data_out_from_device(piso),
    .data_out_to_pins_p(data_out_p),
    .data_out_to_pins_n(data_out_n),
    .clk_in(clk640),
    .clk_div_in(clk160)
);


//===================
// Aurora Rx
//===================
// // ISERDES without IDELAYCTRL or IDELAYE2
// cmd_iserdes i0 (
//     .data_in_from_pins_p(data_in_p),
//     .data_in_from_pins_n(data_in_n),
//     .clk_in(clk640),
//     .clk_div_in(clk160),
//     .io_reset(rst|vio_rst),
//     .bitslip(iserdes_slip),
//     .data_in_to_device(sipo)
// );

// wire delay_locked;
// // ISERDES with IDELAYCTRL or IDELAYE2
// selectio_wiz_0 i0 (
//   .data_in_from_pins_p(data_in_p),
//   .data_in_from_pins_n(data_in_n),
//   .clk_in(clk640),
//   .clk_div_in(clk160),
//   .io_reset(rst|vio_rst),
//   .in_delay_reset(rst|vio_rst),
//   .in_delay_data_ce(1'b0),
 //  .in_delay_data_inc(1'b0),
//   .ref_clock(clk200),
//   .delay_locked(delay_locked),
//   .bitslip(iserdes_slip),
 //  .data_in_to_device(sipo)
// );

// ISERDES with Fixed Tap Value
// selectio_wiz_0 i0 (
//   .data_in_from_pins_p(data_in_p),
//   .data_in_from_pins_n(data_in_n),
//   .clk_in(clk640),
//   .clk_div_in(clk160),
//   .io_reset(rst|vio_rst),
//   .ref_clock(clk200),
//   .delay_locked(delay_locked),
//   .bitslip(iserdes_slip),
//   .data_in_to_device(sipo)
// );


/** OLD SERDES REPLACED BY XAPP 1017 IMPLEMENTATION**/
//selectio_wiz_0 i0 (
//  .data_in_from_pins_p(data_in_p),
//  .data_in_from_pins_n(data_in_n),
//  .clk_in(clk640),
//  .clk_div_in(clk160),
//  .io_reset(rst|vio_rst),

//  .in_delay_reset(in_delay_reset),      // input wire in_delay_reset
//  .in_delay_tap_in(vio_tap_value),          // input wire [4 : 0] in_delay_tap_in
//  .in_delay_tap_out(vio_tap_out),           // output wire [4 : 0] in_delay_tap_out
//  .in_delay_data_ce(delay_ce),          // input wire [0 : 0] in_delay_data_ce
//  .in_delay_data_inc(delay_inc),        // input wire [0 : 0] in_delay_data_inc
  
//  //.ref_clock(clk200),
//  //.ref_clock(clk300),
//  .ref_clock(clk400),
//  .delay_locked(delay_locked),
//  .bitslip(iserdes_slip),
//  .data_in_to_device(sipo)
//);

/** XAPP 1017 IMPLEMENTATION FOR ISERDES **/
wire rx_lckd;
wire [28:0] debug;


serdes_1_to_468_idelay_ddr #(
	.S			(8),				// Set the serdes factor (4, 6 or 8)
 	.HIGH_PERFORMANCE_MODE 	("TRUE"),
      	.D			(1),				// Number of data lines
      	.REF_FREQ		(400.0),			// Set idelay control reference frequency, 300 MHz shown EDITED from 300
      	.CLKIN_PERIOD		(6.664),			// Set input clock period, 600 MHz shown EDITED FROM 1.666, now 160 MHz
	.DATA_FORMAT 		("PER_CLOCK"))  		// PER_CLOCK or PER_CHANL data formatting
iserdes_inst (                      
	.clk160             (clk160),
    .clk640             (clk640),
	.datain_p     		(data_in_p),
	.datain_n     		(data_in_n),
	.enable_phase_detector	(1'b1),				// enable phase detector (active alignment) operation
	.enable_monitor		(1'b1),				// enables data eye monitoring
	.dcd_correct		(1'b0),				// enables clock duty cycle correction
	.rxclk    		(),
	.idelay_rdy		(idelay_rdy),
	.system_clk		(clk160),
	.reset     		(rst),
	.rx_lckd		(rx_lckd),
	.bitslip  		(iserdes_slip),
	.rx_data		(sipo),
	.bit_rate_value		(16'h0320),			// required bit rate value in BCD (1200 Mbps shown)
	.bit_time_value		(),				// bit time value
	.eye_info		(),				// data eye monitor per line
	.m_delay_1hot		(),				// sample point monitor per line
	.debug			 (debug),           // debug bus 
	.clock_sweep     ()) ;				

(* IODELAY_GROUP = "xapp_idelay" *)
  IDELAYCTRL
    delayctrl (
     .RDY    (idelay_rdy),
     .REFCLK (idelay_ref_clock),
     .RST    (rst));
/**
BUFG
    ref_clock_bufg (
    .I (clk400),
    .O (ref_clk_bufg)); 
**/

gearbox32to66 rx_gb (
    .rst(rst),
    .clk(clk40),
    .data32(data32_iserdes_r_r),
    .gearbox_rdy(gearbox_rdy_rx),
    .gearbox_slip(gearbox_slip),
    .data66(data66_gb_rx),
    .data_valid(data_valid)
);

descrambler uns (
    .clk(clk40),
    .rst(!blocksync_out|rst),
    .data_in(data66_gb_rx), 
    .sync_info(sync_out_i),
    .enable(blocksync_out&data_valid&gearbox_rdy_rx),
    .data_out(data_out)
);

block_sync # (
    .SH_CNT_MAX(16'd1000),           // default: 64
    .SH_INVALID_CNT_MAX(10'd16)     // default: 16
)

b_sync (
    .clk(clk40),
    .system_reset(rst),
    .blocksync_out(blocksync_out),
    .rxgearboxslip_out(rxgearboxslip_out),
    .rxheader_in(sync_out_i),
    .rxheadervalid_in(data_valid&gearbox_rdy_rx),
    .sync_header_invalid_count_i(sync_header_invalid_count_i),
    .sync_done_r(sync_done_r),
    .next_begin_c(next_begin_c),
    .next_sh_invalid_c(next_sh_invalid_c),
    .next_sh_valid_c(next_sh_valid_c),
    .next_slip_c(next_slip_c),
    .next_sync_done_c(next_sync_done_c),
    .next_test_sh_c(next_test_sh_c),
    .sh_count_equals_max_i(sh_count_equals_max_i),
    .sh_invalid_cnt_equals_max_i(sh_invalid_cnt_equals_max_i),
    .sh_invalid_cnt_equals_zero_i(sh_invalid_cnt_equals_zero_i),
    .slip_done_i(slip_done_i),
    .sync_found_i(sync_found_i),
    .sh_invalid_r(sh_invalid_r),
    .sh_valid_r(sh_valid_r),
    .slip_count_i(slip_count_i),
    .sync_header_count_i(sync_header_count_i)
);

bitslip_fsm bs_fsm (
    .clk(clk160),
    .rst(rst),
    .blocksync(blocksync_out),
    .rxgearboxslip(rxgearboxslip_out),
    .iserdes_slip(iserdes_slip),
    .gearbox_slip(gearbox_slip)
);

ber ber_inst(
    .rst(rst),
    .clk40(clk40),
    .blocksync_out(blocksync_out),
    .data_valid(data_valid),
    .gearbox_rdy_rx(gearbox_rdy_rx),
    .data66_gb_rx(data66_gb_rx),
    .data64_rx_uns(data_out), // data64_rx_uns not driven. should this be data_out?
    .ber_cnt(ber_cnt),
    .ber_sync(ber_sync),
    .sync_init(sync_init)
);





//============================================================================
//                          Debugging & Monitoring
//============================================================================

// ILA
//ila_1 ila_slim_rx (
//    .clk(clk160),
//    .probe0(rst|vio_rst),
//    .probe1(blocksync_out),
//    .probe2(data_out),
//    .probe3(ber_cnt),
//    .probe4(rx_lckd),
//    .probe5(sipo),
//    .probe6(debug),
//    .probe7(ber_sync),
//    .probe8(sync_init)
//);

/** COMMENTED OUT MOVED TO 8_pair_top.sv
ila_1 ila_slim_tx (
    .clk(clk160),
    .probe0(rst),
    .probe1(mmcm_locked),
    .probe2(data_in),
    .probe3(data_out),
    .probe4(data66_gb_rx),
    .probe5(blocksync_out),
    .probe6(gearbox_rdy_rx),
    .probe7(data_valid),
    .probe8(sync_out),
    .probe9(ber_cnt),
    .probe10(rx_lckd)
);


//ila_0 ila (
//	.clk(clk160),                  // input wire clk

//    .probe0(rst),                 // input wire [0:0]  probe0  
//	.probe1(clk40),               // input wire [0:0]  probe1 
//	.probe2(clk160),              // input wire [0:0]  probe2 
//	.probe3(1'b0),                // input wire [0:0]  probe3 
//    .probe4(mmcm_locked),         // input wire [0:0]  probe4 
//	.probe5(gearbox_rdy_rx),      // input wire [0:0]  probe5 
//	.probe6(data_valid),          // input wire [0:0]  probe6 
//	.probe7(blocksync_out),       // input wire [0:0]  probe7 
//	.probe8(rxgearboxslip_out),   // input wire [0:0]  probe8 
//	.probe9(iserdes_slip),        // input wire [0:0]  probe9 
//	.probe10(gearbox_slip),       // input wire [0:0]  probe10 
//	.probe11(data32_iserdes),     // input wire [31:0] probe11 
//    .probe12(sipo),               // input wire [7:0]  probe12 
//	.probe13(data66_gb_rx),       // input wire [65:0] probe13 
//	.probe14(sync_out),           // input wire [1:0]  probe14 
//	.probe15(data_out),           // input wire [63:0] probe15
//	.probe16(bit_err_cnt),        // input wire [15:0] probe16 
//    .probe17(bit_err_cnt_next),   // input wire [15:0] probe17 
//    .probe18(inv_data_cnt),       // input wire [15:0] probe18 
//    .probe19(data64_latched),     // input wire [63:0] probe19 
//    .probe20(data64_added),       // input wire [63:0] probe20 
//    .probe21(latched_true)        // input wire [0:0]  probe21
//);

/** COMMENTED OUT MOVED TO 8_pair_top.sv
// VIO
vio_0 vio_tx (
    .clk(clk160),
    .probe_out0(vio_rst),
    .probe_out1(vio_en),
    .probe_out2(vio_data),
    .probe_out3(vio_en_counting),
    .probe_out4(vio_tap_value),   // output wire [4 : 0] probe_out1
    .probe_out5(vio_tap_en),      // output wire [0 : 0] probe_out2
    .probe_out6(vio_tap_set)      // output wire [0 : 0] probe_out3
);  
**/

//vio_0 vio_rx (
//    .clk(clk160),                 // input wire clk
//    .probe_out0(vio_rst),         // output wire [0 : 0] probe_out0
//    .probe_out1(vio_tap_value),   // output wire [4 : 0] probe_out1
//    .probe_out2(vio_tap_en),      // output wire [0 : 0] probe_out2
//    .probe_out3(vio_tap_set)      // output wire [0 : 0] probe_out3
//);

wire SF_CE0;

// LCD
lcd lcd_debug (
     .clk(clk50),
     .rst(rst),
     .SF_D({LCD_DB7_LS, LCD_DB6_LS, LCD_DB5_LS, LCD_DB4_LS}),
     .LCD_E(LCD_E_LS),
     .LCD_RS(LCD_RS_LS),
     .LCD_RW(LCD_RW_LS),
     .SF_CE0(SF_CE0),
     .inv_data_cnt(ber_cnt)
);
endmodule

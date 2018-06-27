// Engineer: Lev Kurilenko
// Date: 8/3/2017
// Module: Aurora Tx Top
// 
// Changelog: 
// (Lev Kurilenko) 8/3/2017 - Created top module
// (Lev Kurilenko) 8/7/2017 - Added ILA and VIO

module aurora_tx_top(
    // input sysclk_in_p,
    // input sysclk_in_n,
    input rst_in,
    
    output data_out_p,
    output data_out_n,
    
    input USER_SMA_CLOCK_P,
    input USER_SMA_CLOCK_N
);

localparam ber_char = 64'hB0B5_C0CA_C01A_CAFE;   // From Memory may need to be changed

// Resets
wire rst;

// Clocks
wire clk640;
wire clk160;
wire clk40;
wire mmcm_locked;

// Tx Gearbox Signals
wire [31:0] data32_gb_tx;
wire        data_next;
wire        gearbox_rdy;

// Scrambler Signals
reg  [63:0] data_in;
reg  [1:0]  sync;
wire [65:0] data66_tx_scr;

// OSERDES Signals
wire [7:0]  piso;
reg  [63:0] tx_buffer;
reg  [2:0]  tx_buf_cnt;

// Reset deasserted when mmcm locks
assign rst = !mmcm_locked;

// Debug/Monitoring Signals
wire vio_rst;
wire vio_en;
wire [63:0] vio_data;
wire vio_en_counting;

// LCD Debugging
// reg [31:0] inv_header_cnt;

// Data Driver
always @(posedge clk40) begin
    if (rst) begin
        data_in <= 64'h0000_0000_0000_0000;
        sync <= 2'b00;
        //inv_header_cnt <= 32'h0000_0000;
    end
    else if (gearbox_rdy&data_next) begin
        //data_in <= data_in + 1;
        
        // Used for BER Testing
        //data_in <= ber_char;
        //sync <= 2'b01;
        
        if (vio_en) begin
            if (vio_en_counting) begin
                data_in <= data_in + 1;
                sync <= 2'b01;
                
                // LCD Debugging
                // inv_header_cnt <= inv_header_cnt + 1;
                // if (inv_header_cnt < 40_000_000) begin
                //     sync <= 2'b01;
                // end
                // else if (inv_header_cnt == 40_000_000) begin
                //     sync <= 2'b00;
                //     inv_header_cnt <= 32'h0000_0000;
                // end
            end
            else begin
                data_in <= vio_data;
                sync <= 2'b01;
            end
        end
        else begin
            data_in <= ber_char;
            sync <= 2'b10;
        end
    end
end

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

// Frequencies
// clk40:  10  MHz
// clk160: 40 MHz
// clk640: 160 MHz
// 
// If this PLL is instantiated the clocks
// will run at slower frequencies, despite
// having names such as clk40, clk160, clk640.
// clk_wiz_1 pll_slow(
//    .clk_in1_p(sysclk_in_p),
//    .clk_in1_n(sysclk_in_n),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .reset(rst_in),
//    .locked(mmcm_locked)
// );

// Frequencies
// clk40:  10  MHz
// clk160: 40 MHz
// clk640: 160 MHz
// Internal clocks generated from incoming clk sent over SMA or VHDCI
// clk_wiz_2 pll_inc_clk(
//    .clk_in1_p(USER_SMA_CLOCK_P),
//    .clk_in1_n(USER_SMA_CLOCK_N),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .reset(rst_in),
//    .locked(mmcm_locked)
// );

// Frequencies
// clk40:  39.0625  MHz
// clk160: 156.25 MHz
// clk640: 625 MHz
// Internal clocks generated from incoming clk sent over SMA or VHDCI
clk_wiz_3 pll_fast(
   .clk_in1_p(USER_SMA_CLOCK_P),
   .clk_in1_n(USER_SMA_CLOCK_N),
   
   // Inverted incoming clock signal (roughly 400ps delay in data out signal)
   //.clk_in1_p(USER_SMA_CLOCK_N),
   //.clk_in1_n(USER_SMA_CLOCK_P),
   
   .clk_out1(clk640),
   .clk_out2(clk160),
   .clk_out3(clk40),
   .reset(rst_in),
   .locked(mmcm_locked)
);

// // Frequencies
// // clk40:  20  MHz
// // clk160: 80 MHz
// // clk640: 320 MHz
// // Internal clocks generated from incoming clk sent over SMA or VHDCI
// clk_wiz_4 pll_mid(
//    .clk_in1_p(USER_SMA_CLOCK_P),
//    .clk_in1_n(USER_SMA_CLOCK_N),
//    .clk_out1(clk640),
//    .clk_out2(clk160),
//    .clk_out3(clk40),
//    .reset(rst_in),
//    .locked(mmcm_locked)
// );

//==========================
//        Aurora Tx
//==========================

// Scrambler
scrambler scr (
    .clk(clk40),
    .rst(rst|vio_rst),
    .data_in(data_in),
    .sync_info(sync),
    .enable(data_next&gearbox_rdy),
    .data_out(data66_tx_scr)
);

// Gearbox
gearbox66to32 tx_gb (
    .rst(rst|vio_rst),
    .clk(clk40),
    .data66(data66_tx_scr),
    //.data66({sync, data_in}),     // Use this to bypass Scrambler
    .gearbox_rdy(gearbox_rdy),
    .data32(data32_gb_tx),
    .data_next(data_next)
);

//OSERDES Interface
cmd_oserdes piso0_1280(
   .io_reset(rst|vio_rst),
   .data_out_from_device(piso),
   .data_out_to_pins_p(data_out_p),
   .data_out_to_pins_n(data_out_n),
   .clk_in(clk640),
   .clk_div_in(clk160)
);

//============================================================================
//                          Debugging & Monitoring
//============================================================================

// ILA
ila_1 ila_slim (
    .clk(clk160),             // input wire clk
    .probe0(data_in),         // input wire [63:0] probe0  
    .probe1(mmcm_locked),     // input wire [0:0] probe1 
    .probe2(gearbox_rdy)      // input wire [0:0] probe2 
);

// ila_0 ila (
// .clk(clk160),              // input wire clk
// .probe0 (data_in),         // input wire [63:0] probe0  
// .probe1 (data32_gb_tx),    // input wire [31:0] probe1 
// .probe2 (data66_tx_scr),   // input wire [65:0] probe2 
// .probe3 (sync),            // input wire [1:0]  probe3 
// .probe4 (piso),            // input wire [7:0]  probe4 
// .probe5 (mmcm_locked),     // input wire [1:0]  probe5 
// .probe6 (1'b0),            // input wire [0:0]  probe6 
// .probe7 (clk160),          // input wire [0:0]  probe7 
// .probe8 (clk40),           // input wire [0:0]  probe8 
// .probe9 (gearbox_rdy),     // input wire [0:0]  probe9 
// .probe10(rst),             // input wire [0:0]  probe10 
// .probe11(tx_buffer),       // input wire [63:0] probe11
//    .probe12(tx_buf_cnt)       // input wire [2:0]  probe12
// );

// VIO
// vio_1 vio_slim (
//   .clk(clk40),
//   .probe_out0(vio_rst)         // output wire [0:0]  probe_out0
// );

vio_0 vio (
  .clk(clk40),
  .probe_out0(vio_rst),         // output wire [0:0]  probe_out0
  .probe_out1(vio_en),          // output wire [0:0]  probe_out1
  .probe_out2(vio_data),        // output wire [63:0] probe_out2
  .probe_out3(vio_en_counting) // output wire [0:0]  probe_out3
);

endmodule

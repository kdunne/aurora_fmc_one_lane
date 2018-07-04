// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Mon Jul  2 15:16:31 2018
// Host        : dhcp-130-148.ucsc.edu running 64-bit Scientific Linux CERN SLC release 6.9 (Carbon)
// Command     : write_verilog -force -mode synth_stub
//               /home/pixdaq/kdunne/aurora_fmc_one_lane/aurora.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_stub.v
// Design      : selectio_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module selectio_wiz_0(data_in_from_pins_p, data_in_from_pins_n, 
  data_in_to_device, in_delay_reset, in_delay_data_ce, in_delay_data_inc, delay_locked, 
  ref_clock, bitslip, clk_in, clk_div_in, io_reset)
/* synthesis syn_black_box black_box_pad_pin="data_in_from_pins_p[0:0],data_in_from_pins_n[0:0],data_in_to_device[7:0],in_delay_reset,in_delay_data_ce[0:0],in_delay_data_inc[0:0],delay_locked,ref_clock,bitslip[0:0],clk_in,clk_div_in,io_reset" */;
  input [0:0]data_in_from_pins_p;
  input [0:0]data_in_from_pins_n;
  output [7:0]data_in_to_device;
  input in_delay_reset;
  input [0:0]in_delay_data_ce;
  input [0:0]in_delay_data_inc;
  output delay_locked;
  input ref_clock;
  input [0:0]bitslip;
  input clk_in;
  input clk_div_in;
  input io_reset;
endmodule

-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Mon Jul  2 15:16:31 2018
-- Host        : dhcp-130-148.ucsc.edu running 64-bit Scientific Linux CERN SLC release 6.9 (Carbon)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/pixdaq/kdunne/aurora_fmc_one_lane/aurora.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_stub.vhdl
-- Design      : selectio_wiz_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx485tffg1761-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity selectio_wiz_0 is
  Port ( 
    data_in_from_pins_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_in_from_pins_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_in_to_device : out STD_LOGIC_VECTOR ( 7 downto 0 );
    in_delay_reset : in STD_LOGIC;
    in_delay_data_ce : in STD_LOGIC_VECTOR ( 0 to 0 );
    in_delay_data_inc : in STD_LOGIC_VECTOR ( 0 to 0 );
    delay_locked : out STD_LOGIC;
    ref_clock : in STD_LOGIC;
    bitslip : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_in : in STD_LOGIC;
    clk_div_in : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );

end selectio_wiz_0;

architecture stub of selectio_wiz_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "data_in_from_pins_p[0:0],data_in_from_pins_n[0:0],data_in_to_device[7:0],in_delay_reset,in_delay_data_ce[0:0],in_delay_data_inc[0:0],delay_locked,ref_clock,bitslip[0:0],clk_in,clk_div_in,io_reset";
begin
end;

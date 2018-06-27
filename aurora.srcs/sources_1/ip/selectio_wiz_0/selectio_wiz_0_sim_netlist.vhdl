-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Mon Jun 25 17:42:56 2018
-- Host        : dhcp-130-148.ucsc.edu running 64-bit Scientific Linux CERN SLC release 6.9 (Carbon)
-- Command     : write_vhdl -force -mode funcsim
--               /home/pixdaq/kdunne/aurora_fmc_one_lane/aurora.srcs/sources_1/ip/selectio_wiz_0/selectio_wiz_0_sim_netlist.vhdl
-- Design      : selectio_wiz_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7vx485tffg1761-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_0_selectio_wiz_0_selectio_wiz is
  port (
    data_in_from_pins : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_in_to_device : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_in : in STD_LOGIC;
    clk_out : out STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_0_selectio_wiz_0_selectio_wiz : entity is 1;
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of selectio_wiz_0_selectio_wiz_0_selectio_wiz : entity is "selectio_wiz_0_selectio_wiz";
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_0_selectio_wiz_0_selectio_wiz : entity is 1;
end selectio_wiz_0_selectio_wiz_0_selectio_wiz;

architecture STRUCTURE of selectio_wiz_0_selectio_wiz_0_selectio_wiz is
  signal clk_in_int : STD_LOGIC;
  signal \^clk_out\ : STD_LOGIC;
  signal data_in_from_pins_int : STD_LOGIC;
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of clkout_buf_inst : label is "PRIMITIVE";
  attribute BOX_TYPE of ibuf_clk_inst : label is "PRIMITIVE";
  attribute CAPACITANCE : string;
  attribute CAPACITANCE of ibuf_clk_inst : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE : string;
  attribute IBUF_DELAY_VALUE of ibuf_clk_inst : label is "0";
  attribute IFD_DELAY_VALUE : string;
  attribute IFD_DELAY_VALUE of ibuf_clk_inst : label is "AUTO";
  attribute BOX_TYPE of \pins[0].fdre_in_inst\ : label is "PRIMITIVE";
  attribute IOB : string;
  attribute IOB of \pins[0].fdre_in_inst\ : label is "TRUE";
  attribute BOX_TYPE of \pins[0].ibuf_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[0].ibuf_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[0].ibuf_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[0].ibuf_inst\ : label is "AUTO";
begin
  clk_out <= \^clk_out\;
clkout_buf_inst: unisim.vcomponents.BUFR
    generic map(
      BUFR_DIVIDE => "BYPASS",
      SIM_DEVICE => "7SERIES"
    )
        port map (
      CE => '1',
      CLR => '0',
      I => clk_in_int,
      O => \^clk_out\
    );
ibuf_clk_inst: unisim.vcomponents.IBUF
     port map (
      I => clk_in,
      O => clk_in_int
    );
\pins[0].fdre_in_inst\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0',
      IS_C_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_R_INVERTED => '0'
    )
        port map (
      C => \^clk_out\,
      CE => '1',
      D => data_in_from_pins_int,
      Q => data_in_to_device(0),
      R => io_reset
    );
\pins[0].ibuf_inst\: unisim.vcomponents.IBUF
     port map (
      I => data_in_from_pins(0),
      O => data_in_from_pins_int
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_0 is
  port (
    data_in_from_pins : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_in_to_device : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_in : in STD_LOGIC;
    clk_out : out STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of selectio_wiz_0 : entity is true;
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_0 : entity is 1;
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_0 : entity is 1;
end selectio_wiz_0;

architecture STRUCTURE of selectio_wiz_0 is
  attribute DEV_W of inst : label is 1;
  attribute SYS_W of inst : label is 1;
begin
inst: entity work.selectio_wiz_0_selectio_wiz_0_selectio_wiz
     port map (
      clk_in => clk_in,
      clk_out => clk_out,
      data_in_from_pins(0) => data_in_from_pins(0),
      data_in_to_device(0) => data_in_to_device(0),
      io_reset => io_reset
    );
end STRUCTURE;

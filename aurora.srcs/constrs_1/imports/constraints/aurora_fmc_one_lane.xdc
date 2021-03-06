################################## Clock Constraints ##########################
create_clock -period 5.000 -waveform {0.000 2.500} [get_ports sysclk_in_p]

#create_generated_clock -name ttc_decoder_i/rclk -source [get_pins pll_i/clk_out1] -divide_by 3 [get_pins ttc_decoder_i/sample_reg/Q]
#create_generated_clock -name phase_sel_i/clk40_i -source [get_pins ttc_decoder_i/sample_reg/Q] -divide_by 4 [get_pins phase_sel_i/clk_out_reg/Q]
#create_generated_clock -source [get_pins phase_sel_i/clk_out_reg/Q] -multiply_by 2 [get_pins cout_i/recovered_clk/inst/clk_out1]
#create_generated_clock -source [get_pins phase_sel_i/clk_out_reg/Q] -multiply_by 2 [get_pins cout_i/recovered_clk/clk_out1]

################################# Location constraints ########################

##### LOCATIONS ARE FOR XILINX KC705 BOARD ONLY

# VC707
#Reset input - GPIO_SW_N
set_property PACKAGE_PIN AR40 [get_ports rst_in]
set_property IOSTANDARD LVCMOS18 [get_ports rst_in]

# VC707
#Sys/Rst Clk - built into board 200MHz
set_property IOSTANDARD LVDS [get_ports sysclk_in_n]
set_property PACKAGE_PIN E18 [get_ports sysclk_in_n]
set_property PACKAGE_PIN E19 [get_ports sysclk_in_p]
set_property IOSTANDARD LVDS [get_ports sysclk_in_p]

# XAPP IOBUF used to route clk640 as Input
# set_property PACKAGE_PIN AD23 [get_ports clk640inout]
# set_property IOSTANDARD LVCMOS25 [get_ports clk640inout]

# # ISERDES Input
# # FMC_LPC_LA06_P
# set_property PACKAGE_PIN AK20 [get_ports data_in_p]
# set_property IOSTANDARD LVDS_25 [get_ports data_in_p]
# # FMC_LPC_LA06_N
# set_property PACKAGE_PIN AK21 [get_ports data_in_n]
# set_property IOSTANDARD LVDS_25 [get_ports data_in_n]
#
# #USER FMC CLOCK
# set_property PACKAGE_PIN AD23 [get_ports USER_SMA_CLOCK_P]
# set_property IOSTANDARD LVDS_25 [get_ports USER_SMA_CLOCK_P]
# set_property PACKAGE_PIN AE24 [get_ports USER_SMA_CLOCK_N]
# set_property IOSTANDARD LVDS_25 [get_ports USER_SMA_CLOCK_N]

# VC707
# ISERDES Input

#FMC_IN_6_P on Hardware (mistake on FMC layout)
# FMC1_HPC_LA33_N
#set_property PACKAGE_PIN T31 [get_ports data_in_n]
#set_property IOSTANDARD LVDS [get_ports data_in_n]
#set_property DIFF_TERM TRUE [get_ports data_in_n]
#FMC_IN_6_N
# FMC1_HPC_LA33_P
#set_property PACKAGE_PIN U31 [get_ports data_in_p]
#set_property IOSTANDARD LVDS [get_ports data_in_p]
#set_property DIFF_TERM TRUE [get_ports data_in_p]

#FMC_IN_5_P on Hardware (mistake on FMC layout)
# FMC1_HPC_LA30_N
set_property IOSTANDARD LVDS [get_ports data_in_n]
set_property DIFF_TERM TRUE [get_ports data_in_n]
#FMC_IN_5_N
# FMC1_HPC_LA30_P
set_property PACKAGE_PIN V31 [get_ports data_in_n]
set_property PACKAGE_PIN V30 [get_ports data_in_p]
set_property IOSTANDARD LVDS [get_ports data_in_p]
set_property DIFF_TERM TRUE [get_ports data_in_p]

# VC707
# OSERDES Input

# FMC_OUT_6_N on Hardware (mistake on FMC layout)
# FMC1_HPC_LA11_P
#set_property PACKAGE_PIN F40 [get_ports data_out_p]
#set_property IOSTANDARD LVDS [get_ports data_out_p]
# FMC_OUT_6_P on Hardware
# FMC1_HPC_LA11_N
#set_property PACKAGE_PIN F41 [get_ports data_out_n]
#set_property IOSTANDARD LVDS [get_ports data_out_n]

# FMC_OUT_5_P on Hardware (mistake on FMC layout)
# FMC1_HPC_LA12_N
set_property IOSTANDARD LVDS [get_ports data_out_n]
# FMC_OUT_5_N on Hardware
# FMC1_HPC_LA12_P
set_property PACKAGE_PIN P40 [get_ports data_out_n]
set_property PACKAGE_PIN R40 [get_ports data_out_p]
set_property IOSTANDARD LVDS [get_ports data_out_p]

# Rx->TX clock internal
#USER SMA CLOCK
#set_property PACKAGE_PIN L25 [get_ports USER_SMA_CLOCK_P]
#set_property IOSTANDARD LVDS_25 [get_ports USER_SMA_CLOCK_P]
#set_property PACKAGE_PIN K25 [get_ports USER_SMA_CLOCK_N]
#set_property IOSTANDARD LVDS_25 [get_ports USER_SMA_CLOCK_N]

#LED Ports
#set_property PACKAGE_PIN F16 [get_ports {led[7]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {led[7]}]
#set_property PACKAGE_PIN E18 [get_ports {led[6]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {led[6]}]
#set_property PACKAGE_PIN G19 [get_ports {led[5]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {led[5]}]
#set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {led[4]}]
#set_property PACKAGE_PIN AB9 [get_ports {led[3]}]
#set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
#set_property PACKAGE_PIN AC9 [get_ports {led[2]}]
#set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]
#set_property PACKAGE_PIN AA8 [get_ports {led[1]}]
#set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
#set_property PACKAGE_PIN AB8 [get_ports {led[0]}]
#set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]

#Emulator Ports
#SMA_GPIO
#set_property IOSTANDARD LVDS_25 [get_ports ttc_data_p]
#set_property PACKAGE_PIN Y24 [get_ports ttc_data_n]
#set_property IOSTANDARD LVDS_25 [get_ports ttc_data_n]


# CHIP OUTPUT
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_n[0]}]
#set_property PACKAGE_PIN L25 [get_ports {cmd_out_p[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_p[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_n[1]}]
#set_property PACKAGE_PIN B28 [get_ports {cmd_out_p[1]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_p[1]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_n[2]}]
#set_property PACKAGE_PIN F21 [get_ports {cmd_out_p[2]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_p[2]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_n[3]}]
#set_property PACKAGE_PIN C19 [get_ports {cmd_out_p[3]}]
#set_property IOSTANDARD LVDS_25 [get_ports {cmd_out_p[3]}]
#set_property PACKAGE_PIN K1  [get_ports {cmd_out_p[0]} ]
#set_property PACKAGE_PIN K2  [get_ports {cmd_out_n[0]} ]
#set_property PACKAGE_PIN C6  [get_ports {cmd_out_p[1]} ]
#set_property PACKAGE_PIN C7  [get_ports {cmd_out_n[1]} ]
#set_property PACKAGE_PIN A2  [get_ports {cmd_out_p[2]} ]
#set_property PACKAGE_PIN A3  [get_ports {cmd_out_n[2]} ]
#set_property PACKAGE_PIN A6  [get_ports {cmd_out_p[3]} ]
#set_property PACKAGE_PIN A7  [get_ports {cmd_out_n[3]} ]

# FMC LPC TRIG_OUT
#set_property PACKAGE_PIN AA20 [get_ports trig_out]
#set_property IOSTANDARD LVCMOS25 [get_ports trig_out]

# DEBUG
#set_property PACKAGE_PIN AB25 [get_ports {debug[0]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {debug[0]}]
#set_property PACKAGE_PIN AA25 [get_ports {debug[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {debug[1]}]
#set_property PACKAGE_PIN AB28 [get_ports {debug[2]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {debug[2]}]
#set_property PACKAGE_PIN AA27 [get_ports {debug[3]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {debug[3]}]

# VC707
#GPIO LCD
#set_property PACKAGE_PIN AT42 [get_ports LCD_DB4_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB4_LS]
#set_property PACKAGE_PIN AR38 [get_ports LCD_DB5_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB5_LS]
#set_property PACKAGE_PIN AR39 [get_ports LCD_DB6_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB6_LS]
#set_property PACKAGE_PIN AN40 [get_ports LCD_DB7_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB7_LS]
#set_property PACKAGE_PIN AT40 [get_ports LCD_E_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_E_LS]
#set_property PACKAGE_PIN AN41 [get_ports LCD_RS_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_RS_LS]
#set_property PACKAGE_PIN AR42 [get_ports LCD_RW_LS]
#set_property IOSTANDARD LVCMOS18 [get_ports LCD_RW_LS]

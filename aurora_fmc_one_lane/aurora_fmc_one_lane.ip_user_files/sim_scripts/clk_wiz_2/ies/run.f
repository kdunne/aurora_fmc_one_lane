-makelib ies_lib/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../../aurora.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2_clk_wiz.v" \
  "../../../../../aurora.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib


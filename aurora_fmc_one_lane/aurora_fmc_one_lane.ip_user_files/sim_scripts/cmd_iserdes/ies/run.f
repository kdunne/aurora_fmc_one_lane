-makelib ies_lib/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../../aurora.srcs/sources_1/ip/cmd_iserdes/cmd_iserdes_selectio_wiz.v" \
  "../../../../../aurora.srcs/sources_1/ip/cmd_iserdes/cmd_iserdes.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib


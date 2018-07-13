vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl" "+incdir+/opt/Xilinx/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl" "+incdir+/opt/Xilinx/Vivado/2017.4/data/xilinx_vip/include" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl" "+incdir+/opt/Xilinx/Vivado/2017.4/data/xilinx_vip/include" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl/verilog" "+incdir+../../../../../aurora.srcs/sources_1/ip/vio_0/hdl" "+incdir+/opt/Xilinx/Vivado/2017.4/data/xilinx_vip/include" \
"../../../../../aurora.srcs/sources_1/ip/vio_0/sim/vio_0.v" \

vlog -work xil_defaultlib \
"glbl.v"


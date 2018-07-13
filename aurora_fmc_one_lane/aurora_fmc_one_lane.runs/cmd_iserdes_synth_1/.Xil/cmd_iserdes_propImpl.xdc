set_property SRC_FILE_INFO {cfile:/home/pixdaq/kdunne/aurora_fmc_one_lane/aurora.srcs/sources_1/ip/cmd_iserdes/cmd_iserdes_ooc.xdc rfile:../../../../aurora.srcs/sources_1/ip/cmd_iserdes/cmd_iserdes_ooc.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:FILTER_OUT_OF_CONTEXT} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in]] 0.1

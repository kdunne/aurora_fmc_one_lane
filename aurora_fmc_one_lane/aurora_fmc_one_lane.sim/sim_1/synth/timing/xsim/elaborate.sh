#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Mon Jul 02 18:05:54 PDT 2018
# SW Build 2086221 on Fri Dec 15 20:54:30 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xelab -wto f2c5c7ccd81747e48a98fd8dfe784899 --incr --debug typical --relax --mt 8 --maxdelay -L xil_defaultlib -L simprims_ver -L secureip --snapshot aurora_top_time_synth -transport_int_delays -pulse_r 0 -pulse_int_r 0 -pulse_e 0 -pulse_int_e 0 xil_defaultlib.aurora_top xil_defaultlib.glbl -log elaborate.log

onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cmd_iserdes_opt

do {wave.do}

view wave
view structure
view signals

do {cmd_iserdes.udo}

run -all

quit -force

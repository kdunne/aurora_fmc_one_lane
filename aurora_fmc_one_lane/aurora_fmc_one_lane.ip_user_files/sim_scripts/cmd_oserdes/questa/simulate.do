onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cmd_oserdes_opt

do {wave.do}

view wave
view structure
view signals

do {cmd_oserdes.udo}

run -all

quit -force

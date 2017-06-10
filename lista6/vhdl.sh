#! /bin/bash
#ghdl -a vhdl_txt.vhd
ghdl -a clock.vhd
ghdl -a simple_tb.vhd

ghdl -e simple_tb
ghdl -r simple_tb --vcd=simple.vcd --stop-time=4000ns

#gtkwave simple.vcd

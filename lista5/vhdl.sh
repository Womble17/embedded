#! /bin/bash

ghdl -a statemachine.vhd
#ghdl -a vhdl_txt.vhd

ghdl -a statemachine_tb.vhd

ghdl -e statemachine_tb
ghdl -r statemachine_tb --vcd=statemachine_tb.vcd --stop-time=10000ns

#gtkwave statemachine_tb.vcd

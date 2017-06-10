#! /bin/bash

ghdl -a *.vhd

ghdl -e simple_tb 
ghdl -r simple_tb --vcd=simple.vcd --stop-time=10000ns

gtkwave simple.vcd 

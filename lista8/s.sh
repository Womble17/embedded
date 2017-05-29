#! /bin/bash
ghdl -a slave.vhd
ghdl -a slave_tb.vhd

ghdl -e slave_tb

ghdl -r slave_tb --vcd=slave_tb.vcd --stop-time=500ns

#! /bin/bash

ghdl -a pack.vhd
ghdl -a crc8.vhd
ghdl -a rom.vhd
ghdl -a crc8_tb.vhd

ghdl -e crc8_tb
ghdl -r crc8_tb --vcd=crc8.vcd --stop-time=10000ns

#gtkwave crc8.vcd

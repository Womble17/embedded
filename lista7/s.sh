#! /bin/bash
ghdl -a encoder.vhd
ghdl -a decoder.vhd

ghdl -a lfsr.vhd
ghdl -a lossy_channel.vhd
ghdl -a lossy_channel_tb.vhd

ghdl -e lossy_channel_tb

ghdl -r lossy_channel_tb --vcd=lossy_channel_tb.vcd --stop-time=5000ns

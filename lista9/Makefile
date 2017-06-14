all:
	ghdl -a pack.vhd
	ghdl -a slave.vhd
	ghdl -a ram.vhd
	ghdl -a MAR.vhd
	ghdl -a slave_tb.vhd

	ghdl -e slave_tb


run:
	ghdl -r slave_tb --vcd=slave_tb.vcd --stop-time=2000ns

clean:
	rm  *.o *.vcd *.cf *_tb

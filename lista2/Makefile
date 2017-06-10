GHDL=ghdl
GHDL_FLAGS=

OBJ_DIR=./obj
SRC_DIR=./src
GTKWAVE_DIR=./gtkwave

all: echo unit unit_tb

analyze: unit_tb
	ghdl -r unit_tb --vcd=${GTKWAVE_DIR}/unit_tb.vcd

echo:
	ghdl -a --workdir=${OBJ_DIR} ${SRC_DIR}/$@.vhdl && \
	ghdl -e --workdir=${OBJ_DIR} $@

unit:
	ghdl -a --workdir=${OBJ_DIR} ${SRC_DIR}/$@.vhdl && \
	ghdl -e --workdir=${OBJ_DIR} $@

unit_tb: unit
	ghdl -a --workdir=${OBJ_DIR} ${SRC_DIR}/$@.vhdl && \
	ghdl -e --workdir=${OBJ_DIR} $@

clean:
	rm -f ${OBJ_DIR}/*
	rm -f ${GTKWAVE_DIR}/*
	rm -f e~*
	rm -f echo
	rm -f unit
	rm -f unit_tb

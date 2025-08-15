# Project setup
PROJ      = tinyqv

# TinyQV program to run - the $PROG.hex file must be in this directory
PROG ?= ledstrip

# Files
FILES = top.v peripherals.v sim_qspi.v bram.v ../../src/tinyQV/cpu/*.v ../../src/tinyQV/peri/uart/*.v ../../src/peri_byte_example.v ../../src/peri_full_example.v ../../src/peri_full_empty.v ../../src/peri_byte_empty.v ../../src/user_peripherals/*.v ../../src/user_peripherals/*.sv ../../src/user_peripherals/*/*.v ../../src/user_peripherals/*/*.sv

.PHONY: clean burn run

$(PROJ).bit: $(FILES)
	# Lint
	#verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-MULTITOP $(FILES)

	# synthesize using Yosys
	yosys -p "read -sv $(FILES) ; synth_ecp5 -top tinyQV_top -json $(PROJ).json" -DECP5 -DPURE_RTL -DSYNTH_FPGA -DPROG_FILE=\"$(PROG).hex\"  > yosys.log
	@grep Warn yosys.log || true
	@grep Error yosys.log || true
	@grep "   Number of cells" yosys.log
	@grep "     TRELLIS_FF" yosys.log | awk '{sum+=$$2;}END{printf("     TRELLIS_FF* %21d\n", sum);}'
	@grep "     LUT" yosys.log
	@echo

	# Place and route using nextpnr
	nextpnr-ecp5 --85k --package CABGA381 --speed 6 --json $(PROJ).json --textcfg $(PROJ)_out.config --lpf ulx3s.lpf > nextpnr.log 2>&1
	@grep Warn nextpnr.log || true
	@grep Error nextpnr.log || true
	@grep "Max frequency.*clk" nextpnr.log | tail -1
	@echo

	# Convert to bitstream using ecppack
	ecppack --svf $(PROJ).svf $(PROJ)_out.config $(PROJ).bit

stats:
	@grep Warn yosys.log | grep -v tri-state || true
	@grep Error yosys.log || true
	@grep Warn nextpnr.log || true
	@grep Error nextpnr.log || true
	@grep "Max frequency.*clk" nextpnr.log | tail -1
	@echo "| Item | Count |"
	@echo "| ---- | ----- |"
	@grep "   Number of cells" yosys.log | awk '{printf("| Cells | %s |\n", $$4);}'
	@grep "     TRELLIS_FF" yosys.log | awk '{sum+=$$2;}END{printf("| TRELLIS_FF* | %d |\n", sum);}'
	@grep "     LUT" yosys.log | awk '{printf("| %s | %s |\n", $$1, $$2);}'
	@grep "     ICESTORM_LC" nextpnr.log | awk '{gsub(/\//, "", $$3);printf("| ICE40 LCs | %s |\n", $$3);}'

prog:
	openFPGALoader -b ulx3s $(PROJ).bit

clean:
	rm $(PROJ)_out.config $(PROJ).svg $(PROJ).bit $(PROJ).json *.log

.PHONY: build sim regress report synth clean

VIVADO := vivado -mode batch

build:
	$(VIVADO) -source scripts/create_project.tcl

sim:
	$(VIVADO) -source scripts/sim.tcl -tclargs $(TEST) $(SEED)

regress:
	$(VIVADO) -source scripts/regress.tcl -tclargs $(SEEDS)

report:
	perl perl/gen_report.pl results/ > report.html
	@echo "Report written to report.html"

synth:
	$(VIVADO) -source scripts/synth.tcl

clean:
	rm -rf build results/*.log results/summary.csv report.html

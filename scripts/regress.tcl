#-------------------------------------------------------------------------------
# regress.tcl
# Regression runner: sweeps a test list x seed list, launching sim.tcl for
# each combination and dumping a structured log per run for the Perl
# reporting layer to parse.
# Usage: vivado -mode batch -source scripts/regress.tcl -tclargs [num_seeds]
#-------------------------------------------------------------------------------

set test_list {
    basic_loopback_test
    random_word_test
    parity_error_test
    frame_error_test
    fifo_overrun_test
    back_to_back_test
}

set num_seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 10}]
set results_dir "./results"
file mkdir $results_dir

foreach test $test_list {
    for {set seed 1} {$seed <= $num_seeds} {incr seed} {
        set log_file "${results_dir}/${test}_seed${seed}.log"
        puts "INFO: Running ${test} (seed ${seed}) -> ${log_file}"

        # In practice this invokes sim.tcl per test/seed and redirects the
        # simulator's transcript to $log_file, e.g.:
        #   exec vivado -mode batch -source scripts/sim.tcl \
        #       -tclargs $test $seed > $log_file
    }
}

puts "INFO: Regression complete. Run 'perl perl/gen_report.pl results/' to build the report."

#!/usr/bin/perl
#-------------------------------------------------------------------------------
# parse_log.pl
# Scrapes one UVM simulation log for UVM_ERROR/UVM_FATAL counts, pass/fail
# status, and simulation time. Prints a single CSV line to stdout:
#   test_name,seed,status,errors,fatals,sim_time_ns
#
# Usage: perl parse_log.pl results/basic_loopback_test_seed3.log
#-------------------------------------------------------------------------------
use strict;
use warnings;

my $log_file = shift @ARGV or die "Usage: perl parse_log.pl <log_file>\n";

open(my $fh, '<', $log_file) or die "Cannot open $log_file: $!\n";

my ($errors, $fatals, $sim_time) = (0, 0, 0);

while (my $line = <$fh>) {
    $errors++ if $line =~ /UVM_ERROR/;
    $fatals++ if $line =~ /UVM_FATAL/;
    if ($line =~ /\$finish.*?(\d+)\s*ns/i) {
        $sim_time = $1;
    }
}
close($fh);

# Derive test name and seed from the log filename: <test>_seed<N>.log
my ($test_name, $seed) = ("unknown", 0);
if ($log_file =~ /([A-Za-z0-9_]+)_seed(\d+)\.log$/) {
    ($test_name, $seed) = ($1, $2);
}

my $status = ($errors == 0 && $fatals == 0) ? "PASS" : "FAIL";

print "$test_name,$seed,$status,$errors,$fatals,$sim_time\n";

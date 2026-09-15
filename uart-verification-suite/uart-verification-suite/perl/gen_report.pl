#!/usr/bin/perl
#-------------------------------------------------------------------------------
# gen_report.pl
# Aggregates parse_log.pl output across all regression logs into a CSV file
# and an HTML pass/fail summary table.
#
# Usage: perl gen_report.pl results/ > report.html
#-------------------------------------------------------------------------------
use strict;
use warnings;
use File::Basename;

my $results_dir = shift @ARGV or die "Usage: perl gen_report.pl <results_dir>\n";

opendir(my $dh, $results_dir) or die "Cannot open $results_dir: $!\n";
my @logs = grep { /\.log$/ } readdir($dh);
closedir($dh);

my @rows;
foreach my $log (sort @logs) {
    my $line = `perl parse_log.pl "$results_dir/$log"`;
    chomp $line;
    push @rows, [split(/,/, $line)] if $line;
}

# --- CSV output ---
open(my $csv_fh, '>', "$results_dir/summary.csv") or die "Cannot write summary.csv: $!\n";
print $csv_fh "test_name,seed,status,errors,fatals,sim_time_ns\n";
print $csv_fh join(",", @$_) . "\n" for @rows;
close($csv_fh);

my $total   = scalar(@rows);
my $passed  = scalar(grep { $_->[2] eq 'PASS' } @rows);
my $failed  = $total - $passed;

# --- HTML output (to stdout) ---
print "<html><head><title>UART Regression Report</title>\n";
print "<style>\n";
print "body { font-family: sans-serif; margin: 2em; }\n";
print "table { border-collapse: collapse; width: 100%; }\n";
print "th, td { border: 1px solid #ccc; padding: 6px 10px; text-align: left; }\n";
print "th { background: #333; color: #fff; }\n";
print ".pass { color: #1a7f37; font-weight: bold; }\n";
print ".fail { color: #cf222e; font-weight: bold; }\n";
print "</style></head><body>\n";

print "<h1>UART Regression Report</h1>\n";
print "<p><b>Total:</b> $total &nbsp; <b>Passed:</b> $passed &nbsp; <b>Failed:</b> $failed</p>\n";

print "<table>\n<tr><th>Test</th><th>Seed</th><th>Status</th><th>Errors</th><th>Fatals</th><th>Sim Time (ns)</th></tr>\n";
foreach my $row (@rows) {
    my ($test, $seed, $status, $errors, $fatals, $sim_time) = @$row;
    my $class = ($status eq 'PASS') ? 'pass' : 'fail';
    print "<tr><td>$test</td><td>$seed</td><td class=\"$class\">$status</td>";
    print "<td>$errors</td><td>$fatals</td><td>$sim_time</td></tr>\n";
}
print "</table>\n</body></html>\n";

#!/usr/bin/perl -w

#Written by Hector Hung, Shouri Chatterjee and Professor Peter Kinget
# Copyright (C) 2004 by the authors and Columbia Integrated Systems
# Laboratory.

# There is no warranty or support and we cannot be held liable in any way.
# Everyone is permitted to copy verbatim copies of the code including
# this message.


#       - Monte Carlo 
use Getopt::Std;
# usage:       '.pl'

#constants:
my $RESULTPATH = "results/";

#for processing
%options=();
$options{t}='Title';
$options{x}='X Label';
$options{y}='Y Label';
$options{f}='out.gnu';
$options{o}='out.ps';

#parse all parameters and override defaults
getopts("t:x:y:f:o:",\%options);

#if not input files specified, show usage
if (!defined $ARGV[0]) {
    print "Usage: MCMakeGraph.pl -f out.gnu -o out.ps -t 'graph title' -x 'x label' -y 'y label [file1] [file2] ... [filen]'\n";
    exit;
}

#show summary
print "Graph  Title:  $options{t}\n";
print "X Axis Label:  $options{x}\n"; 
print "Y Axis Label:  $options{y}\n"; 
print "GnuPlot File:  $options{f}\n"; 
print "Graph   File:  $options{o}\n"; 


#basic gnuplot commands
$PLOTCOMMAND =
    "set terminal postscript\n" .
    "set output \"$options{o}\"\n" .
    "set title  \"$options{t}\"\n" .
    "set xlabel \"$options{x}\"\n" .
    "set ylabel \"$options{y}\"\n" .
    "set logscale x\n" .
    "set data style linespoints\n" .
    "plot ";



#add plot commands for each file
$first =1;
foreach $file (@ARGV) {
    open (IN, $file) or die "cannot open file $file!";
    $_ = <IN>;
    close IN;
    $columns = scalar((@_ = split(/\s+/)));

    #if columns have no avg/ stddev quit
    #min columns = 1 row number, 1 x axis, 2+ data, 1 avg,1 stddev = 6
    next if ($columns < 6 );

    $datacolumn = $columns-1;

    
    if ($first) {

	$PLOTCOMMAND .= "\"$file\" using 2:$datacolumn ";
	$first=0;
    }
    else {

	$PLOTCOMMAND .= ", \"$file\" using 2:$datacolumn ";
    }
}


$PLOTCOMMAND .= "\n";


#generate output gnuplot file
open (OUT, ">$RESULTPATH$options{f}") or die "cannot open outpput file $options{f}";
print OUT "$PLOTCOMMAND";
close OUT;
#run gnuplot
print `gnuplot $RESULTPATH$options{f}`;

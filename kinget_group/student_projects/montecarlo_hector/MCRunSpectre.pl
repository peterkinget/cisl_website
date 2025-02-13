#!/usr/bin/perl -w
#Written by Hector Hung, Shouri Chatterjee and Professor Peter Kinget
# Copyright (C) 2004 by the authors and Columbia Integrated Systems
# Laboratory.

# There is no warranty or support and we cannot be held liable in any way.
# Everyone is permitted to copy verbatim copies of the code including
# this message.


# MCRunSpectre      - Monte Carlo Simulation Runner
#                     runs spectre on all netlists in the results directory

# usage:       'MCRunSpectre.pl'


#constants:
my $RESULTPATH = "results/";

#get list of all netlists in results directory
$files = `ls $RESULTPATH*.scs | xargs`;

#for each netlist, run spectre and output a file in ascii format
foreach $file (split(' ',$files)) {
    print "$file\n";
    $file =~ m/(.*)\.scs/;
    
    print `spectre -format nutascii -raw $1.out $file`;

}

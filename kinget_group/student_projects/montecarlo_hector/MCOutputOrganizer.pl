#!/usr/bin/perl -w

# usage: MCOutputOrganizer.pl

#Written by Hector Hung, Shouri Chatterjee and Professor Peter Kinget
# Copyright (C) 2004 by the authors and Columbia Integrated Systems
# Laboratory.

# There is no warranty or support and we cannot be held liable in any way.
# Everyone is permitted to copy verbatim copies of the code including
# this message.


# MCOutputOrganizer - Monte Carlo Simulation Results Organizer
#                     opens the outputs of multiple simulation runs and
#                     organizes the output values




#constants:
my $RESULTPATH = "results/";
my $EXECNAME = "MCOutputOrganizer.pl";  #filename of the script


#####################
#   INITIALIZATION 
#####################

#get list of all .out output files in results directory
$files = `ls $RESULTPATH*.out | xargs`;
chomp $files;

#gather information about the output, but do not collect data
$files =~ m/^(\S*)[ .*]?/;
open(FILE,$1);


$mode = 0; #This program has 3 modes. 0=ignore lines, 1=variables portion, 2=values portion
@VARIABLES = ();

#array of arrays
#array[0] will be the first var, array[1] second var, array[2] etc.
@ReferenceArray = (); 
#store number of vars (excluding time/freq)
$num_of_vars= 0;
$line = 0;

#first loop will read the first file and copy the time column
while (<FILE>) {
    chomp;
    #ignore lines until 'Variables:... ' line
    if (m/^Variables:/) {
	$mode=1;
    }
    #the following lines will be part of the results
    if (m/Values/) {
	$mode=2;
	
        #now we know all of our parameters so we can initiate the 2d array
        $num_of_vars = scalar(@VARIABLES) -1;
        for ($i=0;$i<$num_of_vars;$i++) {
            $ReferenceArray[$i][0] = "";
        }
	next;
    }
    #parse variable description lines
    if ($mode ==1) {
	s/Variables://;
	s/^\s*//;
	@parts = split(/\t+/);
	print "$parts[0]:$parts[1]\n";
	@VARIABLES[$parts[0]] = $parts[1];
    }

    #parse values
    if ($mode ==2) {
	s/^ //;
	
        @temp = split (/\t+/);
        while (scalar(@temp) < scalar(@VARIABLES+1)) {
            $_ .= <FILE>;
            chomp;
            @temp = split (/\t+/);
        }

        for ($i=0; $i<$num_of_vars; $i++) {
            $temp[1] =~ s/,.*//; #convert imaginary time to real time (drop the 0i)
            $ReferenceArray[$i][$line] = "$temp[0]\t$temp[1]"; #stores column number and time/frequency
        }
        $line++;
    }
}
close FILE;


#for each file, gather info
foreach $file (split(' ',$files)) {
    open(FILE,$file);
    $line=0;
    $mode=0;
    while (<FILE>) {
        chomp;
        #ignore lines until 'Variables:... ' line
        if (m/^Variables:/) {
            $mode=1;
        }
        if (m/Values/) {
            $mode=2;
            next;
        }

        #parse values
        if ($mode ==2) {
            s/^ //;
            @temp = split (/\t+/);
            while (scalar(@temp) < scalar(@VARIABLES+1)) {
            $_ .= <FILE>;
            chomp;
            @temp = split (/\t+/);
            }

            #stores result of (net1, output1) of current output in ReferenceArray[1][1] etc
            for ($i=0; $i<$num_of_vars; $i++) {
                #if result is imaginary, convert to a+bi form
                if ($temp[$i+2] =~ m/(.*),(.*)/) {
                    $real = $1;
                    $imag = $2;
                    if ($imag =~ m/\-/) { $ReferenceArray[$i][$line] .= "\t$real" . "$imag" ."i"; }
                    else { $ReferenceArray[$i][$line] .= "\t$real" ."+" . "$imag" . "i"; }
                }
                else {
                    $ReferenceArray[$i][$line] .= "\t$temp[$i+2]";
                }
            }
            $line++;
        }
    }
}

#add average column and standard deviation column
for ($f=0; $f<scalar(@ReferenceArray); $f++) {
    $ref = $ReferenceArray[$f];
    @ar = @$ref;
    
    for ($j=0; $j<scalar(@ar); $j++) {
        @temp = split(/\s+/, $ar[$j]);

        #if more than one column and not complex
        if ((scalar(@temp) > 3) && !($ar[$j] =~ m/i/)) {
            #ignore value column and x axis column
            shift @temp; shift @temp;
            $average =0;
            $stddev=0;
            $n =0;
            foreach $value (@temp) {
            $average += $value;
            $n++;
            }
            $average /= $n;
            foreach $value (@temp) {
            $stddev += ($value - $average) * ($value - $average);
            }
            $stddev = sqrt($stddev / ($n-1));
            $ReferenceArray[$f][$j] .= "\t" . $average . "\t" . $stddev;
        }
        #unhandled: 1 column of values || complex numbers
        else {
        }
    }
}



#print accumulated data to files
for ($f=0; $f<scalar(@ReferenceArray); $f++) {
    #remove bad ';' char from filename
    $temp = $VARIABLES[$f+1];
    $temp =~ s/\:*//g;

    open (OUTFILE, ">" . $RESULTPATH . "RESULTS$temp");
    $ref = $ReferenceArray[$f];
    @ar = @$ref;
    
    for ($j=0; $j<scalar(@ar); $j++) {
	print OUTFILE "$ar[$j]\n" ;
    }
    close OUTFILE;
}

#!/usr/bin/perl -w
#Written by Hector Hung, Shouri Chatterjee and Professor Peter Kinget
# Copyright (C) 2004 by the authors and Columbia Integrated Systems
# Laboratory.

# There is no warranty or support and we cannot be held liable in any way.
# Everyone is permitted to copy verbatim copies of the code including
# this message.




# MCInputRandomizer - Monte Carlo Simulation Input Randomizer
#                     takes a Spectre netlist as an input, and
#                     generates variations of the netlist

# usage: MCInputRandomizer.pl <input_netlist.scs> <num_outputs> <deviation_file>
#constants:

my $EXECNAME = "MCInputRandomizer.pl";  #filename of the script
my $RESULTPATH = "results/";

#####################
#   INITIALIZATION 
#####################

#check and parse parameters
if (scalar(@ARGV) != 3) {
    print "$EXECNAME: Monte Carlo Simulation Input Randomizer takes a Spectre\n";
    print "                      netlist and generates variations of the netlist\n";
    print "usage: $EXECNAME <input_netlist.scs> <num_outputs> <deviation_file>\n";
    exit;
}
$InputNetlist   = $ARGV[0] || die "$EXECNAME: netlist input file not specified";
$TotalOutputs   = $ARGV[1] || die "$EXECNAME: number of runs not specified";
$DeviationsFile = $ARGV[2] || die "$EXECNAME: deviations file not specified";

#remove previous results, and recreate results directory,
#where the output netlists will be stored
`rm -rf $RESULTPATH`;
mkdir("$RESULTPATH", 0755)
    || die "$EXECNAME: cannot create results directory: $!";

#### Initalize Variables
#my @MOSFETsUsed;       #list of model names of the MOSFETs used (eg. "nch" )
@VoltageNodesUsed = (); #list of voltage nodes used (eg. "v(net1)" )
@CurrentNodesUsed = (); #list of current nodes used (eg. "i(v0)" )
$ResDev = 0;
$ResShift = 0;
$CapDev = 0;
$CapShift = 0;
$IndDev = 0;
$IndShift = 0;
%MOSFETSpecs = ();
%MOSFETSUsedByInput = ();
&processDeviationsFile;
print "save @VoltageNodesUsed @CurrentNodesUsed\n";




############################
#   GENERATE OUTPUT FILES
############################

#generate 'TotalOutputs' number of randomized netlists
for ($OutputNumber=1; $OutputNumber<=$TotalOutputs; $OutputNumber++) {

    #pick appropriate filename format for output files
    @temp = split(/\//, $InputNetlist);  #split filename and path
    @temp = pop(@temp);
    @temp = split(/\./, $temp[0]); #separate filename from file extension
    $OutputFilename = "$RESULTPATH" . $temp[0] . $OutputNumber . "." . $temp[1];


    #open input netlist and new output file stream
    open (IN, $InputNetlist)
	|| die "$EXECNAME: cannot open input file $InputNetlist";
    open (OUT, ">$OutputFilename")
	|| die "$EXECNAME: cannot create output file  $OutputFilename";
    
    
    
    while (<IN>) {

	#combine multiple lines if necessary (handle lines at end with '\')
	while (s/(^.*)\\$/$1/) {
	    chomp;
	    $temp=$_;
	    $lineb =<IN>;
	    chomp $lineb;
	    $_ = $temp . $lineb;
	    s/\s+/ /g;
	    $_.="\n";
	}

	#CAPACITORS
	#modify capacitor value by incorporating shift and deviation
	if (m/(^[ ]*c.* c=[ ]*)([0123456789\.]*)(.*$)/i) {
	    $base = $1;
	    $value = $2;
	    $expo = $3;
	    if ($value =~ m/[0-9\.]/) {
		$value=(&RandomGaussian*$CapDev*$value)+$value*(1+$CapShift);
		print OUT "$base$value$expo\n";
	    } else { print OUT; }
	}
	#RESISTORS
	#modify resistor value by incorporating shift and deviation
	elsif (m/(^[ ]*r.* r=[ ]*)([0123456789\.]*)(.*$)/i) {
	    $base = $1;
	    $value = $2;
	    $expo = $3;
	    if ($value =~ m/[0-9\.]/) {
		$value=(&RandomGaussian*$ResDev*$value)+$value*(1+$ResShift);
		print OUT "$base$value$expo\n";
	    } else { print OUT; }
	}
	#INDUCTORS
	#modify inductor value by incorporating shift and deviation
	elsif (m/(^[ ]*l.* l=[ ]*)([0123456789\.]*)(.*$)/i) {
	    $base = $1;
	    $value = $2;
	    $expo = $3;
	    if ($value =~ m/[0-9\.]/) {
		$value=(&RandomGaussian*$IndDev*$value)+$value*(1+$IndShift);
		print OUT "$base$value$expo\n";
	    } else { print OUT; }
	}
	#MOSFET
	elsif (m/^[ ]*(m\d*) (\(.*\)) (\w*) (.*$)/i) {
	    $mos_number = $1; #spectre fet id
	    $mos_nodes = $2; #fet's nodes
	    $mos_model = $3; #fet's model
	    $mos_stats = $4; #fet's parameters
	    #mark mosfet used if not already used
	    $MOSFETSUsedByInput{$mos_model} = "";
	    
	    $temp = $MOSFETSpecs{$mos_model};
	    #params for this type of fet from the deviations file
	    my %mos_params = %$temp;
 	    #params of this particular instance of the fet
	    my %mos_instance_params;

	    #fill mos_instance_params with values
	    @_= split(/\s+/,$mos_stats);
	    foreach my $params (@_) {
		my @temp = split(/\s*=\s*/,$params);
		
		for (my $i=0; $i < scalar(@temp); $i+=2) {
		    $mos_instance_params{$temp[$i]} = $temp[$i+1];
		}
	    }
	    #UPDATE PARAMETERS OF THE MOSFET INSTANCE
	    #first, update m value if needed
	    if  ($mos_instance_params{"m"} &&  $mos_params{"m"} ) {
		$mos_instance_params{"m"} =
		    (&RandomGaussian*$mos_params{"m"}+1)* $mos_instance_params{"m"};
		}

	    $w = metricToDecimal($mos_instance_params{"w"});
	    $l = metricToDecimal($mos_instance_params{"l"});
	    
	    $gain =$mos_params{"Ab"}/sqrt((2*$w*$l))*&RandomGaussian +$mos_params{"db_b"};
	    $Vt=$mos_params{"avt"}/sqrt((2*$w*$l))*&RandomGaussian +$mos_params{"delvt"};


	    $mos_instance_params{"gain"} = $gain;
	    $mos_instance_params{"Vt"}   = $Vt;
	    	    



	    $mos_line = "I$mos_number $mos_nodes N$mos_model";
	    foreach $param (keys %mos_instance_params) {
		$mos_line .= " $param=$mos_instance_params{$param}";
	    }
	    print OUT "$mos_line\n" ;
	}

	#comment out save line, and print our own save line (print desired nodes)
	elsif (m/(^[ ]*save.*$)/i) {
	    $save = $1;
	    print OUT "//original save line: $save\n"; #copies original save line
	    print OUT "save @VoltageNodesUsed @CurrentNodesUsed\n";
	}


	#if nothing else matched, reproduce line w/o modificiation
	else {
	    print OUT;
	}
    }#end of while (<IN>)
    
    #print subcircuits each mosfet model
    foreach $mod_mos (keys %MOSFETSUsedByInput) {
	&printMOSFETSubcircuit($mod_mos);
    }    


    #close file streams
    close(IN) || die "can't close $InputNetlist";
    close(OUT) || die "can't close $OutputFilename";
}


#convert eg -10m to -0.01
sub metricToDecimal {
    $number = shift;
    $number =~ m/(-?\d*\.?\d*)(\w?)/;
    $value = $1;
    $suffix = $2;
    return $value if ($suffix eq "");
    
    $value *= 10^-12 if ($suffix =~ s/^p$//i);
    $value *= 10^-9  if ($suffix =~ s/^n$//i);
    $value *= 10^-6  if ($suffix =~ s/^u$//i);
    $value *= 10^-3  if ($suffix =~ s/^m$//i);
    $value *= 10^3   if ($suffix =~ s/^k$//i);
    $value *= 10^6   if ($suffix =~ s/^M$//i);
    $value *= 10^9   if ($suffix =~ s/^g$//i);
    $value *= 10^12  if ($suffix =~ s/^t$//i);
    return $value;
}

#open and prase the user-specified devitations file
sub processDeviationsFile {
    print "Starting parsing deviations file $DeviationsFile...\n";
    $ResDev   = 0;
    $ResShift = 0;
    $CapDev   = 0;
    $CapShift = 0;
    $IndDev   = 0;
    $IndShift = 0;
    open (DEV, $DeviationsFile);
    while (defined ($line = <DEV>)) {
	#chomp and remove comments
	chomp($line);
	$line =~ s/\#.*//;
	trim($line);

	#ignore blank lines
	if ($line =~ m/^$/) {
	} 
	#parse capacitor line
	elsif ($line =~ m/^capacitor/i) {
	    @_= split(/\s+/,$line);
	    $CapDev = $_[1];
	    $CapShift = $_[2];
	}
	#parse resistor line
	elsif ($line =~ m/^resistor/i) {
	    @_= split(/\s+/,$line);
	    $ResDev = $_[1];
	    $ResShift = $_[2];
	}
	#parse inductor line
	elsif ($line =~ m/^inductor/i) {
	    @_= split(/\s+/,$line);
	    $IndDev = $_[1];
	    $IndShift = $_[2];
	}
	#parse save line
	elsif ($line =~ m/^save/i) {
	    @_= split(/\s+/,$line);
	    if ($_[1] =~ m/^v/) {
		push(@VoltageNodesUsed,$_[1]);
	    }
	    else {
		push(@CurrentNodesUsed,$_[1]);
	    }
	}
	#parse mosfet lines
	else {
	    #get model, then split each token by = to get param=value sets
	    @_= split(/\s+/,$line);
	    my $mos_model = shift(@_);
	    my %mosparams;

	    foreach my $param (@_) {
		my @temp = split(/\s*=\s*/,$param);
		
		for (my $i=0; $i < scalar(@temp); $i+=2) {
		    $mosparams{$temp[$i]} = $temp[$i+1];
		}
	    }
	    $MOSFETSpecs{$mos_model}  = \%mosparams
	}
    }

    &printDeviationsInfo;
    close (DEV);
    print "Done parsing deviations file $DeviationsFile...\n\n";
}

#print all information parsed from the deviations file
sub printDeviationsInfo {
    print "Voltage Nodes:\t\t@VoltageNodesUsed\n";
    print "Voltage Nodes:\t\t@CurrentNodesUsed\n";
    print "Resistor Deviation:\t$ResDev\t\tShift:\t$ResShift\n";
    print "Capacitor Deviation:\t$CapDev\t\tShift:\t$CapShift\n";
    print "Inductor Deviation:\t$IndDev\t\tShift:\t$IndShift\n";
    foreach $key (sort keys %MOSFETSpecs) {
	$temp = $MOSFETSpecs{$key};
	%hash = %$temp;
	print "MOSFET $key\n";
	foreach $param (sort keys %hash) {
	    print "\t$param:       \t$hash{$param}\n";
	}
	
    }    
}

#remove trailing and leading whitespace off of a string
sub trim {
    my $string = shift || return;
    $string =~ s/\s*$//;
    $string =~ s/^\s*//;
    return $string;
}#sub trim

#generates random numbers with gaussian distribution (av = 0, std = 1)
sub RandomGaussian {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
    # return both if wanted, else just one
}#sub RandomGaussian



#function prints a subcircuit for the passed MOSFET model
sub printMOSFETSubcircuit {
    my $mod_mos = shift || return; #grabs element from @model
    print OUT "subckt N$mod_mos d g s b\n";
    print OUT "	parameters w=1u l=1u ad=1p as=1p pd=1u ps=1u Vt=0 gain=0 // subcircuit parameters\n";
    print OUT "	vsub (g gp) vsource dc=Vt\n";
    print OUT "	vtest (d dp) vsource dc=0\n";
    print OUT "	N$mod_mos (dp gp s b) $mod_mos w=w l=l ad=ad as=as pd=pd ps=ps\n";
    print OUT "	F0 (d s) cccs gain=gain probe=vtest\n";
    print OUT "ends N$mod_mos\n";
}#sub printMOSFETSubcircuit

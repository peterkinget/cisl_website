#!/usr/bin/perl -w

my $is = 'fh00';
my $os = 'fh01';
my $halftable = 0;
my $endtable = 0;

open($is, '<manual_8.txt');
open($os, '>manual_8.raw');
print $os <<EOT;
\@TITLE=\@WPP_TITLE\@ Keywords list\@
\@TSSNAVBAR_IS_4=y\@
\@TSSNAVBAR_URL_L=\@TSS_DIR_PREFIX\@manual_7\@
\@TSSNAVBAR_URL_R=\@TSS_DIR_PREFIX\@manual_9\@


\@INCLUDE utils/box_macros\@
\@INCLUDE utils/h_macros\@
\@D=\$\@
\$Date\$

<DL>
\@H_SECTION("Keywords list", "LINKSNREFS")\@

<DL>
<DD>
<TABLE BORDER=0 CELLSPACING=0>
<TR BGCOLOR="#c0c0c0"><TH WIDTH="80%">\@H_FONT("Directives")\@</TH>
<TH COLSPAN=4>\@H_FONT("Use")\@</TH>
EOT
while (<$is>) {
	chop;
	SW: {
	/^NOTE ([0-9]+): (.*)$/o &&
		do {
			if ($endtable == 0) {
				$endtable = 1;
				print $os <<EOT;
</TABLE>

<DT><P><B>Legenda</B>
<DD><B>R</B> = source files
<DD><B>T</B> = template files
<DD><B>C</B> = configuration files and command line (only for variables through
	the <A HREF="manual_1.html#-D">-D switch</A>).
EOT
			}
			print $os "<DT><A NAME=\"Note$1\"><B>Note $1</B></A>\n<DD>$2\n";
			last SW;
		};
	/^\| ([A-Z_0-9\/\@a-z]+)[\t\s]*\| ([RTC\s]) ([RTC\s]) ([RTC\s]) \|(?: ([0-9]+))?$/o &&
		do {
			print $os "<TR><TD></TD>".
				"<TR BGCOLOR=\"#eeeeee\">\n<TD>\@H_FONT(\"$1\")\@".(defined $5 ?
				" <A HREF=\"#Note$5\"><FONT SIZE=\"-2\">[$5]</FONT></A>" : '').
				'</TD><TD BGCOLOR="#ffffff"></TD><TD>'.
				"\@H_FONT(\"$2\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$3\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$4\")\@&nbsp;"."</TD>\n";
			last SW;
		};
	/^\| ([A-Z_0-9\/\@a-z]+)[\t\s]*\| ([RTC\s]) ([RTC\s]) ([RTC\s]) \| ([RTC\s]) ([RTC\s]) ([RTC\s]) \|(?: ([0-9]+))?$/o &&
		do {
			if ($halftable == 0) {
				$halftable = 1;
				print $os <<EOT;

<TR><TD>&nbsp;</TD>

<TR BGCOLOR="#c0c0c0"><TH>\@H_FONT("Variables/Constants")\@</TH>
<TH COLSPAN=4>\@H_FONT("Assign")\@</TH>
<TH COLSPAN=4>\@H_FONT("Read")\@</TH>
EOT
			}
			print $os "<TR><TD></TD>".
				"<TR BGCOLOR=\"#eeeeee\">\n<TD>\@H_FONT(\"$1\")\@".(defined $8 ?
				" <A HREF=\"#Note$8\"><FONT SIZE=\"-2\">[$8]</FONT></A>" : '').
				'</TD><TD BGCOLOR="#ffffff"></TD><TD>'.
				"\@H_FONT(\"$2\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$3\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$4\")\@&nbsp;".'</TD><TD BGCOLOR="#ffffff"></TD><TD>'.
				"\@H_FONT(\"$5\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$6\")\@&nbsp;".'</TD><TD>'.
				"\@H_FONT(\"$7\")\@&nbsp;"."</TD>\n";
			last SW;
		};
	}
}
print $os "</DL>\n</DL>\n";
close($os);
close($is);

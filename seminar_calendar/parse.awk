#!/usr/bin/awk -f
################################################################################
# parser.awk - parsing script for awkiawki
################################################################################
# Copyright (c) 2002 Oliver Tonnhofer (olt@bogosoft.com)
# See the file `COPYING' for copyright notice.
################################################################################

BEGIN {
	list["ol"] = 0
	list["ul"] = 0
	scriptname = ENVIRON["SCRIPT_NAME"]
	FS = "[ ]"
}

# register blanklines
/^$/ { blankline = 1; next; }

# HTML entities for <, > and &
/[&<>]/ { gsub(/&/, "\\&amp;");	gsub(/</, "\\&lt;"); gsub(/>/, "\\&gt;"); }

# generate links
/[A-Z][a-z]+[A-Z][A-Za-z]*/ ||
/(http|ftp|gopher|mailto|news):/ {
	tmpline = ""
	for(i=1;i<=NF;i++) {
		field = $i 
		# generate HTML img tag for .jpg,.jpeg,.gif,png URLs
		if (field ~ /http:\/\/[^\t]*\.(jpg|jpeg|gif|png)/ \
			&& field !~ /http:\/\/[^\t]*\.(jpg|jpeg|gif|png)''''''/) {
			sub(/http:\/\/[^\t]*\.(jpg|jpeg|gif|png)/, "<img src=\"&\">",field)
		# links for mailto, news and http, ftp and gopher URLs
		}else if (field ~ /((http|ftp|gopher):\/\/|(mailto|news):)[^\t]*/) {
			sub(/((http|ftp|gopher):\/\/|(mailto|news):)[^\t]*[^.,?;:'")\t]/, "<a href=\"&\">&</a>",field)
			# remove mailto: in link description
			sub(/>mailto:/, ">",field)
		# links for awkipages
		}else if (field ~ /(^|[[,.?;:'"(\t])[A-Z][a-z]+[A-Z][A-Za-z]*/) {
			sub(/[A-Z][a-z]+[A-Z][A-Za-z]*/, "<a href=\""scriptname"/&\">&</a>",field)
		}
		tmpline = tmpline field OFS
	}
	# return tmpline to $0 and remove last OFS (whitespace)
	$0 = substr(tmpline, 1, length(tmpline)-1)
}


# remove six single quotes (Wiki''''''Links)
{ gsub(/''''''/,""); }

# emphasize text in single-quotes 
/'''/ { gsub(/'''[^']+'''/, "<strong>&</strong>"); gsub(/'''/,""); }
/''/  { gsub(/''[^']+''/, "<em>&</em>"); gsub(/''/,""); }

#headings
/^-[^-]/ { $0 = "<h2>" substr($0, 2) "</h2>"; close_tags(); print; next; }
/^--[^-]/ { $0 = "<h3>" substr($0, 3) "</h3>"; close_tags(); print; next; }
/^---[^-]/ { $0 = "<h4>" substr($0, 4) "</h4>"; close_tags(); print; next; }

# horizontal line
/^----/ { sub(/^----+/, "<hr>"); blankline = 1; close_tags(); print; next; }

/^\t+[*]/ { close_tags("list"); parse_list("ul", "ol"); print; next;}
/^\t+[1]/ { close_tags("list"); parse_list("ol", "ul"); print; next;}

/^ / { close_tags("pre"); if (pre != 1) { print "<pre>\n" $0; pre = 1 } else { print; } next; }

NR == 1 { print "<p>"; }
{
	close_tags();
	
	# print paragraph when blankline registered
	if (blankline==1) {
		print "<p>";
		blankline=0;
	}

	#print line
	print;

}

END {
	$0 = ""
	close_tags();
}

function close_tags(not) {

	# if list is parsed this line print it
	if (not !~ "list") {
		if (list["ol"] > 0) {
			parse_list("ol", "ul")
		} else if (list["ul"] > 0) {
			parse_list("ul", "ol")
		} 
	}
	# close monospace
	if (not !~ "pre") {
		if (pre == 1) {
			print "</pre>"
			pre = 0
		}
	}

}
function parse_list(this, other) {

	thislist = list[this]
	otherlist = list[other]
	tabcount = 0

	while(/^\t+[1*]/) {
		sub(/^\t/,"")
		tabcount++
	}
	
	# close foreign tags
	if (otherlist > 0) {
		while(otherlist-- > 0) {
			print "</" other ">"
		}
	}

	# if we are needing more tags we open new
	if (thislist < tabcount) {
		while(thislist++ < tabcount) {
			print "<" this ">"
		}
	# if we are needing less tags we close some
	} else if (thislist > tabcount) {
		while(thislist-- != tabcount) {
			print "</" this ">"
		}
	}

	if (tabcount) {
		sub(/^[1*]/,"")
		$0 = "\t<li>" $0
	}
	
	list[other] = 0
	list[this] = tabcount

}

#!/usr/bin/awk -f
################################################################################
# awkiawki - wikiwiki clone written in (n|g|m)awk
################################################################################
# Copyright (c) 2002 Oliver Tonnhofer (olt@bogosoft.com)
# See the file `COPYING' for copyright notice.
################################################################################

BEGIN {
	# change localconf variables to your local settings
	#	img_options: HTML img tag options for picture in page header
	localconf["img_options"] = "src=\"/~kinget/awki.png\" width=\"48\" height=\"39\" align=\"left\""
	#	datadir: directory for raw pagedata; writeable for script
	localconf["datadir"] = "./data/"
	#	parser: parsing script
	localconf["parser"] = "./parse.awk"
	#	default_page: name of the default_page/frontpage
	localconf["default_page"] = "FrontPage"
	#	show_changes: number of changes to show
	localconf["show_changes"] = "10"
	#	max_post: bytes accept by POST requests (to avoid DOS)
	localconf["max_post"] = "100000"
	#	write_protection: regex for write protected files
	#   	e.g.: "*", "PageOne|PageTwo|^.*NonEditable" 
	#		HINT: to edit these protected pages, upload a .htaccess 
	#		      protected awki.cgi script with write_protection = ""
	localconf["write_protection"] = ""

	scriptname = ENVIRON["SCRIPT_NAME"]
	
	# PATH_INFO contains page name
	if (ENVIRON["PATH_INFO"]) {	
		query["page"] = ENVIRON["PATH_INFO"]
		query["show"] = "true"
	}
	
	if (ENVIRON["REQUEST_METHOD"] == "POST") {
        if (ENVIRON["CONTENT_TYPE"] == "application/x-www-form-urlencoded") {
			if (ENVIRON["CONTENT_LENGTH"] < localconf["max_post"])
				bytes = ENVIRON["CONTENT_LENGTH"]
			else
				bytes = localconf["max_post"]
            cmd = "dd ibs=1 count=" bytes " 2>/dev/null"
            cmd | getline query_str
            close (cmd)
		}
		if (ENVIRON["QUERY_STRING"]) 
			query_str = query_str "&" ENVIRON["QUERY_STRING"]
	} else {
		if (ENVIRON["QUERY_STRING"])	
			query_str = ENVIRON["QUERY_STRING"]
	}
	
	n = split(query_str, querys, "&")
	for (i=1; i<=n; i++) {
		split(querys[i], data, "=")
		query[data[1]] = data[2]
	}

	# (IMPORTANT for security!)
	# get first block of alpha characters (see clearstr function below)
	query["page"] = clearstr(query["page"])
	
	
	if (query["page"] == "") query["page"] = localconf["default_page"]
	
	special_pages = "FullSearch|PageList|RecentChanges"
	
	if (localconf["write_protection"] != "")
		non_editable_pages = special_pages"|"localconf["write_protection"]
	else
		non_editable_pages = special_pages

	if (query["page"] ~ "("non_editable_pages")")
		page_editable = 0
	else
		page_editable = 1
	
	query["filename"] = localconf["datadir"] query["page"]
	
	header(query["page"])

	if (query["show"])
		parse(query["filename"])
	else if (query["edit"] && page_editable)
		edit(query["page"], query["filename"])
	else if (query["save"] && query["text"] && page_editable)
		save(query["page"], query["text"], query["filename"])
	else if (query["index"])
		special_index(localconf["datadir"])
	else if (query["changes"])
		special_changes(localconf["datadir"])
	else if(query["search"])
		special_search(clearstr(query["string"]),localconf["datadir"])
	else 
		parse(query["filename"])

	footer(query["page"])
	
}

# print header
function header(page) {
	print "Content-type: text/html\n"
	print "<html>\n<head>\n<title>" page "</title>\n</head>\n<body>"
	print "<img "localconf["img_options"]">"
	print "<h1><a href=\""scriptname"?search=true&amp;string="page"&amp;page=FullSearch\">"page"</a></h1><hr>"
}

# print footer
function footer(page) {
	print "<hr>"
	if (page_editable)
		print "<a href=\""scriptname"?edit=true&amp;page="page"\">Edit "page"</a>"
	print "<a href=\""scriptname"/"localconf["default_page"]"\">"localconf["default_page"]"</a>"
	print "<a href=\""scriptname"?index=true&amp;page=PageList\">PageList</a>"
	print "<a href=\""scriptname"?changes=true&amp;page=RecentChanges\">RecentChanges</a>"
	print "<form action=\""scriptname"\" method=\"GET\" align=\"right\">"
	print "<input type=\"hidden\" name=\"search\" value=\"true\">"
	print "<input type=\"hidden\" name=\"page\" value=\"FullSearch\">"
	print "<input type=\"text\" name=\"string\">"
	print "<input type=\"submit\" value=\"search\">"
	print "</form>\n</body>\n</html>"
}

# send page to parser script
function parse(filename) {
	if (system("[ -f "filename" ]") == 0 ) {
		system(localconf["parser"] " " filename)
	}
}

# print edit form
function edit(page, filename) {
	print "<form action=\""scriptname"?save=true&amp;page="page"\" method=\"POST\">"
	print "<input type=\"submit\" value=\"save\"><br />"
	print "<textarea name=\"text\" rows=25 cols=80>"
	# insert current page into textarea
	while ((getline < filename) >0)
		print
	print "</textarea><br />"
	print "Convert runs of 8 spaces to Tab <input type=\"checkbox\" name=\"convertspaces\">"
	print "</form>"
	print "<small><strong>Emphases:</strong> ''<em>italic</em>''; '''<strong>bold</strong>'''; \
'''''<strong><em>bold italic</em></strong>'''''; ''<em>mixed '''<strong>bold</strong>'''\
and italic</em>''<br>\
<strong>Horizontal Rule:</strong> ----<br><strong>Paragraph:</strong> blank line<br>\
<strong>Headings:</strong> -Title 1 ; --Title 2 ; ---Title 3<br>\
<strong>Preformatted Text:</strong> *space*Text<br>\
<strong>Lists:</strong> tab(s) and one of * bullets; 1 numbered items<br>\
<strong>Links:</strong> JoinCapitalizedWords; url (http, ftp, gopher, mailto, news)</small>"
}

# save page
function save(page, text, filename) {
	dtext = decode(text);
	if (query["convertspaces"] == "on")
		gsub(/        /, "\t", dtext);
	print dtext > filename
	print "saved <a href=\""scriptname"/"page"\">"page"</a>"
}

# list all pages
function special_index(datadir) {
	system("ls -1 " datadir " | " localconf["parser"])
	
}

# list pages with last modified time (sorted by date)
function special_changes(datadir) {
	"date +\"%e %b %R %Z\"" | getline date
	print "<p>current date:", date,"\n<p>"
	system("ls -tlL "datadir" | awk 'BEGIN { print \"<table>\" } $9 ~ /^[A-Z][a-z]+[A-Z][A-Za-z]*/ {filenr++; print \"<tr><td><a href=\\\""scriptname"/\" $9 \"\\\">\", $9, \"</a></td><td>\",$7,$6,$8,\"</td></tr>\"} filenr == " localconf["show_changes"] " { exit } END {print \"</table>\"}'")
}

function special_search(name,datadir) {
	system("grep -il '"name"' "datadir"* | sed -e's/.*\\/\\([^/]*\\)$/\\1/' | " localconf["parser"])
}

# remove non-alpha characters from string
# *** !Important for Security! ***
function clearstr(str) {
	sub(/^[^A-Za-z]*/,"",str)
	sub(/[^A-Za-z]*$/, "" ,str)
	return str
}

# decode urlencoded string
function decode(text) {
	
	split("0 1 2 3 4 5 6 7 8 9 a b c d e f", hex, " ")
	for (i=0; i<16; i++) hextab[hex[i+1]] = i

	# urldecode function from Heiner Steven
	# http://www.shelldorado.com/scripts/cmds/urldecode

	# decode %xx to ASCII char 
	decoded = ""
	i = 1
	len = length(text)
	
	while ( i <= len ) {
	    c = substr (text, i, 1)
		if ( c == "%" ) {
			if ( i+2 <= len ) {
				c1 = tolower(substr(text, i+1, 1))
				c2 = tolower(substr(text, i+2, 1))
				if ( hextab [c1] == "" || hextab [c2] == "" ) {
					print "WARNING: invalid hex encoding: %" c1 c2 | "cat >&2"
				} else {
					code = 0 + hextab [c1] * 16 + hextab [c2] + 0
					c = sprintf ("%c", code)
				i = i + 2
			   }
			} else {
			 print "WARNING: invalid % encoding: " substr (text, i, len - i)
			}
	    } else if ( c == "+" ) {	# special handling: "+" means " "
	    	c = " "
	    }
	    decoded = decoded c
	    ++i
	}
	
	# change linebreaks to \n
	gsub(/\r\n/, "\n", decoded)
	
	# remove last linebreak
	sub(/\n$/,"",decoded)
	
	return decoded
}

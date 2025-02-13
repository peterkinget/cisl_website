#
# GNU Makefile
#
#	author: Marco Lamberto - lm@geocities.com
#	$Revision: 1.14 $
# $Date: 1998/09/23 11:26:51 $
#
SOURCES		= $(wildcard *.raw)
TEMPLATES	= $(wildcard templates/*.tmpl)\
						$(wildcard templates/parags/*.tmpl)\
						$(wildcard templates/tests/*.tmpl)\
						$(wildcard templates/utils/*.tmpl)
DESTS			= $(addprefix ../, $(SOURCES:.raw=.html))
WPP				= ../../wpp

all: $(DESTS) manual_8.raw

../%.html: %.raw $(WPP) config config.common
	@$(WPP) $<

ci:
	ci -l $(SOURCES) $(TEMPLATES) Makefile manual_8.txt manual_8.pl

.depend: manual_8.raw
	@touch .depend

depend dep:
	$(WPP) -d $(SOURCES) >.depend

pgv: all
	$(WPP) -c=config.pgv $(SOURCES)

tss: all
	$(WPP) -c=config.tss $(SOURCES)

dist: all tss pgv

manual_8.raw: manual_8.pl manual_8.txt
	manual_8.pl

include .depend

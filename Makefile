SHELL:=/bin/bash

ASTDIR=/var/lib/asterisk
SOUNDSDIR=/var/lib/asterisk/sounds/en
ORIGDIR=/var/lib/asterisk/sounds/en_US
SALLIDIR=/var/lib/asterisk/sounds/en_Salli
COREFILE=core-sounds-en.txt
CORESIGNATURE=; Core Asterisk Sounds in English


install:
	# make sure corefile exists and isn't a link
	if [ -L "$(SOUNDSDIR)/$(COREFILE)" ]; then \
		echo "Asterisk English sounds alternatives link already in place"; \
		exit; \
	fi
	if [ -d "$(SOUNDSDIR)" -a ! -f "$(SOUNDSDIR)/$(COREFILE)" ]; then \
		echo "Asterisk English sounds prompts file does not exist"; \
		exit; \
	fi
	# check the file for contents
	DETECTEDSIG=$$(head -n1 $(SOUNDSDIR)/$(COREFILE))
	if [ "$${DETECTEDSIG}" != "$(CORESIGNATURE)" ]; then \
		echo "Asterisk English sounds prompts core signature not found"; \
		echo "Found: $${DETECTEDSIG}"; \
		echo "Expected: $(CORESIGNATURE)"; \
		exit; \
	fi
	if [ -d $(ORIGDIR) ]; then \
		echo "Asterisk English sounds alternatives directory already in place"; \
		exit; \
	fi 

rebuild:
	./rebuildsounds.sh

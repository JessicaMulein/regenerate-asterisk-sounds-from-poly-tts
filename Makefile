SHELL:=/bin/bash

# Asterisk base dir
ASTDIR=/var/lib/asterisk
# Directory with original English sounds
SOUNDSDIR=/var/lib/asterisk/sounds/en
# Filename of index file
COREFILE=core-sounds-en.txt
# First line identifier
CORESIGNATURE=; Core Asterisk Sounds in English

# Directory where we'll swap out to
ORIGDIR=/var/lib/asterisk/sounds/en_US
# Directory where we'll build and find Polly-Salli-Mulein library
SALLIDIR=/var/lib/asterisk/sounds/en_Salli

# Change to 1 to ignore a running asterisk installation. DANGER
IGNOREASTERISK=1

#
# Like /etc/alternatives, we'll move every file in the original sound set aside and use links
# If we regenerate our sound set or want to swap in the original, we can do that moderately
# quickly without the database complexity. Requires a drop-in compatible set.
#
# 				Makefile system
#    +--- en_US (ORIGINAL) 	=-=- + 
#
#    +--- en_Salli 		=-=- +-\  links
#    					 -=-=-=--> /var/lib/asterisk/sound/en/*
#    +--- en_Salli2		=-=- +- 


install:
	# check for pre-requisite prompts files needed to generate TTS waveforms
	if [ -d "$(SOUNDSDIR)" -a ! -f "$(SOUNDSDIR)/$(COREFILE)" ]; then \
		echo "Asterisk English sounds prompts file does not exist"; \
		exit; \
	fi
	# make sure corefile exists and isn't a link
	if [ -L "$(SOUNDSDIR)/$(COREFILE)" ]; then \
		echo "Asterisk English sounds alternatives link already in place"; \
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
	# check that we're not already installed
	if [ -d $(ORIGDIR) ]; then \
		echo "Asterisk English sounds alternatives directory already in place"; \
		exit; \
	fi
	# is your asterisk running?
	pgrep safe_asterisk >/dev/null 2>/dev/null
	ASTRUNNING=$?
	if [[ $$ASTRUNNING -eq 0 ]]; then \
		echo "Asterisk is running. This is not a safe operation to perform live on a busy system."; \
		if [ $(IGNOREASTERISK) -eq 1 ]; then \
			echo "IGNORING Due to config"; \
		else \
			exit; \
		fi; \
	fi
	######
	# and GO
	# attempt to make dir
	mkdir -p $(SALLIDIR)

rebuild:
	./rebuildsounds.sh

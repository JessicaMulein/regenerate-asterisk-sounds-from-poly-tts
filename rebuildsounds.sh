#!/bin/bash
stringContain() { [ -z "$1" ] || { [ -z "${2##*$1*}" ] && [ -n "$2" ];};}

NODEBIN=/usr/bin/node
POLLYJS=/opt/aws-nodejs/polly.js
GENPATH=/opt/aws-nodejs/custom-asterisk
OLDIFS=$IFS
SOUNDLIST="/var/lib/asterisk/sounds/en/core-sounds-en.txt"
while IFS= read -r SOUND ; do
	STARTSWITHCOMMENT=0
	TMP=$(echo "${SOUND}" | grep '^\w*;.*$');
	if [ "${TMP}" = "${SOUND}" ]; then
		STARTSWITHCOMMENT=1
		echo "Skipping COMMENT line: ${SOUND}"
		continue
	fi
	HASCOLON=0
	if stringContain ':' "${SOUND}"; then
		HASCOLON=1
	fi
	# the core sounds file is A:B format, the extra file is different apparently.
	if [ $HASCOLON -eq 1 ]; then
		FILENAME=$(echo "$SOUND" | sed -E 's/^(.*):.*$/\1/g' 2>/dev/null)
		TEXT=$(echo "$SOUND" | sed -E 's/^.*:\s*(.*$)/\1/g' 2>/dev/null)
		if [ "${FILENAME}" != "" -a "${TEXT}" != "" ];  then
			REGEX="^<.*>$"
			if [[ "${TEXT}" =~ ${REGEX} ]]; then
				echo "Skipping DIRECTION line: ${SOUND}"
				continue
			fi

			# some have paths eg digits/9
			mkdir -p `dirname "$GENPATH/${FILENAME}"`

			echo "Generating ${FILENAME} with prompt:"
			echo "$TEXT"

			HADERROR=0
			# exec with leading braces, but capture the output
			echo -n "... ["
			RESULT=$(${NODEBIN} ${POLLYJS} --mp3=${GENPATH}/${FILENAME}.mp3 --text="${TEXT}" --wav=${GENPATH}/${FILENAME} 2> /tmp/xerr.tmp)
			if [ $? -eq 0 ]; then
				echo -n "OK"
			else
				echo -n "ERROR"
				HADERROR=1
			fi
			echo "]"
			# enclose brace

			# capture all output
			if [ -f /tmp/xerr.tmp ]; then
				ERROR=$(cat /tmp/xerr.tmp)
			else
				ERROR=""
			fi
			# print output
			echo "${RESULT}${ERROR}"
		
			# if exit code was an error too, stop so we don't continue looping when there's auth issues	
			if [ $HADERROR -eq 1 ]; then
				echo "!!!!!!"
				echo "${ERROR}"
				echo "Error in /tmp/xerr.tmp"
				break
			fi
		fi
	fi
done < $SOUNDLIST
IFS=$OLDIFS

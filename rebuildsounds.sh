#!/bin/bash
stringContain() { [ -z "$1" ] || { [ -z "${2##*$1*}" ] && [ -n "$2" ];};}

DRYRUN=0 # Change 0 to 1 to generate all promptss
GENSQL=1 # Change 0 to 1 to produce an INSERT SQL in MYSQLFILE

NODEBIN=/usr/bin/node
POLLYJS=/opt/aws-nodejs/polly.js
GENPATH=/opt/aws-nodejs/custom-asterisk
MYSQLFILE=/opt/aws-nodejs/custom-asterisk/recordings.sql
MYSQLSOUNDPATH=custom

if [ ${GENSQL} -eq 1 -a -f "${MYSQLFILE}" ]; then
	echo "MySQL file already exists and will be overwritten"
	exit
elif [ ${GENSQL} -eq 1 ]; then
	echo "use asterisk;" > "${MYSQLFILE}"
fi

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
		FILENAME=$(echo "$SOUND" | sed -E 's/^([^:]+):(.*?)/\1/' 2>/dev/null)
		TEXT=$(echo "$SOUND" | sed -E 's/^.+?:\s*(.*$)/\1/g' 2>/dev/null)
		if [ "${FILENAME}" != "" -a "${TEXT}" != "" ];  then
			REGEX="^<.*>$"
			if [[ "${TEXT}" =~ ${REGEX} ]]; then
				echo "Skipping DIRECTION line: ${SOUND}"
				continue
			fi
			REGEX="^\[.*\]$"
			if [[ "${TEXT}" =~ ${REGEX} ]]; then
				echo "Skipping DIRECTION line: ${SOUND}"
				continue
			fi

			# some have paths eg digits/9
			mkdir -p `dirname "$GENPATH/${FILENAME}"`

			if [ -f "${GENPATH}/${FILENAME}.wav" ]; then
				echo "Skipping EXISTING ${FILENAME}"
				continue
			fi

			echo "Generating ${FILENAME} with prompt:"
			echo "$TEXT"

			# exec with leading braces, but capture the output
			echo -n "... ["
			if [ ${DRYRUN} -eq 0 ]; then
				RESULT=$(${NODEBIN} ${POLLYJS} --mp3=${GENPATH}/${FILENAME}.mp3 --text="${TEXT}" --wav=${GENPATH}/${FILENAME} 2> /tmp/xerr.tmp)
			else
				RESULT="DRY RUN SUCCESS"
			fi
			ENDSTATUS=$?
			if [ $ENDSTATUS -ne 0 ]; then
				echo -n "ERROR"
			else
				echo -n "OK"
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
			if [ $ENDSTATUS -ne 0 ]; then
				echo "!!!!!!"
				echo "${ERROR}"
				echo "Error in /tmp/xerr.tmp"
				break
			else
				if [ ${GENSQL} -eq 1 ]; then
					printf -v SANITIZED "%q" "$TEXT"
					echo "INSERT INTO \`recordings\` (\`displayname\`,\`filename\`,\`description\`,\`fcode\`,\`fcode_pass\`) values ('${FILENAME}','${MYSQLSOUNDPATH}/${FILENAME}','${SANITIZED}',0,'en');" >> "${MYSQLFILE}"
				fi

				echo "Generating ulaw file"
				INFILE="${GENPATH}/${FILENAME}.wav"
				OUTFILE="${GENPATH}/${FILENAME}.ulaw"
				if [ ${DRYRUN} -eq 0 ]; then
					asterisk -x "file convert ${INFILE} ${OUTFILE}"
				fi
			fi
		fi
	fi
done < $SOUNDLIST
IFS=$OLDIFS

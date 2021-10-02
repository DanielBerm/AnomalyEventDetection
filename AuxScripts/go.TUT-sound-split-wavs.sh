#!/bin/bash

SRC_AUDIO_DIR="/home/daniel.bermejo/Dani/database/AE/extradata/event/TUT-sound-events-2017-development/audio/street"
DST_AUDIO_DIR="$SRC_AUDIO_DIR/split"

SRC_AUDIO_DIR="."
DST_AUDIO_DIR="./split"


ANOMALY_KEYWORDS="brakes squeaking|baby cry|gun shot|glass break"

DEBUG=1

if [ ! -d $DST_AUDIO_DIR ]
then
    mkdir $DST_AUDIO_DIR
fi

[ "$DEBUG" == "1" ] && echo "Reading audio files from [$SRC_AUDIO_DIR]"
[ "$DEBUG" == "1" ] && echo "Wriring audio files to   [$DST_AUDIO_DIR]"


FILES=`ls $SRC_AUDIO_DIR/*.wav`

declare -a FIELDS
counter=0
for f in $FILES
do
    if [ ! -f $SRC_AUDIO_DIR/$f ]
    then
	echo "File [$SRC_AUDIO_DIR/$f] not found"
    else
	f=`basename $f`
	LAB_FILE="${f%.wav}.ann"
	if [ ! -f $SRC_AUDIO_DIR/$LAB_FILE ]
	then
	    echo "File [$SRC_AUDIO_DIR/$LAB_FILE] not found"
	else
	    echo "Processing [$f] file..."
	    
	    while read -r line
	    do
		# Clean line and detect if anomaly keywords are found
		line=`echo $line|tr -s " "`
		label=`echo $line | egrep "$ANOMALY_KEYWORDS"`
		LAB="anomaly"
		[ "$label" == "" ] && LAB="normal"
		# Get fields in array
		# This works for bash >= 5 readarray -d " " -t FIELDS <<< "$line"
		IFS=' ' read -r -a FIELDS <<< "$line"
		# Generate audio file
		cnt=`printf "%05d" $counter`
		let counter=counter+1
		sox $SRC_AUDIO_DIR/$f $DST_AUDIO_DIR/"$LAB"_id_01_"s$cnt.wav" trim ${FIELDS[2]} =${FIELDS[3]}
		[ "$DEBUG" == "1" ] && echo " -> $line"
		[ "$DEBUG" == "1" ] && echo " -> $LAB"
		[ "$DEBUG" == "1" ] && echo " -> Found $LAB between ${FIELDS[2]} and ${FIELDS[3]}"

	    done < $LAB_FILE
	fi
    fi
    
done


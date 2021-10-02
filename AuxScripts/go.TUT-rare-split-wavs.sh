#!/bin/bash

SRC_AUDIO_DIR="/home/daniel.bermejo/Dani/database/AE/extradata/rare/TUT-rare-sound-events-2017-development/data/mixture_data/devtest/20b255387a2d0cddc0a3dff5014875e7/audio"
DST_AUDIO_DIR="$SRC_AUDIO_DIR/split"
LABEL_DIR="/home/daniel.bermejo/Dani/database/AE/extradata/rare/TUT-rare-sound-events-2017-development/data/mixture_data/devtest/20b255387a2d0cddc0a3dff5014875e7/meta"
#LAB_FILE="$LABEL_DIR/event_list_devtest_babycry.csv"

#SRC_AUDIO_DIR="."
#DST_AUDIO_DIR="split"
#LAB_FILE="event_list_devtest_babycry.csv"

#LAB_FILE=$1
LAB_FILES=`ls $LABEL_DIR/*.csv`

echo "Generating splitted audio in [$DST_AUDIO_DIR]"
for LAB_FILE in $LAB_FILES
do
    echo "Processing for lab file [$LAB_FILE]..."
    ANOMALY_KEYWORDS="brakes squeaking|babycry|gunshot|glassbreak"

    DEBUG=1

    if [ ! -d $DST_AUDIO_DIR ]
    then
	mkdir $DST_AUDIO_DIR
    fi

    BASE_LAB_FILE=`basename $LAB_FILE`
    # Remove line with no labeled segment
    cat $LAB_FILE | grep -P "\t" > $DST_AUDIO_DIR/$BASE_LAB_FILE

    counter=0
    while read -r line
    do
	# It does work from bash 5 ... readarray -d $'\t' -t FIELDS <<< "$line"
	read -r -a FIELDS <<< "$line"

	echo "Read line [$line]..."
	label=`echo $line | egrep "$ANOMALY_KEYWORDS"`
	LAB="anomaly"
	[ "$label" == "" ] && LAB="normal"

	f=$SRC_AUDIO_DIR/${FIELDS[0]}

	echo "Processing file [$f]..."

	if [ ! -f $f ]
	then
	    echo "File [$f] not found"
	else
	    
	    # Generate audio file
	    cnt=`printf "%05d" $counter`
	    let counter=counter+1
	    sox $f $DST_AUDIO_DIR/"$LAB"_id_00_"r$cnt.wav" trim ${FIELDS[1]} =${FIELDS[2]}
	    
	    # Now generate normal segments, assuming only one segment in each file!!!!! CAREFUL, CHECK THIS
	    LAB="normal"
	    cnt=`printf "%05d" $counter`
	    let counter=counter+1
	    sox $f $DST_AUDIO_DIR/"$LAB"_id_00_"r$cnt.wav" trim 0 ${FIELDS[1]}
	    cnt=`printf "%05d" $counter`
	    let counter=counter+1
	    sox $f $DST_AUDIO_DIR/"$LAB"_id_00_"r$cnt.wav" trim ${FIELDS[2]}
	    
	    [ "$label" == "" ] && LAB="normal"
	    [ "$DEBUG" == "1" ] && echo " -> $line"
	    [ "$DEBUG" == "1" ] && echo "    -> Found anomaly event between ${FIELDS[1]} and ${FIELDS[2]}"
	    [ "$DEBUG" == "1" ] && echo "    -> Generated normal events before ${FIELDS[1]} and after ${FIELDS[2]}"
	fi
    done < $DST_AUDIO_DIR/$BASE_LAB_FILE


done

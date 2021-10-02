#!/bin/bash

#LIST=events.list
#LIST=2017Rare.list
LIST=2017Event.list
#LIST=linksdev.list
#LIST=linkseval.list
#LIST=linksaddit.list
DST_DIR=/home/daniel.bermejo/Dani/database/AE/extradata/event


CWD=`pwd`

for f in `cat $LIST`
do
    ZIP_FILE=`basename $f`
    echo "Downloading $ZIP_FILE from $f... "
    wget $f
    mv $ZIP_FILE $DST_DIR
    cd $DST_DIR 
    #zip -s- nameOfSplitZip.zip -O nameOfSplitZip_full.zip #in order to combine an splitted zip (.zip, .z01, z02,...) -0 != -O
    unzip $ZIP_FILE
    rm $ZIP_FILE
    cd -
done


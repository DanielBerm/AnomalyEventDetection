#!/bin/bash


LIST=links.list
DST_DIR=/tmp


CWD=`pwd`

for f in `cat $LIST`
do
#    ZIP_FILE=`basename $f`
    echo "Downloading $ZIP_FILE from $f... "
    wget $f
#    unzip $ZIP_FILE
done


#!/bin/bash

FILE_NAME=files.list  #rarefile.list #soundfile.list 
DST_DIR=concat/


ls *.wav  -1 | sed -e 's/\.wav$//' > $FILE_NAME

echo $FILE_NAME

for f in `cat $FILE_NAME`
do

  
  echo "Editing $f.wav..."
  durat=`soxi -D $f.wav`
  
  echo $durat
  sox $f.wav mono.wav channels 1


  if [ $(echo "$durat<1" | bc) -eq 1 ]
  then

    i=0

    while [ $i -lt 101 ]
    do


      if [ $i -eq 0 ]
      then
      
        sox mono.wav mono.wav tempf.wav

      else

        cp tempf.wav temp.wav
        sox temp.wav mono.wav tempf.wav

      fi

      ((i++))

    done

  else # juntar audios de más de un segundo

    i=0

    while [ $i -lt 10 ]
    do


      if [ $i -eq 0 ]
      then

        sox mono.wav mono.wav tempf.wav

      else

        cp tempf.wav temp.wav
        sox temp.wav mono.wav tempf.wav

      fi

      ((i++))

    done 

  fi

  sox tempf.wav tempF.wav trim 0 =10

  if [ ! -d $DST_DIR ]
  then

    mkdir $DST_DIR

  fi

  mv tempF.wav $DST_DIR/$f.wav
  rm temp.wav tempf.wav mono.wav

done

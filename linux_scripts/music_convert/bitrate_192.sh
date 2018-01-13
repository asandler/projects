#!/bin/bash

find . -name '*.mp3' -exec mp3info {} -p "%F\\t%r\\n" \; | awk -F '\t' '{if (($2 != "Variable") && ($2 > 192)) {print $1} }' | sort > fats

PROCESSED=1
TOTAL=$(wc -l fats | sed 's/ fats//g')

PREFIX=littles
mkdir $PREFIX

while read -r LINE; do
    echo "$PROCESSED/$TOTAL Processing: $LINE"

    DIR=$(dirname "${LINE}" | awk '{print substr($0, 3, length($0) - 1)}')
    mkdir -p "$PREFIX/$DIR"

    #OUTPUT=$(printf "%q" "$PREFIX/$LINE")
    OUTPUT="$PREFIX/$LINE"

    if [ ! -s "$OUTPUT" ]; then
        < /dev/null avconv -v error -i "$LINE" -b 192k "$OUTPUT"
        #echo "$OUTPUT"
    fi

    (( PROCESSED=PROCESSED+1 ))
done < fats

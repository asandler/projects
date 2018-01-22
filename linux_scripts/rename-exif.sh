#!/bin/bash

for i in ./*; do
    NAME=$(exif -t 0x9003 "$i" 2> /dev/null | grep Value | awk -F ": " '{print $2}')

    if [ -n "$NAME" ]; then
        NAME=${NAME// /-}
        SUFFIX=0

        if [ -e "$NAME.jpg" ]; then
            SUFFIX=1
        fi

        while [ -e "$NAME-$SUFFIX.jpg" ]; do
            (( SUFFIX=SUFFIX+1 ))
        done

        if [ $SUFFIX == 0 ]; then
            mv "$i" "$NAME.jpg"
        else
            mv "$i" "$NAME-$SUFFIX.jpg"
        fi
    fi
done

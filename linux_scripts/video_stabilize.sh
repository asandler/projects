SHAKINESS=5

if [ "$2" != "" ]; then
    SHAKINESS=$2
fi

#ffmpeg_vidstab -i $1 -vf vidstabdetect=shakiness="$SHAKINESS":show=1 -f null -
ffmpeg_vidstab -i $1 -vf vidstabtransform=smoothing=30:input="transforms.trf" "stabilized_$1"

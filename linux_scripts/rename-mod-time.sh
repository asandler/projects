for i in `ls Фото*`; do
    NAME=`stat -c '%y' $i | awk -F' ' '{print $1}'`
    SUFFIX=0
    while [ -e $NAME-$SUFFIX.jpg ]; do
        let SUFFIX=$SUFFIX+1
    done
    mv $i $NAME-$SUFFIX.jpg
done

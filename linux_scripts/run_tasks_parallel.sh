#!/bin/bash

mkdir -p run_tasks_"$1".tmp
> "$1".err

> run_tasks_"$1".tmp/pids
cp "$1" run_tasks_"$1".tmp/tasks.tmp
COUNT=0
NPROC=0

while [ -s run_tasks_"$1".tmp/tasks.tmp ]; do
    if [ $NPROC -lt "$2" ]; then
        echo "echo \$\$" > run_tasks_"$1".tmp/worker.$COUNT
        head -n 1 run_tasks_"$1".tmp/tasks.tmp >> run_tasks_"$1".tmp/worker.$COUNT
        chmod +x run_tasks_"$1".tmp/worker.$COUNT

        ./run_tasks_"$1".tmp/worker.$COUNT "${@:3}" 2>> "$1".err | head -n 1 >> run_tasks_"$1".tmp/pids &

        tail -n +2 run_tasks_"$1".tmp/tasks.tmp > run_tasks_"$1".tmp/tasks.tmp.tmp
        mv run_tasks_"$1".tmp/tasks.tmp.tmp run_tasks_"$1".tmp/tasks.tmp
        let COUNT=$COUNT+1

        let NPROC=$NPROC+1
    fi
    > run_tasks_"$1".tmp/pids.tmp
    while read -r i
    do
        kill -0 "$i" 2> /dev/null
        if [ $? -ne 0 ]; then
            echo "$i finished"
            let NPROC=$NPROC-1
        else
            echo "$i" >> run_tasks_"$1".tmp/pids.tmp
        fi
    done < run_tasks_"$1".tmp/pids
    mv run_tasks_"$1".tmp/pids.tmp run_tasks_"$1".tmp/pids
done

while [ -s run_tasks_"$1".tmp/pids ]; do
    > run_tasks_"$1".tmp/pids.tmp
    while read -r i
    do
        kill -0 "$i" 2> /dev/null
        if [ $? -ne 0 ]; then
            echo "$i finished"
            let NPROC=$NPROC-1
        else
            echo "$i" >> run_tasks_"$1".tmp/pids.tmp
        fi
    done < run_tasks_"$1".tmp/pids
    mv run_tasks_"$1".tmp/pids.tmp run_tasks_"$1".tmp/pids
done

rm -r run_tasks_"$1".tmp

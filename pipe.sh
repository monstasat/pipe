#!/bin/bash

pipe=./testpipe
process=$@

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 0
fi

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

$process < $pipe &
pid=$!

echo "Executed process with PID $pid"

# if the script is killed, kill the process
trap "kill $pid 2> /dev/null" EXIT

while kill -0 $pid 2> /dev/null
do
    if read -rsn1; then
        touch ./tmp
        vim -c 'startinsert' ./tmp
        txt=$(<./tmp)
        if [[ "$txt" == 'quit' ]]; then
            break
        fi
        # echo $txt > $pipe
        if [ -s "./tmp" ]; then
            echo $txt > $pipe
        fi
        rm ./tmp
    fi
done 3>$pipe

echo "Pipe script exiting"

exit 0

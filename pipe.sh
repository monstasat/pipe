#!/bin/bash

pipe=./testpipe

process=$1

exec $process &
pid=$!

# if the script is killed, kill the process
trap "kill $pid 2> /dev/null" EXIT

# print executed process pid
echo "the pid of process is $pid"

while kill -0 $pid 2> /dev/null; do
    echo "string" > /proc/$pid/fd/0
    # echo "running"
    echo < /proc/$pid/fd/1
    sleep 1
done

echo "Pipe script exiting"

# disable trap on normal exit
trap - EXIT

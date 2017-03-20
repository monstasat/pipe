#!/bin/bash

PIPE=/tmp/pipe
PROC=$@
TMPFILE="/tmp/tmp.pipe"
: ${EDITOR:="vi"}

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 0
fi

if [[ ! -p $PIPE ]]; then
    mkfifo $PIPE
fi

$PROC < $PIPE &
PID=$!

echo "Executed process with PID $PID"

# if the script is killed, kill the process
trap "kill $PID 2> /dev/null" EXIT

while kill -0 $PID 2> /dev/null
do
    if read -rs -n 1 -p "Options: [e]dit, [q]uit" OPTION; then
	echo ""
   	echo "" > $TMPFILE
	case "$OPTION" in
		q) 
			break
			;;
		e)
        		$EDITOR $TMPFILE
        		if [ -s "$TMPFILE" ]; then
          			cat $TMPFILE > $PIPE
        		fi
			;;
	esac
    fi
done 3>$PIPE

echo "Pipe script exiting"

exit 0

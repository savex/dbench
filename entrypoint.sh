#!/usr/bin/env bash
set -e

function get_var() {
    # if $1 and $2 exists, then we must use $1
    # if there is only $1, then $1 is actually empty and it is a $2 shown as $1
    # if nothing, then just break exit
    if [ -z $2 ]; then
        if [ -z $1 ]; then
            echo "Error in script while setting vars"
            exit 1
        else
            echo $1
        fi
    else
       echo $1
    fi
}

# Global vars
FIO_TEST_SET=$( get_var $FIO_TEST_SET "bulk")
FIO_MOUNTPOINT=$( get_var $FIO_MOUNTPOINT "/tmp")

if [ $FIO_TEST_SET = 'bulk' ]; then
    /fio-bulk.sh
elif [ $FIO_TEST_SET = 'single' ]; then
    /fio-single.sh
elif [ -f $FIO_TEST_SET ]; then
        cat $FIO_TEST_SET | while read opts; do
                params=($(echo "$opts" | tr ',' '\n'))
                echo "### Running Task: ${params[@]}"
                # Map params to vars and run 'single'
                export FIO_READWRITE="${params[0]}"
                export FIO_RWMIXREAD="${params[1]}"
                export FIO_BS="${params[2]}"
                export FIO_IODEPTH="${params[3]}"
                export FIO_SIZE="${params[4]}"
                # start current task
                /fio-single.sh
                # remove lastrun stopper
                rm $FIO_MOUNTPOINT/lastrun
        done
else
    echo "# Unknown test set of '$FIO_TEST_SET'"
    echo "# Nothing to do, set env var FIO_TEST_SET to either 'bulk' or 'single'"
    exit 1
fi

exec "$@"
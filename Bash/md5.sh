#!/bin/bash
# Üllar Seerme
# Script takes two arguments and an optional one: user, group and possibly the
# name of the output file. Script then either displays (third argument omitted)
# or outputs to file the list of files belonging to the user and group with an
# MD5 hash.
export LC_ALL=C

USR=$1
GRP=$2

function main {
    ACT=$(find -maxdepth 1 -type f -user $USR -group $GRP)
    if [ $# == 3 ]; then
        FHD=$3
        for i in $ACT; do
            md5sum $i >> $FHD.txt
        done
    else
        $ACT
        if [ $? == 0 ]; then
            echo "Can't find any files belonging to that user and group."
        else
            echo "Third argument was not given. Output will just be displayed!"
            for i in $ACT; do
                md5sum $i
            done
        fi
    fi
}

main $@
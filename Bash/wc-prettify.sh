#!/bin/bash
# Üllar Seerme
# Script returns the output of the wc command in a more readable format.
export LC_ALL=C

echo -n "Enter the location of the file you wish to know more about: "
read LOC

DO=$(wc "$LOC")
array=( Lines Words Characters Final\ location )
j=0

for i in $DO; do
    echo ${array[$j]}: $i
    let "j += 1"
done
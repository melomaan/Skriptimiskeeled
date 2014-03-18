#!/bin/bash
# Üllar Seerme
# Script takes an input as "rand,fname,lname,rand,rand" (where "rand" is a random number of arbitrary length), searches for a user in getent passwd with fname and lname, and returns an output as "username, fname lname,," into a text file.
export LC_ALL=C

VAR=$1
ACT=$(cat $1 | cut -d "," -f2,3 | sed "s/,/ /")
getent passwd | grep "$ACT" | cut -d ":" -f1,5 | sed "s/:/,/" | sed "s/$/,,/" >> output.txt
#!/bin/bash
# Üllar Seerme
# Script finds all files that belong to a user, except the ones in the /home folder.
export LC_ALL=C
ARG=$1
VAR=$(getent passwd | grep $ARG | cut -d ":" -f6)
find / -path $VAR -prune -o -user $ARG
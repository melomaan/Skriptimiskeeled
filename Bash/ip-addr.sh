#!/bin/bash
# Üllar Seerme
# Script gets a log file as an input and returns all unique IP-addresses for which it was able to resolve the hostnames.
export LC_ALL=C

ARG=$1
ACT=$(grep NEVE "$ARG" | cut -d " " -f1 | sort -u)
for i in $ACT; do
    echo -n "$i - "
    host $i > /dev/null && host $i | cut -d " " -f5 || echo "An error occurred!"
done
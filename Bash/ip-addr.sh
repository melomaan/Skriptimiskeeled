#!/bin/bash
# Üllar Seerme, A21
# Skript saab sisendiks logifaili, kus on IP-aadressid ning tagastab sealt unikaalsed aadressid, mille nimelahendus õnnestus.
export LC_ALL=C

ARG=$1
ACT=$(grep NEVE "$ARG" | cut -d " " -f1 | sort -u)
for i in $ACT; do
    echo -n "$i - "
    host $i > /dev/null && host $i | cut -d " " -f5 || echo "Tekkis viga"
done
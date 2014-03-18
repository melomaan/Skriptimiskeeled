#!/bin/bash
# Üllar Seerme, A21
# Skript tagastab wc utiliidi väljundi viisakamas vormis.
export LC_ALL=C

echo -n "Sisesta faili asukoht, mille kohta soovid infot: "
read LOC

DO=$(wc "$LOC")
array=( Ridu Sõnu Tähemärke Lõplik\ asukoht )
j=0

for i in $DO; do
    echo ${array[$j]}: $i
    let "j += 1"
done
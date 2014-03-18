#!/bin/bash
# Üllar Seerme, A21
# Skript tagastab kõik failid, mis kuuluvad etteantud kasutajale. Välja arvatud need, mis asuvad /home kaustas.
export LC_ALL=C
ARG=$1
VAR=$(getent passwd | grep $ARG | cut -d ":" -f6)
find / -path $VAR -prune -o -user $ARG
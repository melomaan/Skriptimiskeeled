#!/bin/bash
# Üllar Seerme, A21
# 04.03.2014
# Skript võtab sisendiks faili, kus on read vormistatud kui "(arv),Eesnimi,Perenimi,(arv),(arv)" ning kontrollib Eesnimi ja Perenimi väljade järgi, kas getent passwd failis asub kasutaja, kellele vastaksid need andmed. Seejärel tagastatakse andmed formaadis "kasutajanimi, Eesnimi Perenimi,," uude faili, milleks on hetkel output.txt
export LC_ALL=C

VAR=$1
ACT=$(cat $1 | cut -d "," -f2,3 | sed "s/,/ /")
getent passwd | grep "$ACT" | cut -d ":" -f1,5 | sed "s/:/,/" | sed "s/$/,,/" >> output.txt
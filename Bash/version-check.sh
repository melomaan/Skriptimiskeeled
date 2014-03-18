#!/bin/bash
# Üllar Seerme, A21
# Skript kontrollib, mis versioon pakist on paigaldatud. Juhul, kui paigaldatud ei ole, siis tagastab "Installed: (none)".
export LC_ALL=C

ARG=$1
ACT=$(apt-cache policy "$ARG" | grep "Installed: ")
echo $ACT
#!/bin/bash
# Üllar Seerme
# Script checks which version of a package is installed and only displays the bare essentials. If the package isn't installed, then it returns "Installed: (None)".
export LC_ALL=C

ARG=$1
ACT=$(apt-cache policy "$ARG" | grep "Installed: ")
echo $ACT
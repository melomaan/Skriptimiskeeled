#!/bin/bash
# Üllar Seerme 
# Script takes an input file with each line formatted as hh:mm:ss and adds 
# them together outputting in the same format. Shorthand can also be used for 
# formatting. Such as ::1 meaning 1 second, :2: meaning 2 minutes etc.

function count_args {
	if [ $# == 1 ]; then
		arg=$1
	else
		echo "Usage: $0 input"
		exit 1
	fi
}

function sum_lines {
	secsum=0
	minsum=0
	hrssum=0

	# For every line in input file
	for i in $(cat $arg); do
		# Assign second, minute, and hour variables as columns from each line
		sec=$(echo $i | cut -d ":" -f3)
		min=$(echo $i | cut -d ":" -f2)
		hrs=$(echo $i | cut -d ":" -f1)
		# Add base 10 converted seconds, minutes, and hours to their sums.
		# Converting to base 10 conveniently strips leading zeroes
		secsum=$(($secsum + 10#$sec))
		minsum=$(($minsum + 10#$min))
		hrssum=$(($hrssum + 10#$hrs))
	done

	# Convert seconds to minutes
	minsum=$(($minsum + ($secsum / 60)))
	# New sum of seconds equals the remainder
	secsum=$((secsum % 60))
	# Convert minutes to hours
	hrssum=$(($hrssum + ($minsum / 60)))
	# New sum of minutes equals the remainder
	minsum=$(($minsum % 60))

	echo "HH:MM:SS"
	# Pad values to fit double digits
	out=$(printf "%02d:" "$hrssum" "$minsum" "$secsum")
	# Echo output and remove the last character that was added in the previous
	# printf command as a separator
	echo ${out%?}
}

count_args $1
sum_lines $1
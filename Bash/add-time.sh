#!/bin/bash
# Üllar Seerme   
# Script takes an input file with each line formatted as xx:yy:zz
# where each pair denotes hours, minutes, and seconds, respectively, and adds
# them together. Shorthand can also be used for formatting. Such as ::1 meaning
# 1 second, :2: meaning 2 minutes etc.

function count_args {
	if [ $# == 1 ]; then
		arg=$1
	else
		echo "Usage: $0 input"
		exit 1
	fi
}

function sum_lines {
	# Initialize second, hour, and minut sum variables
	sstash=0
	mstash=0
	hstash=0

	# Each following for-loop prints output, cuts the second, minut or hour
	# field, removes the leading zero, and does basic arithmetics to add the
	# values together
	for i in $(cat $arg | cut -d ":" -f3 | sed 's/^0*//'); do
		sstash=$(($sstash + $i))
		rem=$(($sstash / 60))

		if [ $sstash -lt 60 ]; then
			sstash=$sstash
		else
			sstash=$(($sstash - 60))
		fi

		mstash=$(($mstash + $rem))
	done

	for j in $(cat $arg | cut -d ":" -f2 | sed 's/^0*//'); do
		mstash=$(($mstash + $j))
		rem=$(($mstash / 60))

		if [ $mstash -lt 60 ]; then
			mstash=$mstash
		else
			mstash=$(($mstash - 60))
		fi

		hstash=$(($hstash + $rem))
	done

	for k in $(cat $arg | cut -d ":" -f1 | sed 's/^0*//'); do
		hstash=$(($hstash + $k))
		hstash=$(($hstash + $rem))

	done

	# Add leading zeroes to prettify final output
	if [ $sstash -lt 10 ]; then
		sstash=$(echo "0$sstash")
	fi

	if [ $mstash -lt 10 ]; then
		mstash=$(echo "0$mstash")
	fi

	if [ $hstash -lt 10 ]; then
		hstash=$(echo "0$hstash")
	fi

	echo "Total: $hstash:$mstash:$sstash"
}

count_args $1
sum_lines $1
#!/bin/bash

root="/home/casse/Benchs/malardalen/ppc-eabi/gcc-4.4.2"

for b in `ls $root`; do
	file="$root/$b/$b.elf"
	echo "PROCESSING $file"
	if ./comp $file 2> $b.out; then
		true
	else
		#cat $b.out
		echo "FAILED: content in $b.out"
		exit 1
	fi
done

#!/bin/bash

root="/home/casse/Benchs/malardalen/ppc-eabi/gcc-4.4.2"
benchs="
	adpcm
	bsort100
	compress
	crc
	edn
	fac
	fir
	janne_complex
	lcdnum
	ns
	prime
	select
	statemate
	bs
	cnt
	cover
	duff
	expint
	fdct
	fibcall
	insertsort
	jfdctint
	lms
	matmult
	ndes
	nsichneu
	qsort-exam
	recursion
	st
	ud
"

removed="
	fft1
	ludcmp
	minver
	qurt
"

for b in $benchs; do
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

#!/usr/bin/python

import sys
import os
import subprocess
import re

rate_re = re.compile("Rate = ([0-9]+\\.[0-9]+) Mips\n")

print "Performance Analysis\n"
print "BENCH\tRATE (Mips)"
root = "tests_loop"
sim  = "../sim/ppc-sim -s -fast %s"

rate_total = 0
rate_cnt = 0
rate_max = -1
rate_min = -1

for dir in os.listdir(root):
	sys.stdout.flush()
	file = "%s/%s/%s.elf" % (root, dir, dir)
	rate_sum = 0

	for i in xrange(0, 1):
		proc = subprocess.Popen(sim % file, shell=True, stdout=subprocess.PIPE)
		for line in proc.stdout.xreadlines():
			match = rate_re.match(line)
			if match:
				rate_sum = rate_sum + float(match.group(1))

	rate_avg = rate_sum / 1
	print "%s\t%f" % (dir, rate_avg )
	rate_total = rate_total + rate_avg
	rate_cnt = rate_cnt + 1
	if rate_max < 0:
		rate_max = rate_avg
		rate_min = rate_avg
	else:
		if rate_max < rate_avg:
			rate_max = rate_avg
		if rate_min > rate_avg:
			rate_min = rate_avg

print "AVERAGE\t%f" % (rate_total / rate_cnt)
print "MAX\t%f" % (rate_max )
print "MIN\t%f" % (rate_min )


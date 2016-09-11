#!/usr/bin/env python
import sys, math
def check(number):
	i = 2
	root = math.ceil(math.sqrt(number))
	while i <= root:
		if not (number % i):
			return False
		i += 1
	return True
value=sys.argv[1]
file_output=sys.argv[2]
f=open(file_output,'w')
f.write('%s'%check(float(value)))
f.close()


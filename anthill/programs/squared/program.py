#!/usr/bin/env python
import sys
import math
file_output=sys.argv[2]
f=open(file_output,'w')
params = sys.argv[1]
params=params.split(' ')
a=float(params[0])
b=float(params[1])
c=float(params[2])
D=b*b-4*a*c
if a==0:
	f.write('Error a=0')
else:
	if D<0:
		f.write('Not X')
	else:
		x1=(-b+math.sqrt(D))/2/a
		x2=(-b-math.sqrt(D))/2/a
		f.write('%f %f'%(x1,x2))
f.close()
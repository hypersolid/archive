#!/usr/bin/env python
import sys, math
import time
time.sleep(3)
value=sys.argv[1]
file_output=sys.argv[2]
f=open(file_output,'w')
f.write(value)
f.close()


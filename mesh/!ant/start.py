import numpy, math, sys, os
from lib.ansys import run_ansys
from lib.fourier import rfft
from lib.db import DB

params = sys.argv[1]
file_output=sys.argv[2]
if not len(params):
    exit()

f=open(file_output,'w')
stored=params
root = os.path.dirname(os.path.realpath(__file__))
params=params.split(' ')
params = [x.split('=') for x in params]

result = run_ansys(root,'layer', params).replace('\n',';')

if result.strip() != '':
	f.write(stored+' ### ')
	f.write(result)

f.close()

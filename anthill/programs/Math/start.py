import os, re, sys

bin = '"C:\Program Files\Wolfram Research\Mathematica\8.0\math.exe"'
root = os.path.dirname(os.path.realpath(__file__))

source =root+ '/s.nb'
target =root+ '/t.nb'
	
fs = open(source)
s = fs.read()
fs.close()

params = sys.argv[1]
file_output=sys.argv[2]
if not len(params):
    exit()
params=params.split(' ')
s = s.replace('h_placeholder', 'h=%s;'  % params[0])
s = s.replace('h1_placeholder','h1=%s;' % params[1])

s = s.replace('output_placeholder',file_output.replace('\\','\\\\'))
f = open(target, 'w')
f.write(s)
f.close()
os.system('%s -noinit -batchinput < %s' % (bin, target))

from lib.db import DB
from lib.fourier import rfft
import math, random, re
import numpy as np
from lib.draw import *

d = (20, 2)

def parse_data(data):
	data = map(float, data.split('|'))
	return rfft(data, draw=0)[0][1]

def parse_data_raw(data):
	data = map(float, data.split('|'))
	return map(abs,data)

db = DB(dry_run=0)

params = db.execute("select distinct WIDTH, HEIGHT, LHEIGHT, CDEPTH, CSIZE, CPOSITION from td order by WIDTH;")

vectors = []
blank_matrix = []

for n, p in enumerate(params):
	qset = db.execute("select NN, DATA from td where WIDTH='%s' and HEIGHT='%s' and LHEIGHT='%s' and CDEPTH='%s' and CSIZE='%s' and CPOSITION='%s' order by NN;" % p)
	input_vector = [parse_data(s[1]) for s in qset]
	input_vector_raw = np.matrix([parse_data_raw(s[1]) for s in qset])
	output_vector = [p[3],p[4],p[5]]

	# draw change patterns bitmaps 	
	if 0:
		if len(blank_matrix) > 0:
			input_vector_raw = np.matrix(input_vector_raw) / blank_matrix
		else:
			blank_matrix = np.matrix(input_vector_raw)
		
	bitmap(input_vector_raw, (str(n) + ' ' + ' '.join([str(x).replace('.', '_') for x in p])))

	
	vectors.append(input_vector + output_vector)


# Convert array for further ANN processing
split = 0.9

size = len(vectors)
size_train = int(size * split)
size_test = size - size_train

train = open('ann/train.dat', 'w')
test = open('ann/test.dat', 'w')
train.write("%d %d %d\n" % (size_train, d[0], d[1]))
test.write("%d %d %d\n" % (size_test, d[0], d[1]))

print size_train, size_test

random.shuffle(vectors)
for i, v in enumerate(vectors):
	t = ' '.join(map(str, v)) + '\n'
	if i < size_train:
		train.write(t)
	else:
		test.write(t)

train.close()
test.close()

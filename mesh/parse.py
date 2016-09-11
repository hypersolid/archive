from lib.db import DB
import math, random, re
db = DB(dry_run=0)

db.create_table('td', 'WIDTH double, HEIGHT double, LHEIGHT double, CDEPTH double, CSIZE double, CPOSITION double, NN double, DATA longtext')
db.execute('truncate td;')

f = open('data.txt')
data = f.read()

data = data.split('\n')

for p in data:
	if len(p.strip()) > 0:
		# fetch parameters
		kv = {}
		sp = p.split('###')
		for i in sp[0].strip().split(' '):
			si = i.split('=')
			kv[si[0].strip()] = float(si[1].strip())

		# fetch displacements
		data = sp[1].strip().split(';')
		data = map(lambda x: re.split('\s*', x.strip())[0], data[:-1])
		kv['data'] = '|'.join(data)
		if kv['data'] != '':
			db.insert('td', kv)

db.execute('commit')
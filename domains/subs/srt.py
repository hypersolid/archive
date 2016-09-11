import commands, string, random, time, sys, re,os
import operator
import enchant

d = enchant.Dict("en_US")

thedict={}

for root, dirs, files in os.walk('data'):
    for f in files:
        fullpath = os.path.join(root, f)
	print fullpath
	words = map(lambda x: x.replace('\r',''), open(fullpath).readlines())

	count = 0 
	for line in words:
		try:

			parsed =  re.sub('[^a-z\s]','',line.lower()).split(' ')
			last = ''
			for pword in parsed:
				pword = pword.strip()
				if len(pword)>0 and d.check(pword):
					if len(pword) <=3:
						last += ' ' + pword

					else:
						result = (last + ' ' + pword).strip()
						rs = result.split(' ')
						if len(rs)>=2 and len(rs[-1])>=3 and len(rs)<20:
							if thedict.has_key(result):
								thedict[result]+=1
							else:
								thedict[result]=1
						last = pword


		except UnicodeDecodeError:
		    print ".",
		    count+=1
		if count > 200:
			break
	print

outfile = open('list.txt','w')
sorteddict = sorted(thedict.iteritems(), key=operator.itemgetter(1))
print 'Total:',len(sorteddict)
for i in xrange(0,20000):
	#print sorteddict[-i]
	outfile.write(sorteddict[-i][0]+'\n')
	
	


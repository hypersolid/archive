import commands, string, random, time, sys, re

words = map(lambda x: x.lower().strip(), open('dicts/dictPOP.txt').readlines())
words.reverse()
dump = map(lambda x: x.lower().strip(), open('dump03').readlines())

counter = 0

for word in dump:
	if counter % 2500 == 0:
		outfile = open('listDUMP3/'+str(counter)+'.txt','w')
	counter+=1
	for guess in words:
		if re.match('^'+guess+'.+$',word):
			name =  re.sub('^('+guess+')(.+)$',r'\1 \2',word)
#			print name
			outfile.write(name+'\n')
			break
		



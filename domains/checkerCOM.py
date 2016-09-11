import commands, string, random, time, sys, re

#Edit these options to change the program behaviour
###################################################
pause = 0
printtaken = False
doubleword = False
nomatch = 'No match for'
error = 'Maximum Daily connection limit reached'
###################################################

def check(name):
	available = False
	output = commands.getstatusoutput('whois ' + name)
	for line in output[1:]:
		if nomatch in line:
			available = True
		if error in line:
			print error
			sys.exit(0)
	if available:
		print name+' AVAILABLE'
		return True
	time.sleep(pause)
	return False

tlds = ['.com']
words = map(lambda x: x.lower().strip(), open('dicts/dictPOP.txt').readlines())

counter = 0
outfile = None
skip = True

if True:
	for ttf in tlds:
		for randword1 in words:
			for randword2 in words:
				if counter % 10000 == 0:
					outfile = open('listCOM/'+str(counter)+'.txt','w')
				counter+=1
				name =  randword1+randword2+ttf
				#print name
				outfile.write('%s\n'%(name))
				#outfile.write('%s %s\n'%(randword1,randword2))
				if name == 'andnight2.com':
					skip=False
				if not skip:
					print 'Checking %s (%s+%s) ...' % (name, randword1,randword2)
		
					if check(name):
						outfile.write('%s %s\n'%(randword1,randword2))
						



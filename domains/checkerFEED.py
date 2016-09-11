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


words = map(lambda x: x.lower().strip(), open('feedCOM').readlines())
skip = True
outfile = open('rCOM','a')



for randword in words:		
	name = randword.replace(' ','')+'.com'
	if name == 'andsystem.com':
		skip=False
	if not skip:
		print 'Checking %s (%s) ...' % (name, randword)
		if check(name):
			outfile.write('%s\n'%(randword))
			outfile.flush()

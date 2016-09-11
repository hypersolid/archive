import commands, string, random, time, sys, re

#Edit these options to change the program behaviour
###################################################
pause = 2.0
printtaken = False
doubleword = False
nomatch = 'No match for'
error = 'Maximum Daily connection limit reached'
###################################################

def check(word):
	output = commands.getstatusoutput('whois ' + name)
	for line in output[1:]:
		if nomatch in line:
			available = True
		if error in line:
			print error
			sys.exit(0)
	if available:
		print name + ' AVAILABLE'
	time.sleep(pause)


tlds = '.book .download .movie .how .new .auto .bank .home .film .photo .one .house .music .pictures .school .university .top .web .car .email .news .photos .black .city .club .day .hot .red .cars .blog .computer .art .buy .center .college .company .baby .place .property .football .box .cam .chat .codes .media .pics .are .blue .business .services .design .earth .credit .care .casa .homes .land .directory .bar .recipes .restaurant .careers .education .town .build .cards .date .dog .moto .camera .data .direct .audio .food .career .inc .institute .ltd .market .money .pay .cool .country .estate .bike .dance .fish .golf .run .app .contact .digital .band .photography .press .pizza .law .cheap .academy .community .final .global .clothing .energy .apartments .gallery .cafe .capital .coupon .est .ing .autos .bio .farm .camp .christmas .properties .futbol .soccer .coffee .menu .coupons .exchange .science .here .agency .corp .limited .cash .church .horse .racing .ski .click .deal .construction .finance .financial .loan .bet .maison .basketball .cricket .cooking .kitchen .pub .engineering .deals .discount .equipment .cleaning .banque .beauty .events .haus .lease .realestate .baseball .eat .wine .gmbh .casino .eco .fund .loans .bible .bom .dating .immobilien .fishing .motorcycles .rugby .rest .ads .delivery'.split(' ')
words = map(lambda x: x.lower().strip(), open('dicts/dictPOP.txt').readlines())

counter=0

for ttf in tlds:
	for randword in words:
		if counter % 2500 == 0:
			outfile = open('listCOM/'+str(counter)+'B.txt','w')
		counter+=1
		outfile.write(randword+' '+ttf.replace('.','')+'\n')

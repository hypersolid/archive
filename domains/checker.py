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

#tlds = '.co.at .ac .ae .af .com.af .ag .com.ag .ai .com.ai .am .co.am .net.am .co.ao .og.ao .int.ar .net.ar .as .at .ba .co.ba .bb .com.bb .com.bd .be .bf .bg .bh .com.bh .bi .co.bi .com.bi .bj .bm .com.bm .com.bn .bo .com.bo .net.bo .com.br .net.br .org.br .bs .com.bs .bt .com.bt .co.bw .by .com.by .bz .com.bz .net.bz .ca .cc .cd .cf .cg .ch .ci .co.ci .com.ci .co.ck .cl .cm .com.cm .co.cm .cn .com.cn .co .com.co .net.co .cr .co.cr .ac.cr .cv .com.cv .org.cv .cw .com.cw .net.cw .cx .com.cy .net.cy .org.cy .cz .de .com.de .dj .dk .dm .co.dm .do .com.do .org.do .dz .com.dz .ec .com.ec .fin.ec .ee .co.ee .com.ee .com.eg .info.eg .name.eg .es .com.es .eu .fi .com.fj .co.fk .fm .fo .fr .gd .ge .com.ge .edu.ge .gf .gg .co.gg .com.gh .org.gh .gi .com.gi .gl .co.gl .com.gl .gm .gn .net.gn .org.gn .gp .com.gp .gq .gr .com.gr .gs .gt .com.gt .net.gt .com.gu .gy .co.gy .com.gy .hk .com.hk .hm .hn .com.hn .hr .com.hr .ht .com.ht .hu .co.hu .info.hu .co.id .ie .co.il .im .co.im .net.im .in .co.in .io .iq .com.iq .biz.iq .is .it .bz.it .co.it .je .co.je .com.jm .jo .com.jo .jp .co.jp .ne.jp .co.ke .go.ke .info.ke .kg .com.kg .com.kh .ki .com.ki .km .com.km .org.km .kn .com.kn .edu.kn .kr .co.kr .com.kw .net.kw .org.kw .ky .com.ky .kz .com.kz .edu.kz .la .com.lb .lc .co.lc .com.lc .li .lk .com.lk .com.lr .co.ls .lt .lu .lv .com.lv .ly .com.ly .ma .co.ma .mc .md .me .mg .com.mg .mk .com.mk .com.mm .biz.mm .mn .mo .com.mo .mp .mq .mr .ms .com.mt .mu .com.mu .co.mu .com.mv .mw .co.mw .com.mw .com.mx .mx .my .com.my .co.mz .na .com.na .co.na .nc .com.nc .asso.nc .nf .com.nf .ni .com.ni .in.ni .nl .co.nl .com.nl .no .co.no .gs.no .com.np .org.np .nr .com.nr .nu .co.nz .kiwi.nz .co.om .com.om .net.om .pa .com.pa .edu.pa .pe .com.pe .org.pe .pf .com.pf .com.pg .org.pg .ph .com.ph .pk .com.pk .pl .com.pl .atm.pl .pm .pn .co.pn .net.pn .pr .com.pr .biz.pr .ps .com.ps .pt .com.pt .com.py .edu.py .net.py .qa .com.qa .re .ro .co.ro .com.ro .co.rs .rs .ru .com.ru .msk.ru .rw .sa .com.sa .com.sb .sc .com.sc .se .parti.se .press.se .sg .com.sg .sh .si .co.si .ae.si .sk .sl .com.sl .net.sl .sm .sn .art.sn .edu.sn .so .com.so .net.so .sr .st .su .com.sv .sx .co.sz .ac.sz .org.sz .tc .tf .tg .co.th .tj .com.tj .co.tj .tk .tl .com.tl .net.tl .tm .tn .com.tn .to .com.tr .net.tr .org.tr .tt .com.tt .tv .tw .com.tw .co.tz .ua .com.ua .ug .org.ug .co.uk .us .uy .com.uy .net.uy .uz .co.uz .com.uz .vc .com.vc .com.ve .info.ve .vg .co.vi .com.vi .vn .com.vn .vu .wf .ws .com.ws .com.ye .yt .co.za .org.za .co.zm .co.zw'.split(' ')
tlds = '.im .ac .ag .am .at .be .bz .cc .co.in .co.uk .mx .com.mx .de .eu .firm.in .fm .gs .gen.in .hn .in .ind.in .io .la .me .me.uk .mn .net.in .nl .org.in .org.uk .sc .sh .tl .tv .tw .us .vc .ws .co .ca .ch .li .cm .cz .dk .fr .gy .mx .net.nz .org.nz .pl .pm .re .se .so .tf .wf .xxx .yt'.split(' ')
#tlds = '.es .de .it'.split(' ')
#tlds = ['.me','.us']
words = map(lambda x: x.lower().strip(), open('dicts/dictPOP.txt').readlines())

outfile = open('list.txt','w')


for ttf in tlds:
	tt = ttf.replace('.','')
	print '-----------------------------------------'
	print ttf
	print '-----------------------------------------'
	print
	for randword in words:
		available = False
		if re.match('^.*'+tt+'$',randword) and len(randword) - len(tt) >= 2 and len(randword) - len(tt) <= 8:
			name =  re.sub('^(.*)('+tt+')$',r'\1'+ttf,randword)
			print 'Checking %s (%s) ...' % (name, randword)
		
			outfile.write(name+'\n')
			#check(name)
	#outfile.write('\n')

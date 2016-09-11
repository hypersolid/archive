import os
from config import antPath
def time_prof(filename=antPath() + '/output/profile.out',min_value=0.00001,max_row=1000):
    import pstats
    s = pstats.Stats(filename)
    s.sort_stats('time')
    width, list = s.get_print_list([max_row])
    time_ant_cpu=0
    func_ant_cpu=['nt.system','posix.system']
    time_ant_hdd=0
    func_ant_hdd=['readline','readlines','write','open','close']
    time_ant_network=0
    func_ant_network=['socket','request']
    for func in list:
        cc, nc, tt, ct, callers = s.stats[func]
        func_name=func[2]
        if(tt>min_value or ct>min_value):
            for l in func_ant_cpu:
                if func_name.find(l)!=-1:
                    time_ant_cpu+=tt
            for l in func_ant_hdd:
                if func_name.find(l)!=-1:
                    time_ant_hdd+=tt
            for l in func_ant_network:
                if func_name.find(l)!=-1:
                    time_ant_network+=tt
    time_ant_code=s.total_tt-(time_ant_cpu+time_ant_network+time_ant_hdd)
    time_hill_code=0
    time_mysql=0
    check=False
    if os.path.exists(antPath() + '/output/time.prof'):
        time_get=open(antPath() + '/output/time.prof','r').read().split()
        time_hill_code=float(time_get[0])
        time_mysql=float(time_get[1])
        check=bool(time_get[2])
        os.remove(antPath() + '/output/time.prof')
    time_ant_network=time_ant_network-time_hill_code-time_mysql
    return time_ant_cpu,time_ant_network,time_ant_hdd,time_ant_code,time_hill_code,time_mysql,check

def print_prof(filename='profile.prof',min_value=0.00001,max_row=1000):
	import pstats
	s = pstats.Stats(filename)
	s.sort_stats('time')
	print "Total times: %.3f CPU seconds" % s.total_tt
	width, list = s.get_print_list([max_row])
	#print '%8s'%'ncalls','%8s'%'tottime','%8s'%'perncall','%8s'%'cumtime','%8s'%'perccall','%8s'%'function'
	s.print_title()
	for func in list:
		cc, nc, tt, ct, callers = s.stats[func]
		if(tt>min_value or ct>min_value):
			c = str(nc)
			if nc != cc:
				c = c + '/' + str(cc)
			print c.rjust(9),
			print '%8.5f'%tt,
			if nc == 0:
				print ' '*8,
			else:
				print '%8.5f'%(tt/nc),
			print '%8.5f'%(ct),
			if cc == 0:
				print ' '*8,
			else:
				print '%8.5f'%(ct/cc),
			print("%s:%d(%s)"%(func[0].split('\\')[-1],func[1],func[2]))

	# ncalls -    for the number of calls,
	# tottime -   for the total time spent in the given function (and excluding time made in calls to sub-functions) ***
	# perncall -   is the quotient of tottime divided by ncalls
	# cumtime -   is the total time spent in this and all subfunctions (from invocation till exit). This figure is accurate even for recursive functions. **
	# perccall -   is the quotient of cumtime divided by primitive calls
	# filename:lineno(function) -    provides the respective data of each function


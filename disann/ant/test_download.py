#!/usr/bin/env python
from time import *
from lib.uplink import Uplink
from lib.config import Config,logFile,antPath
from lib.registration import login_node
from lib.tasks import *
logFile()
cfg = Config()
uplink = Uplink(cfg)
login_node(uplink, cfg)

NetworkStat=3000
NetworkStop=30000
steps=4

dir_path=antPath()+'/cache/'
if os.path.isfile(dir_path+'config.txt'):
    lines=open(dir_path+'config.txt').readlines()
    for line in lines:
        line=line.replace('\n','').split('#')
        link=line[2]
        path=dir_path+link.split('/')[-1]
        if os.path.isfile(path):
            os.remove(path)
            
#Run download file
path='/rest/files/'+cfg.get('node_id')+'/'+str(NetworkStat)+'/'+str(NetworkStop)+'/'+str(steps)
status, response = uplink.get(path)
if status:
    #Download file config
    path=antPath()+'/cache/config.txt'
    status = uplink.store_file(response, path)
    lines=open(path).readlines()
    n=[]
    size=[]
    t=[]

    #Down load files in config and calculate time
    for line in lines:
        line=line.replace('\n','').split('#')
        n.append(int(line[0]))
        size.append(int(line[1]))
        link=line[2]
        t1=time.time()
        path=antPath()+'/cache/'+link.split('/')[-1]
        status = uplink.store_file(link, path)
        t2=time.time()
        t.append(t2-t1)

    #Plot graph
    print t
    try:
        import matplotlib.pyplot as plt
        fig1 = plt.figure(figsize = (10,8))
        plt.subplots_adjust(hspace=0.4)
        #Plot size
        p1 = plt.subplot(2,1,0)
        plt.plot(n,size, 'b--' )
        lx = plt.xlabel("Network size")
        ly = plt.ylabel("File size")
        ttl = plt.title("")
        grd = plt.grid(True)
        #Plot time
        p1 = plt.subplot(2,1,1)
        plt.plot(n,t, 'b--' )
        lx = plt.xlabel("Network size")
        ly = plt.ylabel("Time")
        ttl = plt.title("")
        grd = plt.grid(True)

        plt.show()
    except ImportError, e:
        print "Cannot make plots. For plotting install matplotlib.\n%s" % e
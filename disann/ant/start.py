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
#Run unit
remove_dir(antPath()+'/cache')
while True:
    run_unit(uplink, cfg)
    #run_unit_time(uplink, cfg)
    #sleep(5)
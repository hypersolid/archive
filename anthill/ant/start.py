#!/usr/bin/env python
from time import *
from lib.uplink import Uplink
from lib.config import Config,logFile
from lib.registration import login_node
from lib.tasks import *
logFile()
cfg = Config()
uplink = Uplink(cfg)
login_node(uplink, cfg)
#Run unit
while True:
    run_unit(uplink, cfg)
    #sleep(2)
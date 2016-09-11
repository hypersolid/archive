import os
from numpy import *

f = open('params.txt', 'w')

count = 0

for WIDTH in [3]:
    for HEIGHT in [.5]:
        for LHEIGHT in [.05]:
            for CDEPTH in [.25]:
                for CSIZE in linspace(.01, .48, 20):
                    for CPOSITION in [1.5]:
                        for NN in xrange(5, 100, 5):
                            call = 'WIDTH=%s HEIGHT=%s LHEIGHT=%s CDEPTH=%s CSIZE=%s CPOSITION=%s NN=%s'
                            call = call % (WIDTH, HEIGHT, LHEIGHT, CDEPTH, CSIZE, CPOSITION, NN)
                            f.write(call + '\n')
                            count += 1
                            print call
f.close()

os.system('cd /home/sol/development/mesh/!ant')
os.system('/usr/bin/zip -r program.zip *')

print 'Total:', count

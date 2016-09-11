import  socket, multiprocessing, sys, timeit
import logging, config

def register_node(uplink, cfg):
    addr = socket.gethostbyaddr(socket.gethostname())
    power = benchmark()
    cpu_number = multiprocessing.cpu_count()
    platform = sys.platform
    status, response = uplink.post("/rest/register", {'user_id':cfg.get('user_id'),
                                                     'power':power,
                                                     'cpu_number':cpu_number,
                                                     'platform':platform,
                                                     'hostname':addr[0],
                                                     'ip':addr[2][0]
                                                     })
    if status:
        cfg.set('node_id', response)
        print "> Node was successfully registered"
    else:
        print "> Registration error ...."
    
def login_node(uplink, cfg):
    if not cfg.get('node_id'):
        register_node(uplink, cfg)
    else:
        print '> This machine is known as node #' + cfg.get('node_id') + '.'
        logger = logging.getLogger("logfile")
        logger.info(config.fileInfo() + ' - ' + '> This machine is known as node #' + cfg.get('node_id') + '.')
    
def benchmark():
    s1 = '''
    for i in xrange(1,1000):
        for j in xrange(1,1000):
            r1 = i + j
            r2 = i - j
            r3 = i * j
            r4 = i / j
    '''
    s2 = 'pass'
    t1 = timeit.Timer(stmt=s1)
    t2 = timeit.Timer(stmt=s2)
    times = 4
    r1 = t1.timeit(times)
    r2 = t2.timeit(times)
    return  (r1 - r2) / 4 / times

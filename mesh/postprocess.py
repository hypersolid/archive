from pyfann import libfann
from random import random,shuffle

def load_network(path):
    net = libfann.neural_net()
    net.create_from_file(path)
    return net

def validate_network(net, path, params):
    f = open(path)
    lines = f.read().split('\n')
    f.close()
    
    input_length=int(lines[0].split(' ')[1])
    
    deviations = []
    for line in lines[1:]:
        if len(line):
            pattern = line.split(' ')
            format = lambda x : "%.2f" % float(x)
            syntetic = net.run(map(float, pattern[:input_length]))
            real = map(float, pattern[input_length:])
                
            percent = [abs(syntetic[i] - real[i]) for i in xrange(len(syntetic))]
            deviations.append(percent)

            total_percent = sum(percent) / len(percent) * 100
                
            print map(format, syntetic), 'vs', map(format, real), 'error %.1f%%' % total_percent
        
        
    count = len(deviations)
    dim = len(deviations[0])
        
    ordered = [[] for i in xrange(dim)]
    for i in xrange(dim):
        for j in xrange(count):
            ordered[i].append(deviations[j][i])
        
    print '='*16,'Absolute Error ' ,'='*16
    for i in xrange(dim):
        print '%.2f /'%(sum(ordered[i])/count*100),
    print
        
# Start
net = load_network("ann/the.net")
validate_network(net, "ann/test.dat",['position'])
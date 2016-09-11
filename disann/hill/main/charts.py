from hill.main.models import *
from django.shortcuts import *

def plot_profile(request,id):
    import pylab
    node_id=int(id)
    if node_id > 0:
        n = Node.objects.get(id=node_id)
        time_cpu = n.time_cpu
        time_network = n.time_network
        time_antcode = n.time_antcode
        time_hillcode = n.time_hillcode
        time_mysql = n.time_mysql
    else:
        n = Node.objects.all().aggregate(time_cpu=Sum('time_cpu'), time_network=Sum('time_network'), time_antcode=Sum('time_antcode'), time_mysql=Sum('time_mysql'), time_hillcode=Sum('time_hillcode'))
        time_cpu = n['time_cpu']
        time_network = n['time_network']
        time_antcode = n['time_antcode']
        time_hillcode = n['time_hillcode']
        time_mysql = n['time_mysql']
    pylab.figure(figsize=(8, 8))
    #pylab.rcParams[]
    pylab.axes([0.1, 0.1, 0.8, 0.8])
    pylab.rcParams['font.size'] = 12.0
    pylab.rcParams['axes.titlesize'] = 16.0
    pylab.rcParams['xtick.labelsize'] = 11.0
    pylab.rcParams['legend.fontsize'] = 11.0
    labels = 'Ant: Cpu time',  'Hill: code time', 'Network time', 'Mysql time', 'Ant: code time'
    fracs = [time_cpu, time_hillcode, time_network, time_mysql, time_antcode]
    explode = (0, 0, 0, 0, 0)
    colors=('w','w','w','w','w')
    patches = pylab.pie(fracs,colors=colors, explode=explode, labels=labels, autopct='%1.1f%%', shadow=0)
    pylab.legend([labels[k] + ' ' + str(round(v, 2)) + ' s' for k, v in enumerate(fracs)], loc=(-0.08, -.08))
    if node_id == 0:
        pylab.title('Time for all nodes')
    else:
        pylab.title('Time for node number %s' % str(node_id))
    pylab.show()
    return redirect('/home')

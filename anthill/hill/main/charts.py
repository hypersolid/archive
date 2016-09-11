import matplotlib.pyplot as plt
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

def plot_task_time_avg(request,id):
    try:
        temp_unit = Unit_completed.objects.filter(task=id).order_by('id')
        t1 = temp_unit.count()
        if t1 > 0:
            color_array = {0: (0.0, 0.5, 0.0), 1: (0.15, 0, 0.75), 2: (1.0, 0.0, 0.0), 3: (1.0, 0.0, 1.0), 4: (0.75, 0.75, 0), 5: (0.75, 0.2, 0), 6: (0.2, 0.75, 0), 7: (0.0, 0.0, 1.0), 8: (0.0, 0.75, 0.75), 9: (0.0, 0.0, 0.0)}
            #Plot with value of unit
            x1 = []
            y1 = []
            y2=[]
            #Plot with avg value of unit
            tmp_x1 = 0
            tmp_y1 = 0
            for unit in temp_unit:
                tmp_x1 += 1
                x1.append(tmp_x1)
                tmp_y1 += unit.time_total()
                y1.append(tmp_y1 / tmp_x1)
                y2.append(unit.time_total())

            colors1 = color_array[2]
            colors2 = color_array[7]
            plt.clf()
            plt.figure(1)
            plt.grid(True)
            #set title
            plt.title('AVERAGE TIME')
            plt.figure(1).canvas.set_window_title('ANTHILL CHARTS')
            #create label
            plt.xlabel('Total units')
            plt.ylabel('Time')
            #change size figure
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.axis('on')
            plt.plot(x1, y1, color=colors1, lw=1)
            plt.plot(x1, y2, color=colors2, lw=1)
            plt.show()
    except :
        print "Cannot make plots. For plotting install matplotlib.\n"
        return redirect('/home')
    return redirect('/home')

def plot_node_time_update(request,id):
    try:
        temp_unit = Unit.objects.filter(completed=True, node=id).order_by('received_at')[0:27]
        t1=10
        c=temp_unit.count()
        if c-t1>0:
            temp_unit=temp_unit[c-t1:c]
        else:
            t1=c

        if t1 > 0:
            #Plot with value of unit
            y1 = []
            l = []
            #Plot with avg value of unit
            for unit in temp_unit:
                time_received_at = time.localtime(unit.received_at)
                #l.append(time.strftime("%d-%m-%Y %H:%M:%S",time_received_at))
                l.append(time.strftime("%H:%M:%S",time_received_at))
                y1.append(unit.received_at-unit.submitted_at)
            import matplotlib.pyplot as plt
            import numpy as np
            x1 = np.arange(1,t1+1)
            plt.figure(figsize = (10,8))
            width = 0.35       # the width of the bars
            ax = plt.subplot(1,1,1)
            plt.text(4.5,0.92,'Date/time of units in node')
            ax.set_position([0.1,0.1,0.8,0.7])
            rects = ax.bar(x1, y1, width, color='r')
            # add some
            ax.set_ylabel('Date/time')
            ax.set_xticks(x1+width/2)
            ax.set_xticklabels(x1)
            def autolabel(rects,label):
                # attach some text labels
                i=0
                for rect in rects:
                    height = rect.get_height()
                    ax.text(rect.get_x()+rect.get_width()/2., 1.05*height, '%s'%label[i],
                            ha='center', va='bottom')
                    i+=1
            autolabel(rects,l)
            plt.show()
    except :
        print "Cannot make plots. For plotting install matplotlib.\n"
        return redirect('/home')
    return redirect('/home')

def plot_node_error(request,id):
    try:
        temp_node = Node.objects.get(id=id)
        #Plot with value of unit
        x1=[1]
        y1 = [temp_node.bad]
        import matplotlib.pyplot as plt
        plt.figure(figsize = (8,6))
        ax = plt.subplot(1,1,1)
        plt.subplots_adjust(left=0.115, right=0.9,top=0.7,bottom=0.4)
        ax.set_title('Error of node')
        ax.set_ylabel('Error')
        ax.set_yticks(y1)
        ax.set_yticklabels('')
        ax.set_xticks(y1)
        ax.set_xticklabels(y1)
        ax.barh(x1, y1, align='center', height=0.1, color='m')
        plt.show()
    except :
        print "Cannot make plots. For plotting install matplotlib.\n"
        return redirect('/home')
    return redirect('/home')



















#===========================================================================================
#When plot all
#===========================================================================================

def plot_node_time_update1(request,id):
    #try:
        temp_unit = Unit.objects.filter(completed=True, node=id).order_by('received_at')[0:27]
        t1=10
        c=temp_unit.count()
        if c-t1>0:
            temp_unit=temp_unit[c-t1:c]
        else:
            t1=c

        t1=temp_unit.count()
        if t1 > 0:
            color_array = {0: (0.0, 0.5, 0.0), 1: (0.15, 0, 0.75), 2: (1.0, 0.0, 0.0), 3: (1.0, 0.0, 1.0), 4: (0.75, 0.75, 0), 5: (0.75, 0.2, 0), 6: (0.2, 0.75, 0), 7: (0.0, 0.0, 1.0), 8: (0.0, 0.75, 0.75), 9: (0.0, 0.0, 0.0)}
            #Plot with value of unit
            x1 = []
            y1 = []
            y2 = []
            y3 = []
            l1 = []
            l2 = []

            #Plot with avg value of unit
            tmp_x1 = 0
            for unit in temp_unit:
                tmp_x1+=1
                x1.append(tmp_x1)

                time_submitted_at = time.localtime(unit.submitted_at)
                #l1.append(time.strftime("%d-%m-%Y %H:%M:%S",time_submitted_at))
                l1.append(time.strftime("%H:%M:%S",time_submitted_at))

                time_received_at = time.localtime(unit.received_at)
                #l2.append(time.strftime("%d-%m-%Y %H:%M:%S",time_received_at))
                l2.append(time.strftime("%H:%M:%S",time_received_at))
                #y1.append(unit.submitted_at)
                #y2.append(unit.received_at)
                if tmp_x1==1:
                    y1.append(temp_unit[tmp_x1-1].received_at-temp_unit[tmp_x1-1].submitted_at)
                    y2.append(temp_unit[tmp_x1-1].received_at-temp_unit[tmp_x1-1].submitted_at)
                else:
                    time_y1=temp_unit[tmp_x1-1].submitted_at-temp_unit[tmp_x1-2].submitted_at
                    y1.append(time_y1)
                    y2.append(time_y1+temp_unit[tmp_x1-1].received_at-temp_unit[tmp_x1-1].submitted_at)
                y3.append(temp_unit[tmp_x1-1].received_at-temp_unit[tmp_x1-1].submitted_at)
            colors1 = color_array[int(id) % 7]
            colors2 = color_array[(int(id)+1) % 7]
            colors3 = color_array[(int(id)+2) % 7]

            import matplotlib.pyplot as plt
            import numpy as np
            plt.figure(figsize = (10,8))
            plt.subplots_adjust(hspace=0.4)

            N = tmp_x1
            ind = np.arange(1,N+1)  # the x locations for the groups
            width = 0.35       # the width of the bars
            ax = plt.subplot(2,1,1)
            rects1 = ax.bar(ind, y1, width, color=colors1)
            rects2 = ax.bar(ind+width, y2, width, color=colors2)

            # add some
            ax.set_ylabel('Date/time')
            ax.set_title('Date/time of units in node')
            ax.set_xticks(ind+width)
            ax.set_xticklabels( ind )

            ax.legend( (rects1[0], rects2[0]), ('Submitted', 'Received'),loc=(0.01, .72) )

            def autolabel(rects,label):
                # attach some text labels
                i=-1
                for rect in rects:
                    i+=1
                    height = rect.get_height()
                    ax.text(rect.get_x()+rect.get_width()/2., 1.05*height, '%s'%label[i],
                            ha='center', va='bottom')

            #autolabel(rects1,l1)
            autolabel(rects2,l2)

            #Plot sub 2
            plt.subplot(2,1,2)
            plt.subplot(2,1,2)
            plt.plot(x1, y3, color=colors3, lw=1)
            plt.xlabel("X values")
            plt.ylabel("Total time")
            plt.title("Graph total time of units in node")
            plt.grid(True)

            plt.show()
    #except :
    #    print "Cannot make plots. For plotting install matplotlib.\n"
    #    return redirect('/home')
        return redirect('/home')

def plot_avg_old(request,task):
    try:
        max_x = task.unit_set.count()
        temp_unit = Unit.objects.filter(completed=True, task=task.id).order_by('id')
        t1 = temp_unit.count()
        if t1 > 0:
            color_array = {0: (0.0, 0.5, 0.0), 1: (0.15, 0, 0.75), 2: (1.0, 0.0, 0.0), 3: (1.0, 0.0, 1.0), 4: (0.75, 0.75, 0), 5: (0.75, 0.2, 0), 6: (0.2, 0.75, 0), 7: (0.0, 0.0, 1.0), 8: (0.0, 0.75, 0.75), 9: (0.0, 0.0, 0.0)}
            #Plot with value of unit
            x1 = []
            y1 = []
            y2 = []
            y3 = []
            #Plot with avg value of unit
            tmp_x1 = 0
            tmp_y1 = 0
            tmp_y2 = 0
            tmp_y3 = 0
            for unit in temp_unit:
                tmp_x1 += 1
                x1.append(tmp_x1)
                tmp_y1 += unit.time_total()
                tmp_y2 += unit.time_cpu()
                tmp_y3 += unit.time_network()
                y1.append(tmp_y1 / tmp_x1)
                y2.append(tmp_y2 / tmp_x1)
                y3.append(tmp_y3 / tmp_x1)

            colors1 = color_array[(task.id - 1) * 3 % 7]
            colors2 = color_array[(task.id - 1) * 3 % 7 + 1]
            colors3 = color_array[(task.id - 1) * 3 % 7 + 2]

            plt.clf()
            plt.figure(1)
            #set title
            plt.title('AVERAGE TOTAL TIME')
            plt.figure(1).canvas.set_window_title('ANTHILL CHARTS')
            #create label
            plt.xlabel('Total units')
            plt.ylabel('Time')
            #change size figure
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y1, color=colors1, lw=1)
            output1 = 'static/graphs/avg_total' + str(task.id) + '.png'
            plt.figure(1).savefig(output1)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output1 = 'static/graphs/avg_total' + str(task.id) + '_thumbnails.png'
            plt.figure(1).savefig(output1)

            plt.clf()
            plt.figure(2)
            plt.title('AVERAGE CPU TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y2, color=colors2, lw=1)
            output2 = 'static/graphs/avg_cpu' + str(task.id) + '.png'
            plt.figure(2).savefig(output2)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output2 = 'static/graphs/avg_cpu' + str(task.id) + '_thumbnails.png'
            plt.figure(2).savefig(output2)

            plt.clf()
            plt.figure(3)
            plt.title('AVERAGE NETWORK TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y3, color=colors3, lw=1)
            output3 = 'static/graphs/avg_network' + str(task.id) + '.png'
            plt.figure(3).savefig(output3)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output3 = 'static/graphs/avg_network' + str(task.id) + '_thumbnails.png'
            plt.figure(3).savefig(output3)

            plt.clf()
            plt.figure(4)
            plt.title('AVERAGE GENERAL TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y1, color=colors1, lw=1)
            plt.plot(x1, y2, color=colors2, lw=1)
            plt.plot(x1, y3, color=colors3, lw=1)
            output4 = 'static/graphs/avg_general' + str(task.id) + '.png'
            plt.figure(4).savefig(output4)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output4 = 'static/graphs/avg_general' + str(task.id) + '_thumbnails.png'
            plt.figure(4).savefig(output4)
            plt.clf()
        else:
            plt.figure(1)
            plt.title('AVERAGE TOTAL TIME')
            #change size figure
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output1 = 'static/graphs/avg_total' + str(task.id) + '.png'
            plt.figure(1).savefig(output1)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output1 = 'static/graphs/avg_total' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output1)

            plt.figure(2)
            plt.title('AVERAGE CPU TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output2 = 'static/graphs/avg_cpu' + str(task.id) + '.png'
            plt.figure(2).savefig(output2)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output2 = 'static/graphs/avg_cpu' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output2)

            plt.figure(3)
            plt.title('AVERAGE NETWORK TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output3 = 'static/graphs/avg_network' + str(task.id) + '.png'
            plt.figure(3).savefig(output3)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output3 = 'static/graphs/avg_network' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output3)

            plt.figure(4)
            plt.title('AVERAGE GENERAL TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output4 = 'static/graphs/avg_general' + str(task.id) + '.png'
            plt.figure(4).savefig(output4)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output4 = 'static/graphs/avg_general' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output4)
            plt.clf()
    except :
        print 'Error'
        return redirect('/home')
    return redirect('/home')

#plot charts
def plot_normal(request,task):
    try:
        max_x = task.unit_set.count()
        temp_unit = Unit.objects.filter(completed=True, task=task.id).order_by('id')
        t1 = temp_unit.count()
        if t1 > 0:
            color_array = {0: (0.0, 0.5, 0.0), 1: (0.15, 0, 0.75), 2: (1.0, 0.0, 0.0), 3: (1.0, 0.0, 1.0), 4: (0.75, 0.75, 0), 5: (0.75, 0.2, 0), 6: (0.2, 0.75, 0), 7: (0.0, 0.0, 1.0), 8: (0.0, 0.75, 0.75), 9: (0.0, 0.0, 0.0)}
            t2 = 0
            #Plot with value of unit
            x1 = []
            y1 = []
            y2 = []
            y3 = []
            for unit in temp_unit:
                t2 += 1
                x1.append(t2)
                y1.append(unit.time_total())
                y2.append(unit.time_cpu())
                y3.append(unit.time_network())

            colors1 = color_array[(task.id - 1) * 3 % 7]
            colors2 = color_array[(task.id - 1) * 3 % 7 + 1]
            colors3 = color_array[(task.id - 1) * 3 % 7 + 2]

            plt.clf()
            plt.figure(1)
            #set title
            plt.title('TOTAL TIME')
            plt.figure(1).canvas.set_window_title('ANTHILL CHARTS')
            #create label
            plt.xlabel('Total units')
            plt.ylabel('Time')
            #change size figure
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y1, color=colors1, lw=1)
            output1 = 'static/graphs/normal_total' + str(task.id) + '.png'
            plt.figure(1).savefig(output1)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output1 = 'static/graphs/normal_total' + str(task.id) + '_thumbnails.png'
            plt.figure(1).savefig(output1)

            plt.clf()
            plt.figure(2)
            plt.title('CPU TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y2, color=colors2, lw=1)
            output2 = 'static/graphs/normal_cpu' + str(task.id) + '.png'
            plt.figure(2).savefig(output2)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output2 = 'static/graphs/normal_cpu' + str(task.id) + '_thumbnails.png'
            plt.figure(2).savefig(output2)

            plt.clf()
            plt.figure(3)
            plt.title('NETWORK TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y3, color=colors3, lw=1)
            output3 = 'static/graphs/normal_network' + str(task.id) + '.png'
            plt.figure(3).savefig(output3)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output3 = 'static/graphs/normal_network' + str(task.id) + '_thumbnails.png'
            plt.figure(3).savefig(output3)

            plt.clf()
            plt.figure(4)
            plt.title('GENERAL TIME')
            plt.xlabel('Total units')
            plt.ylabel('Time')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            plt.axis('on')
            plt.plot(x1, y1, color=colors1, lw=1)
            plt.plot(x1, y2, color=colors2, lw=1)
            plt.plot(x1, y3, color=colors3, lw=1)
            output4 = 'static/graphs/normal_general' + str(task.id) + '.png'
            plt.figure(4).savefig(output4)
            #thumbnails
            plt.gcf().set_size_inches(0.3, 0.2) #dpi
            plt.axis('off')
            output4 = 'static/graphs/normal_general' + str(task.id) + '_thumbnails.png'
            plt.figure(4).savefig(output4)
            plt.clf()
        else:
            plt.figure(1)
            plt.title('TOTAL TIME')
            #change size figure
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output1 = 'static/graphs/normal_total' + str(task.id) + '.png'
            plt.figure(1).savefig(output1)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output1 = 'static/graphs/normal_total' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output1)

            plt.figure(2)
            plt.title('CPU TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output2 = 'static/graphs/normal_cpu' + str(task.id) + '.png'
            plt.figure(2).savefig(output2)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output2 = 'static/graphs/normal_cpu' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output2)

            plt.figure(3)
            plt.title('NETWORK TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output3 = 'static/graphs/normal_network' + str(task.id) + '.png'
            plt.figure(3).savefig(output3)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output3 = 'static/graphs/normal_network' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output3)

            plt.figure(4)
            plt.title('GENERAL TIME')
            plt.gcf().set_size_inches(9, 5) #dpi
            plt.xlim(0, max_x)
            output4 = 'static/graphs/normal_general' + str(task.id) + '.png'
            plt.figure(4).savefig(output4)
            #thumbnails
            plt.gcf().set_size_inches(0.1, 0.1) #dpi
            output4 = 'static/graphs/normal_general' + str(task.id) + '_thumbnails.png'
            plt.figure(5).savefig(output4)
            plt.clf()
    except :
        print 'Error'
        return redirect('/home')
    return redirect('/home')


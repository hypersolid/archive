# -*- coding: utf-8 -*-
# this file is responsible for communication with ant part
from django.http import HttpResponse
from hill.main.models import *
import time, os,math
from django.db.models import Q,Sum,Count
from hill.settings import *
from django.shortcuts import redirect


# 1. ant program sends POST request to this function and get registered
def register(request):
    p = request.POST
    n = Node(user_id=int(p['user_id']), power=p['power'], cpu_number=p['cpu_number'], platform=p['platform'], hostname=p['hostname'], ip=p['ip'], time=time.time())
    n.save()
    return HttpResponse(str(n.id))

# 3. ant program asks for a program to calculate the task
def program(request, id):
    t = Task.objects.get(id=id)
    return HttpResponse(t.program_url() + '\n' + t.program_hash)

# 2. ant program asks for a new task or submits old task and asks for a new one at the same time 
def node(request, id,cache=''):
    if request.method == 'GET':
        t_total_start=time.time()
        t_mysql=0
        t_mysql_start=time.time()
        check_chunk=False
        if len(cache)>0:
            chunk=eval('['+cache+']')
            u = Unit.objects.filter(Q(node=None,completed=False,id__in=chunk)).order_by('?')[:1]
            if u.count()>0:
                check_chunk=True
        if check_chunk==False:
            u = Unit.objects.filter(Q(node=None,completed=False) | Q(node__gt=0, completed=False)).order_by('?')[:1]
        t_mysql+=time.time()-t_mysql_start
        #Process when all nodes completed
        if len(u) == 0:
            HttpResponse.status_code = 500
            return HttpResponse('')
        else:
            u = u[0]
        u.node_id = id
        u.submitted_at  = float(time.time())
        t_mysql_start=time.time()
        u.save()
        t_mysql+=time.time()-t_mysql_start
        HttpResponse.status_code = 200
        t_total=time.time()-t_total_start
        f=open(MEDIA_ROOT+'tmp/time'+str(u.id)+'.prof','w')
        f.write('%s %s'%(str(t_total-t_mysql),str(t_mysql)))
        f.close()
        return HttpResponse('\n'.join([str(u.id), str(u.task_id), u.task.program_hash, u.params_url(),u.network_url(),str(int(check_chunk))]))

    # 4. submit results
    if request.method == 'POST':
        t_post_start=time.time()
        t_mysql=0
        p = request.POST
        t_mysql_start=time.time()
        u = Unit.objects.get(id=p['id'])
        #u.result = '['+p['result'].replace(' ',',')+']'
        u.result = convert_to_binary('['+p['result'].replace(' ',',')+']')
        n=Node.objects.get(id=id)
        u.flops = float(p['time_ant_cpu'])
        u.error=float(p['error'])
        u.completed = True
        u.received_at  = float(time.time())
        u.save()
        #Check finish epoch
        tmp=Task.objects.get(id=u.task_id)
        u_sum=Unit.objects.filter(task=tmp.id,completed=True).aggregate(t_submitted=Sum('submitted_at'),t_received=Sum('received_at'),u_count=Count('id'))
        t_mysql+=time.time()-t_mysql_start
        time_unit=u_sum['t_received']-u_sum['t_submitted']
        chunk_completed=u_sum['u_count']
        check_time_percent=(time_unit>time_max) and (tmp.count_epoch!=tmp.number_epochs) and (chunk_completed>percent_completed*tmp.number_blocks)
        if (((chunk_completed==int(tmp.number_blocks)) and (tmp.count_epoch!=tmp.number_epochs)) or check_time_percent):
            #Meger weights
            w_old= revert_from_binary(tmp.result)
            error=0.0
            t_mysql_start=time.time()
            u = Unit.objects.filter().all()
            t_mysql+=time.time()-t_mysql_start
            for unit in u:
                weights=revert_from_binary(unit.result)
                #If unit not ok => plus 1/(2^delay)*delta(delay)
                if unit.completed==0:
                    for i in range(len(w_old)):
                        w_old[i]+=(1.0/math.pow(2,unit.step))*(weights[i]/tmp.number_blocks)
                else:
                    for i in range(len(w_old)):
                        w_old[i]+=weights[i]/tmp.number_blocks
                    error+=unit.error
                    #Increase step
                    unit.step+=1
                    if tmp.count_epoch<tmp.number_epochs-1:
                        #Reset unit
                        unit.node_id=None
                        unit.completed=False
                        #unit.result=''
                        unit.received_at=0
                        unit.submitted_at=0
                        unit.error=0
                    t_mysql_start=time.time()
                    unit.save()
                    t_mysql+=time.time()-t_mysql_start

            #Set new weights for all net
            w_new=str(list(w_old))
            tmp.result=convert_to_binary(w_new)
            tmp.error+=str(error/tmp.number_blocks)+' '
            tmp.count_epoch+=1
            if tmp.count_epoch==tmp.number_epochs:
                tmp.completed=True
            t_mysql_start=time.time()
            tmp.save()
            t_mysql+=time.time()-t_mysql_start
            w_new='"'+w_new.strip()+'"'
            file_update_weights=settings.MEDIA_ROOT_PROGRAM+str(tmp.id)+'/server/update_weights.py'
            path_cmd='python '+file_update_weights+' '+settings.MEDIA_ROOT_PROGRAM+str(tmp.id)+'/server'+' '+ w_new
            path_cmd=path_cmd.replace('\\','/')
            os.system(path_cmd)
            print "Finish epochs "+str(tmp.count_epoch)

        t_post_total=time.time()-t_post_start
        time_get=open(MEDIA_ROOT+'tmp/time'+p['id']+'.prof','r').read().split()
        t_hillcode=t_post_total-t_mysql+float(time_get[0])
        t_mysql+=float(time_get[1])
        
        os.remove(MEDIA_ROOT+'tmp/time'+p['id']+'.prof')
        n.time_cpu+=float(p['time_ant_cpu'])
        n.time_antcode+=float(p['time_ant_code'])
        n.time_hillcode+=t_hillcode
        n.time_mysql+=t_mysql
        n.time_network+=time.time()-float(p['time_unit_start'])-t_hillcode-t_mysql-float(p['time_ant_cpu'])-float(p['time_ant_code'])
        n.save()
        return HttpResponse('')

# Submits profile for ant
def profile(request, id):
    if request.method == 'POST':
        p = request.POST
        time_ant_cpu=float(p['time_ant_cpu'])
        time_ant_network=float(p['time_ant_network'])
        time_ant_hdd=float(p['time_ant_hdd'])
        time_ant_code=float(p['time_ant_code'])
        time_hill_code=float(p['time_hill_code'])
        time_mysql=float(p['time_mysql'])
        n = Node.objects.get(id=id)
        n.time_cpu+=time_ant_cpu
        n.time_hdd+=time_ant_hdd
        n.time_network+=time_ant_network
        n.time_antcode+=time_ant_code
        n.time_hillcode+=time_hill_code
        n.time_mysql+=time_mysql
        n.save()
    return HttpResponse('')

def results(request, id):
    output='<?xml version="1.0" ?>'
    output+="<root>"
    units = Unit.objects.filter(task=id).all()
    mapper = lambda x: "<unit><params>%s</params><result>%s</result></unit>" % (x.params,x.result)
    output += '\n'.join(map(mapper,units))
    output+="</root>"
    response = HttpResponse(output, mimetype='text/xml')
    response['Content-Disposition'] = 'attachment; filename=result'+id+'.xml'
    return response

def reset_time(request):
    nd=Node.objects.filter().all()
    for n in nd:
        n.time_cpu=0
        n.time_hdd=0
        n.time_network=0
        n.time_antcode=0
        n.time_hillcode=0
        n.time_mysql=0
        n.save()
    return redirect('/home')

def convert_to_binary(weights_server):
    import array
    result=eval(weights_server)
    a = array.array('f', result)
    a= a.tostring()
    return a

def revert_from_binary(a):
    import array
    b = array.array('f')
    b.fromstring(a)
    return b

def files(request, id,start,stop,steps):
    if request.method == 'GET':
        dir_link=SITE_URL+'static/files/'
        dir_path=MEDIA_ROOT+'files/'
        path_cmd= 'python '+dir_path+'create_files.py'+' '+str(start)+' '+str(stop)+' '+str(steps)+' '+dir_path+' '+dir_link
        print path_cmd
        os.system(path_cmd)
        file_config=dir_link+'config.txt'
        HttpResponse.status_code = 200
        return HttpResponse(file_config)
    # 4. submit results
    if request.method == 'POST':
        return HttpResponse('')
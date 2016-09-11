# -*- coding: utf-8 -*-
# this file is responsible for communication with ant part
from django.http import HttpResponse
from hill.main.models import *
from hill.settings import *
import time
from hill.logfile import fileInfo
import logging
from django.shortcuts import redirect
import os
# 1. ant program sends POST request to this function and get registered
def register(request):
    p = request.POST
    n = Node(user_id=int(p['user_id']), power=p['power'], cpu_number=p['cpu_number'], platform=p['platform'], hostname=p['hostname'], ip=p['ip'], time=time.time())
    n.save()
    logger = logging.getLogger("hill_logfile")
    logger.info(fileInfo() + ' - Create new node ' + str(n.id))
    return HttpResponse(str(n.id))

# 3. ant program asks for a program to calculate the task
def program(request, id):
    t = Task.objects.get(id=id)
    return HttpResponse(t.program_url() + '\n' + t.program_hash)

# 2. ant program asks for a new task or submits old task and asks for a new one at the same time
# task example: a=1, b=2, c=3
def node(request, id):
    from django.db.models import Q
    if request.method == 'GET':
        t_total_start=time.time()
        t_mysql=0
        t_mysql_start=time.time()
        n = Node.objects.get(id=id)
        t_mysql+=time.time()-t_mysql_start
        if n.bad > 1000:
            return HttpResponse('')
        t_out = time.time() - time_max
        t_mysql_start=time.time()
        ut = Unit.objects.filter(Q(node=None,completed=False) | Q(submitted_at__lt=t_out, completed=False)).order_by('?')[:1]
        t_mysql+=time.time()-t_mysql_start
        if not ut:
            HttpResponse.status_code = 500
            return HttpResponse('')
        u=ut[0]
        u.node_id = id
        u.submitted_at = float(t_total_start)
        t_mysql_start=time.time()
        u.save()
        t_mysql+=time.time()-t_mysql_start
        t_total=time.time()-t_total_start
        f=open('static/tmp/time'+str(u.id)+'.prof','w')
        f.write('%s %s'%(str(t_total-t_mysql),str(t_mysql)))
        f.close()
        HttpResponse.status_code = 200
        return HttpResponse('\n'.join([str(u.id), str(u.task_id), u.task.program_hash, u.params]))
        

    # 4. submit results
    if request.method == 'POST':
        t_total_start=time.time()
        t_mysql=0
        p = request.POST
        p_id = p['id']
        p_result = p['result']
        checkResult=True
        if not(p_result == '' or p_result.lower().find('error') != -1 or p_result.lower().find('python') != -1):
            t_mysql_start=time.time()
            u = Unit.objects.get(id=p_id)
            n = Node.objects.get(id=id)
            if n.bad > 0:
                n.bad = 0 #reset n.bad
            n.time=time.time()
            n.save()
            #Copy to u_completed
            uc=Unit_completed(id=u.id,task_id=u.task_id,node_id=u.node_id,params=u.params,submitted_at=u.submitted_at,received_at=time.time(),result=p_result,completed=True,flops = float(p['time_ant_cpu']))
            uc.save()
            u.completed=True
            u.save()
            time_unit_start=u.submitted_at
            t_mysql+=time.time()-t_mysql_start
        else:
            checkResult=False
            t_mysql_start=time.time()
            n = Node.objects.get(id=id)
            t_mysql+=time.time()-t_mysql_start
            n.bad += 1
            n.save()
            t_mysql_start=time.time()
            u = Unit.objects.get(id=p_id)
            t_mysql+=time.time()-t_mysql_start
            u.submitted_at = 0
            u.completed = False
            u.node_id = None
            t_mysql_start=time.time()
            u.save()
            t_mysql+=time.time()-t_mysql_start
            logger = logging.getLogger("hill_logfile")
            logger.info(fileInfo() + ' - Run unit error - node:' + id + ', units:' + p['id'])
        if checkResult==True:
            time_get=open(SITE_ROOT+'static/tmp/time'+p['id']+'.prof','r').read().split()        
            time_hill_code=time.time()-t_total_start-t_mysql+float(time_get[0])
            time_mysql=t_mysql+float(time_get[1])
            time_ant_cpu = float(p['time_ant_cpu'])
            time_ant_code = float(p['time_ant_code'])
            #time_unit_start=float(p['time_unit_start'])
            time_post_total=time.time()-time_unit_start
            time_network=time_post_total-(time_hill_code+time_ant_code+time_ant_cpu+time_mysql)
            n.time_cpu+=time_ant_cpu
            n.time_antcode+=time_ant_code
            n.time_hillcode+=time_hill_code
            n.time_mysql+=time_mysql
            n.time_network+=time_network
            n.save()
        if os.path.isfile(SITE_ROOT+'static/tmp/time'+p['id']+'.prof'):
            os.remove(SITE_ROOT+'static/tmp/time'+p['id']+'.prof')
        if checkResult:
            HttpResponse.status_code = 200
        else:
            HttpResponse.status_code = 500
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


def results(request, id, f_type):
    output_xml = '<?xml version="1.0" ?>'
    output_xml += "<root>"
    units = Unit_completed.objects.filter(task=id, completed=True)
    mapper = lambda x: "<unit><params>%s</params><result>%s</result></unit>" % (x.params, x.result)
    output_xml += '\n'.join(map(mapper, units))
    output_xml += "</root>"
    mapper1 = lambda x: "%s" % (x.result)
    output_txt = '\n'.join(map(mapper1, units))
    if int(f_type) == 0:
        response = HttpResponse(output_xml, mimetype='text/xml')
        response['Content-Disposition'] = 'attachment; filename=results' + id + '.xml'
    else:
        response = HttpResponse(output_txt, mimetype='text/plain')
        response['Content-Disposition'] = 'attachment; filename=results' + id + '.txt'
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

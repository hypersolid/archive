# -*- coding: utf-8 -*-
from django.shortcuts import *
from django.template import RequestContext, loader
from hill.logfile import fileInfo
from hill.main.charts import *
from hill.main.models import *
from hill.settings import *
import django.contrib.auth
import logging,libann
import time,os

### Main views
def index(request):
    if request.user and request.user.is_authenticated():
        return redirect('/home')
    else:
        return template('index.html', request)

def home(request):
    if HttpResponse.status_code == 500:
        HttpResponse.status_code = 200
    user = request.user.get_profile()
    t_out = time.time() - 30 * 24 * 3600
    tasks = Task.objects.filter(user=user).order_by('-id')
    #Deleted nodes a month ago
    Node.objects.filter(time__lt=t_out).delete()
    #Select 20 nodes to views
    nodes = Node.objects.filter(user=user).order_by('-id')[:20]
    log = []
    logfile_path = SITE_ROOT + 'logfile.txt'
    if os.path.exists(logfile_path):
        log = open(logfile_path).readlines()
        if len(log)>11:
            log = log[len(log) - 11:len(log)]
    return template('home.html', request, {'tasks':tasks, 'nodes':nodes, 'log':log})

### Task views
def tasks_create(request):
    p = request.POST
    f = request.FILES
    t = Task(user=request.user.get_profile(), title=p['title'])
    if f.has_key('program'):
        t.program = f['program']
    if f.has_key('params'):
        t.params = f['params']
    #Check file, if zipfile then ok else not_ok.
    #??????????????????????????????????????????
    t.save()
    #Create unit
    t.result=libann.create_unit(t,0)
    t.save()
    logger = logging.getLogger("hill_logfile")
    logger.info(fileInfo() + ' - Create new tasks - Name:' + p['title'] + ', id:' + str(t.id))
    return redirect('/home')

def tasks_update(request, id):
    f = request.FILES
    t = Task.objects.get(id=id)
    if f.has_key('program'):
        t.program = f['program']
    if f.has_key('params'):    
        t.params = f['params']
    t.completed=False
    t.count_epoch=0
    t.result=''
    t.error=''
    t.save()
    #t.restart()
    t.result=libann.create_unit(t,1)
    t.save()
    logger = logging.getLogger("hill_logfile")
    logger.info(fileInfo() + ' - Update tasks - Id:' + str(id))
    return redirect('/home')

def tasks_test(request, id):
    t = Task.objects.get(id=id)
    num_input=t.number_input
    link_file_test=MEDIA_ROOT_PROGRAM+str(id)+'/server/test.py'
    file_net=MEDIA_ROOT_PROGRAM+str(id)+'/server/server.net'
    file_data_test=MEDIA_ROOT_PROGRAM+str(id)+'/server/data/test.txt'
    full_cmd='python '+link_file_test+' '+file_net+' '+file_data_test+' '+str(int(num_input))
    os.system(full_cmd)
    return redirect('/home')

def tasks_error(request, id):
    t = Task.objects.get(id=id)
    error=t.error.strip()
    link_file_error=MEDIA_ROOT_PROGRAM+str(id)+'/server/error.py'
    error='"'+error+'"'
    full_cmd='python '+link_file_error+' '+error
    os.system(full_cmd)
    return redirect('/home')

def tasks_delete(request, id):
    Task.objects.get(id=id).delete()
    remove_dir(MEDIA_ROOT_PROGRAM+str(id))
    remove_dir(MEDIA_ROOT_PARAM+str(id))
    logger = logging.getLogger("hill_logfile")
    logger.info(fileInfo() + ' - Delete tasks - Id:' + str(id))
    return redirect('/home')

### Nodes views
def nodes_delete(request, id):
    Node.objects.get(id=id).delete()
    return redirect('/home')

### Auth functions
def login(request):
    p = request.POST
    user = django.contrib.auth.authenticate(username=p['email'], password=p['password'])
    if user is None:
        return template('index.html', request, {'flash':'Wrong email or password'})
    else:
        django.contrib.auth.login(request, user)
        return redirect('/home')
    
def logout(request):
    try:
        django.contrib.auth.logout(request)
    except:
        pass
    return redirect('/')

def register(request):
    p = request.POST
    user = User(username=p['email'], email=p['email'])
    user.set_password(p['password'])
    
    try:
        user.save()
    except:
        return template('index.html', request, {'flash':'This email was already taken'})
        
    profile = Profile(name=p['name'], email=p['email'], password=p['password'], organization=p['organization'], user=user)
    profile.save()
    return login(request)
    
### Secondary functions
def template(name, request, context={}):
    context = RequestContext(request, context)
    return HttpResponse(loader.get_template(name).render(context))

def deploy(request):
    import re
    user = request.user.get_profile()
    user_id = user.id
    f = open(ANT_ROOT + 'config.xml', 'r+')
    cfg = f.read()
    
    url = SITE_URL.replace('\\', '/')
    url = url.split('//')[-1]
    url = url.split('/')[0]
    cfg = re.sub('<server>[^<]*?</server>', '<server>' + url + '</server>', cfg)
    cfg = re.sub('<user_id>[^<]*?</user_id>', '<user_id>' + str(user_id) + '</user_id>', cfg)
    cfg = re.sub('<node_id>[^<]*?</node_id>', '', cfg)
    
    f.close()
    
    import zipfile, os.path, shutil
    deploy_dir = SITE_ROOT + 'static/deploy/'
    deploy_ant = deploy_dir + 'ant.zip'
    user_ant = deploy_dir + 'ant%d.zip' % user_id
    if not os.path.exists(user_ant):
        shutil.copyfile(deploy_ant, user_ant)
        z = zipfile.ZipFile(user_ant, 'a')
        z.writestr('ant/config.xml', cfg)
        z.close()

    return HttpResponseRedirect('/static/deploy/ant%d.zip' % user_id)

def HillPath():
    return SITE_ROOT + '/hill'

def remove_dir(folder):
    import shutil
    try:
        for root, dirs, files in os.walk(folder):
            for f in files:
                os.remove(os.path.join(root, f))
            for d in dirs:
                shutil.rmtree(os.path.join(root, d))
        os.rmdir(folder)
        return True
    except :
        return False
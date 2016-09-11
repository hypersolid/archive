# -*- coding: utf-8 -*-
from django.contrib.auth.models import User, UserManager
from django.http import HttpResponse, HttpResponsePermanentRedirect, HttpResponseRedirect
from django.shortcuts import *
from django.template import Context, RequestContext, Template, loader
from hill.logfile import fileInfo
from hill.main.charts import *
from hill.main.models import *
from hill.settings import *
import django.contrib.auth
import logging
import time

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
        if len(log):
            log = log[len(log) - 11:len(log) - 1]
        
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
    t.save()
    t.validate()
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
    t.save()
    t.restart()
    logger = logging.getLogger("hill_logfile")
    logger.info(fileInfo() + ' - Update tasks - Id:' + str(id))
    return redirect('/home')

def tasks_delete(request, id):
    Task.objects.get(id=id).delete()
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

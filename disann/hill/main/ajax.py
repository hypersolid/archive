from django.http import HttpResponse, HttpResponsePermanentRedirect, HttpResponseRedirect
from hill.settings import *
from hill.main.models import *
import json

def stats(request):
    response = []

    user = User.objects.get(id=request.GET['id']).get_profile()
    
    tasks = Task.objects.filter(user=user)
    for task in tasks:
        response.append(['stats_%d_percentage' % task.id, task.percentage() + ' %'])
        response.append(['stats_%d_time' % task.id, task.get_time()])
        response.append(['stats_%d_flops' % task.id, task.get_flops()])
    response.append(['stats_tasks', user.tasks_completed()])
    response.append(['stats_subtasks', user.units_completed()])
    response.append(['stats_estimated_time', user.estimated_time()])
    return HttpResponse(json.dumps(response))

def log(request):
    log = []
    logfile_path = SITE_ROOT + 'logfile.txt'
    if os.path.exists(logfile_path):
        log = open(logfile_path).readlines()
        if len(log):
            log = log[len(log) - 11:len(log) - 1]
    return HttpResponse('<br />'.join(log))

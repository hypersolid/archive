# -*- coding: utf-8 -*-
from django.conf import settings
from django.contrib.auth.models import User
from django.db import models
from django.db.models import Avg, Sum
from os import path,rename,remove,chdir
import django.utils.http
import hashlib

class BlobField(models.Field):
    description = "Blob"
    def db_type(self, connection):
        return 'blob'
    
class Profile(models.Model):
    user = models.OneToOneField(User, null=True)
    name = models.CharField(max_length=200)
    organization = models.CharField(max_length=100, blank=True)
    email = models.EmailField(max_length=75, unique=True)
    password = models.CharField(max_length=50)
    
    def name_humanized(self):
        if self.name:
            return self.name
        else:
            return "User"
    
    def tasks_total(self):
        return self.task_set.count()

    def tasks_completed(self):
        return self.task_set.filter(completed=True).count()
    
    def units_total(self):
        return Unit.objects.filter(task__user=self.id).count()
    
    def units_completed(self):
        return Unit.objects.filter(completed=True, task__user=self.id).count()

class Node(models.Model):
    user = models.ForeignKey(Profile)
    # info
    cpu_number = models.IntegerField(default=0)
    power = models.FloatField(default=0)
    platform = models.CharField(max_length=250)
    hostname = models.CharField(max_length=250)
    ip = models.CharField(max_length=250)
    # stats
    stat_flops = models.FloatField(default=0)
    stat_units = models.IntegerField(default=0)
    stat_failures = models.IntegerField(default=0)
    # bad
    bad = models.IntegerField(default=0)
    # time for stop
    time = models.FloatField(default=0)
    # time from ant
    time_cpu=models.FloatField(default=0)
    time_hdd=models.FloatField(default=0)
    time_network=models.FloatField(default=0)
    time_antcode=models.FloatField(default=0)
    time_hillcode=models.FloatField(default=0)
    time_mysql=models.FloatField(default=0)
    
    def title(self):
        return u"№%d %s (%.3fx%d GFlops/s) %s" % (self.id, self.hostname, self.power, self.cpu_number, self.platform)
    
    def get_flops(self):
        value = self.unit_set.filter(completed=True).all().aggregate(sum_flops=Sum('flops'))['sum_flops']
        return '%.3f' % (value)


class Task(models.Model):
    user = models.ForeignKey(Profile)
    title = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now=True)
    count_epoch=models.FloatField(default=0)
    completed = models.BooleanField(default=False)
    validated = models.BooleanField(default=False)
    # data
    program = models.FileField(upload_to=settings.MEDIA_ROOT_PROGRAM)
    program_hash = models.CharField(max_length=200)
    params = models.FileField(upload_to=settings.MEDIA_ROOT_PARAM)
    # Info network
    result=BlobField()
    error=models.TextField()
    number_epochs=models.FloatField(default=0)
    number_blocks=models.FloatField(default=0)
    number_input=models.FloatField(default=0)
    number_hidden=models.FloatField(default=0)
    number_output=models.FloatField(default=0)

    def units_total(self):
        return self.unit_set.count()
    
    def units_completed(self):
        return self.unit_set.filter(completed=True).count()
    
    def check_completeness(self):
        value = True
        if not self.completed:
            value = self.units_total() != 0 and self.units_completed() == self.units_total()
            if value:
                self.completed = True
                self.save()
        return value
    
    def percentage(self):
        value = "%.1f" % (float(self.count_epoch) / self.number_epochs  * 100)
        return value
        
    def program_url(self):
        return settings.MEDIA_URL + 'uploads/programs/'+str(self.id)+'/client/' + path.basename(str(self.program))
    
    def params_url(self):
        return settings.MEDIA_URL + 'uploads/params/'+str(self.id)+'/' + path.basename(str(self.params))
    
    def validate(self,file_name,weights):
        if self.program and self.params:
            self.get_md5()
            self.map(file_name,weights)
            if self.units_total():
                self.validated = True
                self.save()
                
    def map(self,file_name,weights):
        #Get path to create unit
        from libann import zip
        f = open(file_name, 'r')
        st=[]
        for line in f.readlines():
            file_name_old=line.replace('\n', '')
            u = Unit(task=self, result=weights)
            #Rename file
            u.save()    
            #Rename file
            file_name_new=path.dirname(file_name_old)+'/'+str(u.id)+'.txt'
            rename(file_name_old,file_name_new)
            file_name_zip=path.dirname(file_name_old)+'/'+str(u.id)+'.zip'
            chdir(path.dirname(file_name_old))
            zip(str(u.id)+'.txt',str(u.id)+'.zip')
            remove(file_name_new)
            st.append(file_name_zip)
        f = open(file_name, 'w')
        for i in range(len(st)):
            if i<len(st)-1:
                f.write(st[i]+'\n')
            else:
                f.write(st[i])
        f.close()
        
    def restart(self,file_name,weights):
        Unit.objects.filter(task=self).delete()
        self.completed = False
        self.save()
        self.validate(file_name,weights)

    def get_md5(self):
        self.program_hash = django.utils.http.urlquote_plus(self.md5_for_file(open(str(self.program))))
        self.save
    
    def md5_for_file(self, f, block_size=2 ** 20):
        md5 = hashlib.md5()
        while True:
            data = f.read(block_size)
            if not data:
                break
            md5.update(data)
        return md5.digest()
    
    def get_time(self):
        #value = self.unit_set.filter(completed=True).all().aggregate(sum_time=Sum('time'))['sum_time']
        value1 = self.unit_set.filter(completed=True).all().aggregate(submitted_time=Sum('submitted_at'))['submitted_time']
        value2 = self.unit_set.filter(completed=True).all().aggregate(received_time=Sum('received_at'))['received_time']
        if value1 and value2:
            value = value2 - value1
            return '%.1f' % (float(value) / 60.0)
        else:
            return 0
    
    def get_flops(self):
        value = self.unit_set.filter(completed=True).all().aggregate(sum_flops=Sum('flops'))['sum_flops']
        if value:
            return '%.3f' % (value)
        else:
            return 0

    def get_patterns(self):
        file_name=settings.MEDIA_ROOT_PARAM+str(self.id)+'/config.txt'
        lines=open(file_name).readline()
        return int(lines[4].split('=')[-1])

class Unit(models.Model):
    task = models.ForeignKey(Task)
    node = models.ForeignKey(Node, null=True)
    flops = models.FloatField(default=0)
    result =BlobField()
    step = models.FloatField(default=0)
    error = models.FloatField(default=0)
    # stats
    submitted_at = models.FloatField(default=0)
    received_at = models.FloatField(default=0)
    completed = models.BooleanField(default=False)

    def network_url(self):
        return settings.MEDIA_URL + 'uploads/programs/'+str(self.task_id)+'/server/server.net'

    def params_url(self):
        return settings.MEDIA_URL + 'uploads/params/'+str(self.task_id)+'/' + str(self.id)+'.zip'

    def submitted(self):
        if self.submitted_at == 0:
            return False
        else:
            return True
        
    def received(self):
        if self.received_at == 0:
            return False
        else:
            return True

    def timeout(self):
        if (self.completed == False) and (self.node == True):
            return True
        else:
            return False

    def time_network(self):
        return self.received_at - self.submitted_at - self.time

    def time_cpu(self):
        return self.time

    def time_total(self):
        return self.received_at - self.submitted_at


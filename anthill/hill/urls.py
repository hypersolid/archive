from django.conf.urls.defaults import *
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^rest/results/(\d+)/(\d+)$','main.rest.results'),
    
    url(r'^$', 'main.views.index'),
    url(r'^home/?$', 'main.views.home'),
    
    url(r'^login/?$', 'main.views.login'),
    url(r'^logout/?$', 'main.views.logout'),
    url(r'^register/?$', 'main.views.register'),
    url(r'^deploy', 'main.views.deploy'),
    
    url(r'^tasks/create/?$', 'main.views.tasks_create'),
    url(r'^tasks/update/(\d+)$', 'main.views.tasks_update'),
    url(r'^tasks/delete/(\d+)$', 'main.views.tasks_delete'),
    url(r'^nodes/delete/(\d+)$', 'main.views.nodes_delete'),

    url(r'^admin/', include(admin.site.urls)),
    
    url(r'^ajax/stats$', 'main.ajax.stats'),
    url(r'^ajax/log$', 'main.ajax.log'),
    
    url(r'^rest/register$', 'main.rest.register'),
    url(r'^rest/program/(\d+)$', 'main.rest.program'),
    url(r'^rest/node/(\d+)$', 'main.rest.node'),
    url(r'^rest/profile/(\d+)$', 'main.rest.profile'),
    url(r'^rest/reset_time/$', 'main.rest.reset_time'),
    url(r'^plot/chart/node/time/process/(\d+)$', 'main.charts.plot_profile'),
    url(r'^plot/chart/task/time/avg/(\d+)$', 'main.charts.plot_task_time_avg'),
    url(r'^plot/chart/node/time/update/(\d+)$', 'main.charts.plot_node_time_update'),
    url(r'^plot/chart/node/error/(\d+)$', 'main.charts.plot_node_error'),
)



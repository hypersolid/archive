from django.conf.urls.defaults import *
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'main.views.index'),
    url(r'^home/?$', 'main.views.home'),
    
    url(r'^login/?$', 'main.views.login'),
    url(r'^logout/?$', 'main.views.logout'),
    url(r'^register/?$', 'main.views.register'),
    url(r'^deploy', 'main.views.deploy'),
    
    url(r'^tasks/create/?$', 'main.views.tasks_create'),
    url(r'^tasks/update/(\d+)$', 'main.views.tasks_update'),
    url(r'^tasks/test/(\d+)$', 'main.views.tasks_test'),
    url(r'^tasks/error/(\d+)$', 'main.views.tasks_error'),
    url(r'^tasks/delete/(\d+)$', 'main.views.tasks_delete'),
    url(r'^nodes/delete/(\d+)$', 'main.views.nodes_delete'),

    url(r'^admin/', include(admin.site.urls)),
    
    url(r'^ajax/stats$', 'main.ajax.stats'),
    url(r'^ajax/log$', 'main.ajax.log'),
    
    url(r'^rest/register$', 'main.rest.register'),
    url(r'^rest/program/(\d+)$', 'main.rest.program'),
    #url(r'^rest/node/(\d+)/(\?+)$', 'main.rest.node'),
    url(r'^rest/node/(?P<id>(\d+))/(?P<cache>.*)$', 'main.rest.node'),
    url(r'^rest/profile/(\d+)$', 'main.rest.profile'),
    url(r'^rest/results/(\d+)/(\d+)$', 'main.rest.results'),
    url(r'^rest/reset_time/$', 'main.rest.reset_time'),
    url(r'^plot/chart/(\d+)$', 'main.charts.plot_profile'),
    #url(r'^rest/files/?P<id>(\d+)/?P<start>(\d+)/?P<stop>(\d+)/?P<steps>(\d+)$', 'main.rest.files'),
    url(r'^rest/files/(\d+)/(\d+)/(\d+)/(\d+)$', 'main.rest.files'),
)


import math
math.sin
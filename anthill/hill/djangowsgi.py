import os, sys
root = os.path.realpath(__file__)

path=os.path.dirname(root)
if path not in sys.path:
  sys.path.append(path)


path=os.path.dirname(root.replace('\\hill', '\\'))
if path not in sys.path:
  sys.path.append(path)

os.environ['DJANGO_SETTINGS_MODULE'] = 'hill.settings'
import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()

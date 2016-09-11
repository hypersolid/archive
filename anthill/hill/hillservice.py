### Run Python scripts as a service
import win32service
import win32serviceutil
import win32api
import win32event
import win32con
import os
import settings
from time import *
from servicemanager import LogErrorMsg 
def checkServices(name):
    resume = 0
    accessSCM = win32con.GENERIC_READ
    accessSrv = win32service.SC_MANAGER_ALL_ACCESS
    #Open Service Control Manager
    hscm = win32service.OpenSCManager(None, None, accessSCM)
    #Enumerate Service Control Manager DB
    typeFilter = win32service.SERVICE_WIN32
    stateFilter = win32service.SERVICE_STATE_ALL
    services = win32service.EnumServicesStatus(hscm, typeFilter, stateFilter)
    name_lower = name.lower()
    match = [i for i in services if i[0].lower() == name_lower or i[1].lower() == name_lower]
    if (len(match) == 0):
        return False
    else:
        return True

class a_service(win32serviceutil.ServiceFramework):

   _svc_name_ = "Hill Server"
   _svc_display_name_ = "Hill server program!"
   _svc_description_ = ""

   def __init__(self, args):
           win32serviceutil.ServiceFramework.__init__(self, args)
           self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)

   def SvcStop(self):
           self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
           win32event.SetEvent(self.hWaitStop)
           try:
                self._flax_main.stop()
           except:
                import traceback
                tb = traceback.format_exc()
                LogErrorMsg('Exception during SvcStop, traceback follows:\n %s' % tb)

   def SvcDoRun(self):
      import servicemanager
      servicemanager.LogMsg(servicemanager.EVENTLOG_INFORMATION_TYPE, servicemanager.PYS_SERVICE_STARTED, (self._svc_name_, ''))
      self.timeout = 1#120000     #120 seconds / 2 minutes
      # This is how long the service will wait to run / refresh itself (see script below)
      kt = True
      while True:
         # Wait for service stop signal, if I timeout, loop again
         rc = win32event.WaitForSingleObject(self.hWaitStop, self.timeout)
         # Check to see if self.hWaitStop happened
         if rc == win32event.WAIT_OBJECT_0:
            # Stop signal encountered
            servicemanager.LogInfoMsg("SomeShortNameVersion - STOPPED!")  #For Event Log
            break
         else:
                 try:
                    if kt == True:
                        path = os.path.dirname(os.path.realpath(__file__))
                        path = path.replace('\\', '/')
                        cmdFull = settings.SITE_URL.split('http://')[-1]
                        cmdFull = cmdFull.replace('/', '')
                        cmdFull = 'python manage.py runserver ' + cmdFull
                        dir_Path = path.split('/')[0]
                        f = open(path + '/auto.bat', 'w')
                        f.write('%s\n' % dir_Path)
                        f.write('%s\n' % ('CD ' + path))
                        f.write('%s\n' % (cmdFull))
                        f.close()
                        sleep(20)
                        os.system(path + '/auto.bat')
                        kt = False
                 except:
                    pass
                 sleep(3)

def ctrlHandler(ctrlType):
   return True

if __name__ == '__main__':
   win32api.SetConsoleCtrlHandler(ctrlHandler, True)
   win32serviceutil.HandleCommandLine(a_service)

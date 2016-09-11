### Run Python scripts as a service 
import win32service
import win32serviceutil
import win32api
import win32event
import win32con
from time import *
from lib.uplink import Uplink
from lib.config import Config,logFile,antPath
from lib.registration import login_node
from lib.tasks import *
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
    name_lower=name.lower()
    match = [i for i in services if i[0].lower() == name_lower or i[1].lower() == name_lower]
    if (len(match) == 0):
        return False
    else:
        return True
    
class a_service(win32serviceutil.ServiceFramework):

   _svc_name_ = "DisANN_AntProgram"
   _svc_display_name_ = "DisANN_ANTProgram"
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
                tb=traceback.format_exc()
                LogErrorMsg('Exception during SvcStop, traceback follows:\n %s' % tb)

   def SvcDoRun(self):
      import servicemanager
      servicemanager.LogMsg(servicemanager.EVENTLOG_INFORMATION_TYPE,servicemanager.PYS_SERVICE_STARTED,(self._svc_name_, ''))
      self.timeout = 10#120000     #120 seconds / 2 minutes
      # This is how long the service will wait to run / refresh itself (see script below)
      sleep(5) #wait other service start
      logFile()
      cfg = Config()
      uplink = Uplink(cfg)
      login_node(uplink, cfg)
      remove_dir(antPath()+'/cache')
      while True:
         # Wait for service stop signal, if I timeout, loop again
         rc = win32event.WaitForSingleObject(self.hWaitStop, self.timeout)
         # Check to see if self.hWaitStop happened
         if rc == win32event.WAIT_OBJECT_0:
             # Stop signal encountered
             servicemanager.LogInfoMsg("SomeShortNameVersion - STOPPED!")  #For Event Log
             logger = logging.getLogger("logfile")
             logger.info(config.fileInfo()+' - '+'SomeShortNameVersion - STOPPED!')
             break
         else:
             try:
                 run_unit_time(uplink, cfg)
             except:
                logger = logging.getLogger("logfile")
                logger.info(config.fileInfo()+' - '+'run unit from service error')
                sleep(30)
                cfg = Config()
                uplink = Uplink(cfg)
                login_node(uplink, cfg)
                remove_dir(antPath()+'/cache')

def ctrlHandler(ctrlType):
   return True

if __name__ == '__main__':
   win32api.SetConsoleCtrlHandler(ctrlHandler, True)
   win32serviceutil.HandleCommandLine(a_service)

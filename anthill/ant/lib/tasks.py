import shutil
import time
import os
import config
import zipfile
import logging

file_output = config.antPath() + '/output/output.txt'
task_id = []
def unzip_file(my_dir, my_zip):
    zip_file = zipfile.ZipFile(my_zip, 'r')
    for files in zip_file.namelist():
        data = zip_file.read(files, my_dir)
        myfile_path = my_dir + files
        if myfile_path.endswith('/'):
            os.makedirs(myfile_path)
        if not myfile_path.endswith('/'):
            myfile = open(myfile_path, "wb")
            myfile.write(data)
            myfile.close()
    zip_file.close()

def update_program(uplink, cfg, id, hash=''):
    if update_hash(id, hash):
        id = str(id)
        status, response = uplink.get('/rest/program/' + id)
        if not status:
            print "> Couldn't fetch program #" + id + " (description error)."
            logger = logging.getLogger("logfile")
            logger.info(config.fileInfo() + ' - ' + "> Couldn't fetch program #" + id + " (description error).")
            return False 
        url, hash = response.split('\n')
        dir = config.antPath() + '/furnace/' + str(id)
        if os.path.exists(dir):
            shutil.rmtree(dir)
        os.mkdir(dir)
        if((url.split('.')[-1] != 'zip') and (url.split('.')[-1] != 'ZIP')):
            status = uplink.store_file(url, dir + '/start' + os.path.splitext(url)[1])
        else:
            status = uplink.store_file(url, dir + '/source' + os.path.splitext(url)[1])
            if status:
                unzip_file(dir + '/', dir + '/source' + os.path.splitext(url)[1])
        if not status:
            print "> Couldn't fetch program #" + id + " (download error)."
            return False
        open(config.antPath() + '/furnace/' + id + '/hash', 'w').write(hash)
        print "> Program #" + id + " fetched."
        return True
    print "> Program #" + id + " wasn't changed."
    return True

def run_unit(uplink, cfg):
    if config.getUnit==False:
        config.getUnit=True
        config.timeStart=time.time()
        time_unit_start= time.time()
        try:
            path = '/rest/node/' + cfg.get('node_id')
        except:
            path=''
        status, response = uplink.get(path)
        t1 = time.time()
        if not response:
            print 'Server is OFFLINE or Client has problem'
            logger = logging.getLogger("logfile")
            logger.info(config.fileInfo() + ' - ' + 'Server is OFFLINE or client problems')
            return False
        tmp =time.time()-t1
        if status:
            id, task_id, task_hash, params = response.split('\n')
            if  update_program(uplink, cfg, task_id, task_hash):
                print "> Fetched unit #"+id+" ok"
                result,time_ant_cpu,time_ant_code = run_programs(task_id, params)
                if result == '' or result.lower().find('error') != -1 or result.lower().find('python') != -1:
                    time.sleep(180)
                time_ant_code =time_ant_code+tmp
                print "~ Uploading..."
                if store_unit(uplink, cfg, id, result,time_unit_start, time_ant_code, time_ant_cpu):
                    config.getUnit=False                
        else:
            print "> Nothing fetched"
            logger = logging.getLogger("logfile")
            logger.info(config.fileInfo() + ' - ' + "> Nothing fetched")
    if (time.time()-config.timeStart>10) and (config.getUnit==True):
        config.getUnit=False
        

def update_hash(id, hash):
    hash_file = config.antPath() + '/furnace/' + id + '/hash'
    return not(os.path.exists(hash_file) and open(hash_file).read() == hash)

def run_programs(task_id,params):
    t1=time.time()
    folder = 'furnace/'+task_id+'/'
    filename = 'start'
    executable = filter(lambda x:os.path.splitext(x)[0] == filename, os.listdir(config.antPath()+'/'+folder))[0]
    file_ext = executable.split(".", len(executable) - len(filename))[1]
    if file_ext == 'py':
        program = 'python'
    else:
        program = ''
    if os.path.isfile(file_output):
        os.chmod(config.antPath()+'/'+folder+executable,0777)
        os.remove(file_output)
    os.chmod(config.antPath()+'/'+folder+executable,0777)
    file_run=config.antPath()+'/' + folder+ executable
    fullCmd = program +' '+ file_run + ' "' + params + '" '+file_output
    t2=time.time()
    os.system(fullCmd)
    #subprocess.call(fullCmd, shell=True)
    if os.path.isfile(file_output):
        result=open(file_output).read()
    else:
        result=''
    return result,time.time()-t2,t2-t1


def store_unit(uplink, cfg, id, result,time_unit_start, time_ant_code, time_ant_cpu):
    status, response = uplink.post('/rest/node/' + cfg.get('node_id'), {'id':id, 'result':result,'time_unit_start':time_unit_start, 'time_ant_code':time_ant_code,  'time_ant_cpu':time_ant_cpu})
    if status:
        pass
        #print "~ Complete!"
        logger = logging.getLogger("logfile")
        logger.info(config.fileInfo() + ' - ' + "~ Completed unit")
        return True
    else:
        print "~ Upload error."
        logger = logging.getLogger("logfile")
        logger.info(config.fileInfo() + ' - ' + "~ Upload error.")
        return False

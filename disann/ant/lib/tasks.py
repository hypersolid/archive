import os, shutil
import time
import config
import zipfile
import profile
import cProfile
import logging

file_output = config.antPath() + '/output/output.txt'

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

def update_program(uplink,cfg,id,hash=''):
    if update_hash(id,hash):
        id = str(id)
        status, response = uplink.get('/rest/program/'+id)
        if not status:
            print "> Couldn't fetch program #"+id+" (description error)."
            return False 
        url, hash = response.split('\n')
        dir = config.antPath() + '/furnace/' + str(id)
        if os.path.exists(dir):
            shutil.rmtree(dir)
        os.mkdir(dir)
        status = uplink.store_file(url, dir + '/program' + os.path.splitext(url)[1])
        if status:
            unzip_file(dir + '/', dir + '/program' + os.path.splitext(url)[1])

        if not status:
            print "> Couldn't fetch program #"+id+" (download error)."
            return False         
        open(dir+'/hash','w').write(hash)
        print "> Program #"+id+" fetched."
        return True
    print "> Program #"+id+" wasn't changed."
    return True

def run_unit(uplink,cfg):
    time_unit_start=time.time()
    time_ant_code=0
    time_ant_code_start=time.time()
    #Get catche
    dirList=os.listdir(config.antPath()+'/cache')
    arr=''
    for f in dirList:
        if f.split('.')[-1]=='zip':
            arr+=f.split('.')[0]+','
    arr=arr[0:-1]
    time_ant_code+=time.time()-time_ant_code_start
    status, response = uplink.get('/rest/node/'+cfg.get('node_id')+'/'+arr)
    if status:
        time_ant_code_start=time.time()
        id, task_id, task_hash, params,network,check_chunk = response.split('\n')
        print "> Fetched unit #"+id
        time_ant_code+=time.time()-time_ant_code_start
        if update_program(uplink,cfg,task_id,task_hash):
            # Store file data + file network
            time_ant_code_start=time.time()
            dir_cache = config.antPath() + '/cache'
            dir = config.antPath() + '/furnace/' + str(task_id)
            file_params_new=dir_cache + '/'+params.split('/')[-1]
            if int(check_chunk)==0:
                uplink.store_file(params,file_params_new )
            uplink.store_file(network, dir + '/train' + os.path.splitext(network)[1])
            time_ant_code+=time.time()-time_ant_code_start
            t1 = time.time()
            results,error=run_program(task_id,file_params_new,check_chunk)
            t2 = time.time()
            store_unit(uplink, cfg, id, results,time_unit_start, t2-t1,time_ant_code,error)
    else:
        print "> Nothing fetched"
        

def update_hash(id,hash):
    hash_file=config.antPath() +'/furnace/'+id+'/hash'
    return not( os.path.exists(hash_file) and open(hash_file).read()==hash )

def run_program(id,file_data,check_chunk):
    folder = 'furnace/'+id+'/'
    filename = 'start'
    executable = filter(lambda x:os.path.splitext(x)[0] == filename, os.listdir(config.antPath()+'/'+folder))[0]
    file_ext = executable.split(".", len(executable) - len(filename))[1]
    if file_ext == 'py':
        program = 'python'
    else:
        program = ''
    os.chmod(config.antPath()+'/'+folder+executable,0777)
    file_run=config.antPath()+'/' + folder+ executable
    file_net=config.antPath()+'/' + folder+ 'train.net'
    file_results=config.antPath()+'/' + folder+ 'results.wei'
    fullCmd = program +' '+ file_run +' '+file_net+' '+ file_data +' '+file_results+ ' '+str(int(check_chunk))
    os.system(fullCmd)
    results=open(file_results).read().split('\n')
    return results[0],results[1]

def store_unit(uplink, cfg, id, result,time_unit_start, time_ant_cpu=0,time_ant_code=0,error=0):
    status, response = uplink.post('/rest/node/'+cfg.get('node_id')+'/',{'id':id,'result':result,'time_unit_start':time_unit_start,'time_ant_cpu':time_ant_cpu,'time_ant_code':time_ant_code,'error':error})
    if status:
        pass
    else:
        print "~ Upload error."
        logger = logging.getLogger("logfile")
        logger.info(config.fileInfo() + ' - ' + "~ Upload error.")

def run_unit_time(uplink, cfg):
    cProfile.runctx('run_unit(uplink, cfg)',globals(), locals(), config.antPath() + '/output/profile.out')
    time_ant_cpu,time_ant_network,time_ant_hdd,time_ant_code,time_hill_code,time_mysql,check=profile.time_prof(config.antPath() + '/output/profile.out',0.00001,10)
    if check:
        status, response = uplink.post_profile('/rest/profile/' + cfg.get('node_id'), {'time_ant_cpu':time_ant_cpu, 'time_ant_network':time_ant_network,'time_ant_hdd':time_ant_hdd,'time_ant_code':time_ant_code,'time_hill_code':time_hill_code,'time_mysql':time_mysql})

def remove_dir(folder):
    import shutil
    try:
        for root, dirs, files in os.walk(folder):
            for f in files:
                os.remove(os.path.join(root, f))
            for d in dirs: 
                shutil.rmtree(os.path.join(root, d))
        return True
    except :
        return False
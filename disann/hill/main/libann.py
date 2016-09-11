from hill.main.models import *
from zipfile import ZipFile, ZIP_DEFLATED
import shutil,os
from contextlib import closing

def extract(zipfilepath, extractiondir):
    zip = ZipFile(zipfilepath)
    zip.extractall(path=extractiondir)

def zip(textfile_in,zipfile_out):
    # save the files in .zip file
    zout = ZipFile(zipfile_out, "w",compression=ZIP_DEFLATED,)
    zout.write(textfile_in)
    zout.close()

def zipdir(basedir, archivename):
    assert os.path.isdir(basedir)
    with closing(ZipFile(archivename, "w", ZIP_DEFLATED)) as z:
        for root, dirs, files in os.walk(basedir):
            #NOTE: ignore empty directories
            for fn in files:
                absfn = os.path.join(root, fn)
                zfn = absfn[len(basedir)+len(os.sep):] #XXX: relative path
                z.write(absfn, zfn)

def create_data(file_input,dir_output,dir_program_server):

    file_input = file_input.replace('\\','/')
    dir_output = dir_output.replace('\\','/')

    dir_program_server=dir_program_server.replace('\\','/')
    file_init_net=dir_program_server+'init_net.py'

    #Extract file zip
    extract(file_input,dir_output)
    z = ZipFile(file_input, "r")
    for filename in z.namelist():
        file_input_txt =dir_output+filename
            
    input = open(file_input_txt, 'r').read().split('\n')
    line=input[0].split()
    epochs=int(line[0])
    num_input=int(line[1])
    num_hidden=int(line[2])
    num_output=int(line[3])
    num_patterns=int(line[4])
    num_block=int(line[5])
    epochs_client=int(line[6])
    auto_convert=int(line[7])

    #Write to config data
    f_config=open(dir_output+'/config.txt','w')
    f_config.write('Epochs=%s\n'%epochs)
    f_config.write('Number input=%s\n'%num_input)
    f_config.write('Number hidden=%s\n'%num_hidden)
    f_config.write('Number output=%s\n'%num_output)
    f_config.write('Number patterns=%s\n'%num_patterns)
    f_config.write('Number pattern in block=%s\n'%num_block)
    f_config.write('Epochs in client=%s\n'%epochs_client)
    f_config.write('Auto convert data=%s\n'%auto_convert)
    f_config.close()
    f_unit_net=open(dir_output+'/unit_net.txt','w')

    #Init net to write weights to file unit_net
    file_net_tmp_server=dir_program_server+'server.net'
    file_weights=dir_program_server+'weights.wei'
    if auto_convert==1:
        #When init net => auto convert data
        path_cmd='python '+file_init_net+' '+file_net_tmp_server+' '+str(num_input)+ ' '+str(num_hidden)+' '+str(num_output)+' '+file_weights+' '+file_input_txt
    else:
        path_cmd='python '+file_init_net+' '+file_net_tmp_server+' '+str(num_input)+ ' '+str(num_hidden)+' '+str(num_output)+' '+file_weights
    os.system(path_cmd)
    #Get weights from file after init net
    weights_server=open(file_weights,'r').read()
    weights_server='['+weights_server.replace(' ',',')+']'


    import array
    result=eval(weights_server)
    a = array.array('f', result)
    a= a.tostring()
    weights_server=a

    splitLen = num_block #lines per file
    outputBase = 'train_' # train1.zip, train2.zip, etc.
    os.chdir(dir_output)

    if num_patterns % num_block ==0:
        count_block=int(num_patterns/num_block)
    else:
        count_block=int(num_patterns/num_block)+1

    at = 1
    for lines in range(1, num_patterns, splitLen):
        # First, get the list slice
        outputData = input[lines:lines+splitLen]
        #Real number of patterns
        tmp=len(outputData)
        # Now open the output file, join the new slice with newlines
        # and write it out. Then close the file.
        output = open(outputBase + str(at) + '.txt', 'w')
        output.write('%s %s %s %s %s\n'%(tmp,num_input,num_hidden,num_output,epochs_client))
        output.write('\n'.join(outputData))
        output.close()
        #Zip file and remove text file
        #zip(outputBase + str(at) + '.txt',outputBase + str(at) + '.zip')
        if at<count_block:
            f_unit_net.write('%s\n'%(dir_output+outputBase + str(at) + '.txt'))
        else:
            f_unit_net.write('%s'%(dir_output+outputBase + str(at) + '.txt'))
        #os.remove(outputBase + str(at) + '.txt')
        # Increment the counter
        at += 1
    f_unit_net.close()
    #Remove file
    os.remove(file_input_txt)
    return epochs,num_input,num_hidden,num_output,count_block,weights_server

def create_unit(t,flag=0):
    #Create folder program/task_id
    temp_program=settings.MEDIA_ROOT_PROGRAM+str(t.id)+'/'
    if not os.path.exists(temp_program):
        os.makedirs(temp_program)

    #Create folder params/task_id
    temp_param=settings.MEDIA_ROOT_PARAM+str(t.id)+'/'
    if not os.path.exists(temp_param):
        os.makedirs(temp_param)

    #Copy data to folder task
    link_data=str(t.params.path).replace('\\','/')

    #Set file name: filename_taskid_0.zip
    file_param=temp_param + 'data.zip'
    #Change file
    if not os.path.isfile(file_param):
        shutil.copy(link_data,file_param)
        os.remove(link_data)

    #Copy program to folder task
    link_program=str(t.program.path).replace('\\','/')
    #Set file name: filename_taskid_0.zip
    file_program=temp_program + 'program.zip'
    #Change file
    if not os.path.isfile(file_program):
        shutil.copy(link_program,file_program)
        os.remove(link_program)

    #Extract file program
    weights_server=''
    extract(file_program,temp_program)
    #Program on server in folder server
    dir_program_server=temp_program+'server/'
    #Program on client in folder client
    file_program=temp_program+'client/client.zip'
    if not os.path.isfile(temp_program+'client/client.zip'):
        zipdir(temp_program+'client',temp_program+'client.zip')
        shutil.copy(temp_program+'client.zip',temp_program+'client/client.zip')
        os.remove(temp_program+'client.zip')

    if (file_param.split('.')[-1]=='zip') or (file_param.split('.')[-1]=='ZIP'):
        epochs,num_input,num_hidden,num_output,count_block,weights_server =create_data(file_param,temp_param,dir_program_server)
        t.params=file_param
        t.program=file_program
        t.number_epochs =epochs
        t.number_input=num_input
        t.number_hidden = num_hidden
        t.number_output =num_output
        t.number_blocks =count_block
        t.save()
        if flag==0:
            #Create unit
            t.validate(temp_param+'unit_net.txt',weights_server)
        else:
            t.restart(temp_param+'unit_net.txt',weights_server)
    else:
        print 'Error'

    return weights_server


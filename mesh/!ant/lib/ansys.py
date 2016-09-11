import os
import shutil
def run_ansys(root,input_file, parameters = {}, dry_run = False):
    bin = '%ans%'
    root =root.replace("\\", "/")+'/'
    ansys= bin + ' -p ansys -dir ' + root + 'workdir '
    ansys+= '-i ' + root + 'script/'+input_file+'.dat '
    ansys+= '-o ' + root + 'workdir/output.txt '
    result = ''

    for k in parameters:
        result+="-%s %s " % (k[0],k[1])
    call = ansys+' -b '+result
    if not dry_run:
        try:
            os.remove(root + 'workdir/file.lock')
        except :
            pass
    if not dry_run:
        os.system(call)
    return open(root + 'workdir/data.dat').read()
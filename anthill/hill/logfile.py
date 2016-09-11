import os
def hillPath():
    #Get path of ant
    root = os.path.dirname(os.path.realpath(__file__))
    root=root.replace('\\','/')
    return root

def create_logFile():
    #Crete logfile
    import logging
    #check last line logfile
    pathLogFile=hillPath()+'/logfile.txt'

    #Only 12.0000 lines
    max_line=12000
    if os.path.isfile(pathLogFile):
        l_file=open(pathLogFile, 'r').readlines()
        if len(l_file)>max_line:
            n_file=l_file[len(l_file)-(max_line+1):len(l_file)-1]
            f=open(pathLogFile,'w')
            for line in n_file:
                f.write('%s'%line)
            f.close()

    st=''
    if os.path.isfile(pathLogFile):
        st=open(pathLogFile, 'r').read().split('-')[-1]
    if st.strip()=='START HILL':
        #create logger
        #create logger with "hill_logfile"
        logger = logging.getLogger("hill_logfile")
        fh = logging.FileHandler(pathLogFile)
        #create formatter
        #fh.setLevel(logging.INFO)
        formatter = logging.Formatter("%(asctime)s - %(message)s")
        #add formatter to fh
        fh.setFormatter(formatter)
        #add fh to logger
        logger.addHandler(fh)
        logger.setLevel(logging.INFO)
    else:
        #create logger
        #create logger with "hill_logfile"
        logger = logging.getLogger("hill_logfile")
        fh = logging.FileHandler(pathLogFile)
        #create formatter
        #fh.setLevel(logging.INFO)
        formatter = logging.Formatter("%(asctime)s - %(message)s")
        #add formatter to fh
        fh.setFormatter(formatter)
        #add fh to logger
        logger.addHandler(fh)
        logger.setLevel(logging.INFO)
        logger = logging.getLogger("hill_logfile")
        logger.info('START HILL')


def fileInfo():
    import sys
    return sys._getframe(1).f_code.co_filename+' - function:'+sys._getframe(1).f_code.co_name+' - line:'+str(sys._getframe(1).f_lineno)

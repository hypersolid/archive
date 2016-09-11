from xml.dom.minidom import parse
import os
def antPath():
    #Get path of ant
    root = os.path.realpath(__file__)
    root = root.replace('\\', '/')
    root = '/'.join(root.split('/')[:-2])
    return root

def logFile():
    #Crete logfile
    import logging
    #create logger
    #create logger with "logfile"
    pathLogFile = antPath() + '/logfile.txt'
    #Only 10000 lines
    max_line = 10000
    if os.path.isfile(pathLogFile):
        l_file = open(pathLogFile, 'r').readlines()
        if len(l_file) > max_line:
            n_file = l_file[len(l_file) - (max_line + 1):len(l_file) - 1]
            f = open(pathLogFile, 'w')
            for line in n_file:
                f.write('%s' % line)
            f.close()
    logger = logging.getLogger("logfile")
    fh = logging.FileHandler(pathLogFile)
    #create formatter
    formatter = logging.Formatter("%(asctime)s - %(message)s")
    #add formatter to fh
    fh.setFormatter(formatter)
    #add fh to logger
    logger.addHandler(fh)
    logger.setLevel(logging.INFO)
    logger.info("START ANT")

def fileInfo():
    import sys
    return sys._getframe(1).f_code.co_filename + ' - function:' + sys._getframe(1).f_code.co_name + ' - line:' + str(sys._getframe(1).f_lineno)

class Config:
    config = parse(antPath() + '/config.xml')
    def get(self, tag):
        try:
            return self.getText(self.config.getElementsByTagName(tag)[0])
        except:
            return None
        
    def set(self, name, value):
        tag = self.config.createElement(name)
        tag.appendChild(self.config.createTextNode(value))
        self.config.getElementsByTagName('root')[0].appendChild(tag)
        open('config.xml', 'w').write(self.config.toxml())
        
    def getText(self, nodelist):
        rc = []
        nodelist = nodelist.childNodes
        for node in nodelist:
            if node.nodeType == node.TEXT_NODE:
                rc.append(node.data)
        return ''.join(rc)




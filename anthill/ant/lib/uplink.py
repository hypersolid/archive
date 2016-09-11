import httplib, urllib
import logging, config

class Uplink:
    connection = None

    def __init__(self, cfg):
        self.url = cfg.get('server')
        self.connection = httplib.HTTPConnection(self.url)
        self.trigger = False
        print '> Server:', self.url
        #logger = logging.get#logger("logfile")
        #logger.info(config.fileInfo() + ' - ' + '> Server:' + self.url)
        
    def __del__(self):
        try:
            self.connection.close()
        except:
            pass

    def reconnect(self):
        self.connection = httplib.HTTPConnection(self.url)
        self.trigger = False

    def post(self, path, params_dict):
        if self.trigger:
            self.reconnect()
        try:
            params = urllib.urlencode(params_dict)
            headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}
            self.connection.request("POST", path, params, headers)
            response = self.connection.getresponse()
            data = response.read()
            s = (response.status < 500)
            if not s:
                open('error.html', 'w').write(data)
                #logger = logging.get#logger("logfile")
                #logger.info(config.fileInfo() + ' - ' + data)
            return s, data
        except:
          self.trigger = True
          return False, False

    def post_profile(self, path, params_dict):
        params = urllib.urlencode(params_dict)
        headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}
        self.connection.request("POST", path, params, headers)
        response = self.connection.getresponse()
        data = response.read()
        s = (response.status < 500)
        return s, data

    def get(self, path):
        if self.trigger:
            self.reconnect()
        try:
            self.connection.request("GET", path)
            result = self.connection.getresponse()
            data = result.read()
            s = (result.status < 500)
            if not s:
                open('error.html', 'w').write(data)
                #logger = logging.get#logger("logfile")
                #logger.info(config.fileInfo() + ' - can not get ' + path)
            return s, data
        except:
          self.trigger = True
          return False, False


    def store_file(self, url, path):
        try:
            open(path, 'wb').write(urllib.urlopen(url).read())
            return True
        except:
            return False

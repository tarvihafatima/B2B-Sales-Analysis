# -*- coding: utf-8 -*-
"""
Created on Mon Oct 10 00:50:58 2022

@author: Tarviha.Fatima
"""
######## Import Required Python Libraries ########## 

import re
import logging, platform
import socket
from user_agents import parse
import requests
import textwrap
from getuseragent import UserAgent
from datetime import datetime

url = 'https://api64.ipify.org'


class HttpFormatter(logging.Formatter):   
    def _formatHeaders(self, d):
        return ' '.join(f'{k}: {v}' for k, v in d.items())
    def formatMessage(self, record):
        result = super().formatMessage(record)
        response = requests.get(url, stream=True) 
        # ''' + str(len(response)) + '''
        if record.name == 'httplogger':
            result += textwrap.dedent('''"{req.method} {req.url}" {res.status_code} ''' + str(len(response.content)) + ''' "{res.url}"''').format(
                req=record.req,
                res=record.res,
                reqhdrs=self._formatHeaders(record.req.headers),
                reshdrs=self._formatHeaders(record.res.headers),
            )
        return result
    
######## Get Hostname ########## 
    
class HostnameFilter(logging.Filter):
    hostname = platform.node()
    
    if hostname is None:
        hostname = '-'

    def filter(self, record):
        record.hostname = HostnameFilter.hostname
        return True
    
######## Get Host IP ########## 
    
class HostipFilter(logging.Filter):
    hostip = socket.gethostbyname(socket.gethostname())

    def filter(self, record):
        record.hostip = HostipFilter.hostip
        return True

######## Get Host User Identity ########## 
    
class identityFilter(logging.Filter):
    # N = 6
    # res = ''.join(random.choices(string.ascii_uppercase +
    #                          string.digits, k=N))
    # identity = str(res)
    response = requests.get(url, stream=True) 
    r=requests.get(url,headers={"Content-Type":"text"})
    identity = r.request.headers.get('user')
    
    if identity is None:
        identity = '-'

    def filter(self, record):
        record.identity = identityFilter.identity
        return True
    
######## Get User Agent ########## 
    
class useragentFilter(logging.Filter):
    
    #ua_string = 'BlackBerry9700/5.0.0.862 Profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/331 UNTRUSTED/1.0 3gpp-gba'
    useragent = UserAgent()
    r=requests.get(url, headers={"Content-Type":"text"})
    ua_string = r.request.headers.get('user-agent')
    user_agent = parse(ua_string)
    useragent = user_agent.browser
    

    def filter(self, record):
        record.useragent = useragentFilter.useragent
        return True


Status = False
Return_Arg="Before Start"

f = open("WebLog - Data Fetch - Logfile.txt", "a")
try:

    handler = logging.StreamHandler()
    
    ######## Add Hostname, Host IP, User Identity, User Agent in Handler ########## 
    
    handler.addFilter(HostnameFilter())
    handler.addFilter(HostipFilter())
    handler.addFilter(identityFilter())
    handler.addFilter(useragentFilter())
    
    f.write(str(datetime.now())+" Added Hostname, Host IP, User Identity, User Agent in Handler\n")  
    
    ######## Set a Format for logging ########## 
    
    formatter = HttpFormatter('{hostip} {identity} {hostname} {asctime} "{useragent}" ' ,datefmt='[%d/%b/%Y:%H:%M:%S]' , style='{')
    logger = logging.getLogger('httplogger')
    handler.setFormatter(formatter)

    f.write(str(datetime.now())+" Set a Format for logging\n") 
    
    ######## Adding the handler to the logger ##########
    
    logger.addHandler(handler)
                                 
    f.write(str(datetime.now())+" Added the handler to the logger\n") 
    
                                  
    def logRoundtrip(response, *args, **kwargs):
        extra = {'req': response.request, 'res': response}
        logger.info('HTTP roundtrip', extra=extra)
        
        
    session = requests.Session()
    session.hooks['response'].append(logRoundtrip)

    session.get(url)

    ######## Adding a file handler to log in a txt file ##########
    
    fileHandler = logging.FileHandler(filename='Weblog Data_stg.txt')
    fileHandler.setFormatter(formatter)
    fileHandler.setLevel(level=logging.INFO)
    logger.addHandler(fileHandler)    
    
    logging.basicConfig(level=logging.INFO, handlers=[fileHandler,handler])
                                    
    f.write(str(datetime.now())+" Added a file handler to log in a txt file\n") 

    ######## Writing the log in a file ##########
    
    with open('Weblog Data_stg.txt','r') as f2:
        line = ''
        last_line =''
        for line in f2:
            if len(line) == 0:
                line = ' '
            pass
            last_line = line
        if len(last_line) > 1:
            occurence = [i.start() for i in re.finditer('"', last_line)]
            new_last_line = last_line[0:occurence[0]] + last_line[(occurence[1]+2):-1] + last_line[(occurence[0]-1):(occurence[1]+1)]
            file1 = open('Weblog Data.txt', "a+") # append mode
            #data = file1.read(2)
            #if len(data) > 0 :
            #    file1.write("\n")
            file1.write("\n" + new_last_line)
            file1.close()
                                     
    f.write(str(datetime.now())+" Written the logs in WebLog File \n")    

except ValueError as e:
    print('--------------------Error Occurred in process ---------------------- \n'+ str(e))   
    
    ######## Logging Errors in Text File ##########  
    
    f.write(str(datetime.now())+" [Error]: Exception occurred in process \n "+str(e)+"\n")   
    f.close()
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  7 22:48:09 2022

@author: Tarviha.Fatima
"""

import json
import os
from datetime import datetime   
import geocoder
import pandas as pd
import psycopg2
from user_agents import parse

class Load_WebLog_Data():
    
    config_dict = dict()

    def Read_Configuration(self , FileName):
        parent_dir = os.path.split(os.path.split(os.path.dirname(__file__))[0])[0]

        if not os.path.isfile(parent_dir+"/"+FileName):
            return False , FileName +' file does not exist at ' +os.getcwd() + '/'
        
        JsonFile = open(parent_dir+"\\"+FileName).read()
        
        try:
            self.config_dict = json.loads(JsonFile)
            
        except ValueError as e:
            
            return False, FileName +': Decoding JSON has failed \nInformation: ' + str(e)
        
        return True , ''  
    
 

    def get_location(self, ip_address):
        
        ######## Get Location from IP Address ##########  
        ip = geocoder.ip(ip_address)

        return ip.city, ip.country, ip.state, ip.postal, ip.latlng, ip.street, ip.housenumber
    
    
    def Process_Data(self,Config_FileName):

        Status = False
        Return_Arg="Before Start"
        
        f = open("WebLog - Data Load - Logfile.txt", "a")
        try:
            
            ######### Reading JSON Config ################
            Status , Return_Arg = self.Read_Configuration(Config_FileName) 
            f.write(str(datetime.now())+" Read Configurations from File\n") 
            
            if Status:
                
                ######## Creating PostgresSQL Connection ##########
                PostgresWebLogConfig = self.config_dict['PostgresDBCredentials']
                PostgresWebLogconn = psycopg2.connect(**PostgresWebLogConfig)
                PostgresWebLogcursor = PostgresWebLogconn.cursor()

                f.write(str(datetime.now())+" Connected to Postgres Successfully\n") 
                
                ######## Reading WebLog File ##########
                WebLogFilePath = self.config_dict['Paths']["weblog_path"] + 'WebLog Data.txt'
                df = pd.read_csv(WebLogFilePath, sep=" ")
                
                f.write(str(datetime.now())+" Connected File " + WebLogFilePath + " to Read Data\n") 
                                  
                ######## Creating Database Dump Statements ##########                    
                drop_statement = "drop table if exists b2bstagingdb.WebLog_Staging;"
                create_statement = "create table b2bstagingdb.WebLog_Staging (ClientIP varchar(15) not null, UserName varchar(50), Time varchar(50) not null, UserAgent varchar(200) not null, country varchar(100), region varchar(100), city varchar(100), postalcode varchar(50), longitude varchar(50), latitude varchar(50), street varchar(100), housenumber varchar(50), Device varchar(10));"
                insert_statement_stg = "Insert into b2bstagingdb.WebLog_Staging (ClientIP, UserName, Time, UserAgent, Country, Region, City, postalcode, longitude, latitude, street, housenumber, Device) values "
 
                f.write(str(datetime.now())+" Reading WebLog Data Line by Line\n")    
                
                ######## Reading WebLog Data Line by Line ##########                     
                for index, row in df.iterrows():
                    ClientIP = row['ClientIP']
                    UserName = row['username']
                    Time = row['time']
                    UserAgent = row['user_agent'].replace("'", "")
                    Device="-"
                    
                    
                    ####### Getting Device from User-Agent ##########  
                    user_agent = parse(UserAgent)
                    if (user_agent.is_mobile):
                        Device = "mobile"
                    if (user_agent.is_tablet):
                        Device = "tablet"
                    if (user_agent.is_pc):
                        Device = "pc"
                    if (user_agent.is_bot):
                        Device = "bot"
                    
                    ######## Getting Location from IP address ##########  
                    city, country, region, postalcode, latlng, street, housenumber = self.get_location(str(ClientIP))                    
                    
                    try:
                        longitude = latlng[0]
                        latitude = latlng[1]
                    except:
                        longitude = None
                        latitude = None                     
                    
                    insert_statement_stg = insert_statement_stg + "('" + str(ClientIP) + "','" + str(UserName) + "','" + str(Time) + "','" + str(UserAgent) + "','" + str(country).replace("'", "") + "','" + str(region).replace("'", "") + "','" + str(city).replace("'", "") + "','" + str(postalcode).replace("'", "") + "','" + str(longitude) + "','" + str(latitude) + "','" + str(street).replace("'", "") + "','" + str(housenumber).replace("'", "") +  "','" + str(Device) + "'),"
                
                ######## Inserting Weblog Data into Staging Table ##########              
                insert_statement_stg = insert_statement_stg[0:-1] + ";"
                PostgresWebLogcursor.execute(drop_statement)
                PostgresWebLogcursor.execute(create_statement)
                PostgresWebLogcursor.execute(insert_statement_stg)
                PostgresWebLogconn.commit()
                
                f.write(str(datetime.now())+" Data Loaded into weblog Table\n") 
                              
            else:
                print( Return_Arg, "Cannot Read Config file")
        except ValueError as e:
            print('--------------------Error Occurred in process ---------------------- \n'+ str(e))   
            
            ######## Logging Errors in Text File ##########  
            f.write(str(datetime.now())+" [Error]: Exception occurred in process \n "+str(e)+"\n")   
            f.close()
 
        return Status , Return_Arg
    
    
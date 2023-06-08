# -*- coding: utf-8 -*-
"""
Created on Fri Oct  7 22:48:09 2022

@author: Tarviha.Fatima
"""

import json
import os
from datetime import datetime   
import psycopg2
import csv


class Load_Marketing_Data():
    
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
    
    
    def Process_Data(self,Config_FileName):

        Status = False
        Return_Arg="Before Start"
        
        f = open("Marketing Lead - Data Load - Logfile.txt", "a")
        try:
            
            ######### Reading JSON Config ################
            Status , Return_Arg = self.Read_Configuration(Config_FileName) 
            f.write(str(datetime.now())+" Read Configurations from File\n") 
            
            if Status:
                
                ######## Creating PostgresSQL Connection ##########
                PostgresWebLogConfig = self.config_dict['PostgresDBCredentials']
                PostgresWebLogconn = psycopg2.connect(**PostgresWebLogConfig)
                PostgresWebLogcursor = PostgresWebLogconn.cursor()
                
                PostgresWebLogconn.autocommit= True

                f.write(str(datetime.now())+" Connected to Postgres Successfully\n") 

                                   
                ######## Creating Database Dump Statements ##########        
                dropstatement = '''DROP TABLE IF EXISTS b2bstagingdb.marketinglead;'''

                createstatement = '''CREATE TABLE b2bstagingdb.marketinglead (First_Contact_Date varchar(20),	Username varchar(50), Contact_Name varchar(50),	City varchar(50), Country varchar(50),	Lead_Source varchar(50), Status varchar(50));'''

                PostgresWebLogcursor.execute(dropstatement)
                PostgresWebLogcursor.execute(createstatement)
                
                with open(self.config_dict['Paths']["marketing_path"] + 'Marketing Lead Spreadsheet.csv', 'r') as f2:
                    reader = csv.reader(f2)
                    next(reader) # Skip the header row.
                    for row in reader:
                        PostgresWebLogcursor.execute(
                        "INSERT INTO b2bstagingdb.marketinglead VALUES (%s, %s, %s, %s, %s, %s, %s)",
                        row
                    )
                  
                
                f.write(str(datetime.now())+" Data Loaded into Marketing Lead Table\n") 
                  
                PostgresWebLogconn.commit()
                PostgresWebLogconn.close()
                
                                              
       
        except ValueError as e:
            print('--------------------Error Occurred in process ---------------------- \n'+ str(e))   
            
            ######## Logging Errors in Text File ##########  
            f.write(str(datetime.now())+" [Error]: Exception occurred in process \n "+str(e)+"\n")   
            f.close()
 
        return Status , Return_Arg
    
  
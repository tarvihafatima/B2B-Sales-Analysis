"""
Created on Fri Oct  7 22:48:09 2022

@author: Tarviha.Fatima
"""

import json
import os
import csv
import psycopg2

class Load_Location_Data():
    
    config_dict = dict()

    def Read_Configuration(self , FileName):

        if not os.path.isfile(os.getcwd()+"\\"+FileName):
            return False , FileName +' file does not exist at ' +os.getcwd() + '/'
        
        JsonFile = open(FileName).read()
        
        try:
            self.config_dict = json.loads(JsonFile)
            
        except ValueError as e:
            
            return False, FileName +': Decoding JSON has failed \nInformation: ' + str(e)
        
        return True , ''  
    
    
    def Process_Data(self,Config_FileName):

        Status = False
        Return_Arg="Before Start"
        try:
            
            ######### Reading JSON Config ################
            Status , Return_Arg = self.Read_Configuration(Config_FileName)
 
            if Status:
  
                ######## Creating PostgresSQL Connection ##########
                PostgresConfig = self.config_dict['PostgresDBCredentials']
                Postgresconn = psycopg2.connect(**PostgresConfig)
                Postgrescursor = Postgresconn.cursor()
                
                Postgrescursor.execute(
                "Drop table if exists b2bstagingdb.location; Create Table b2bstagingdb.location (longitude varchar(200), latitude varchar(200), housenumber varchar(200), street varchar(200), unit varchar(200), city varchar(200), district varchar(200), region varchar(200), postalcode varchar(200), id varchar(200), hash varchar(200), country varchar(200));"
            )   
                Postgresconn.commit() 
                ######## Reading Location Path ##########

                LocationPath = self.config_dict['Paths']["location_path"]             
                directory = os.path.join(LocationPath)
                for root,dirs,files in os.walk(directory):
                    for file in files:
                       if file.endswith(".csv"):
                            f=open(directory+file, 'r')
                            reader = csv.reader(f)
                            next(reader) # Skip the header row.
                            for row in reader:
                                country =file.replace('.csv', '')
                                row.append(country)
                                Postgrescursor.execute(
                                "INSERT INTO b2bstagingdb.location (longitude, latitude, housenumber, street, unit, city, district, region, postalcode, id, hash, country) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",row
                            )   
                                Postgresconn.commit()                         
                                            
                            f.close()
                Postgrescursor.execute(
                "INSERT INTO b2btargetdb.d_location (longitude, latitude, housenumber, street, city, region, postalcode, country) select longitude::float, latitude::float, housenumber, street, city, region, postalcode, country from b2bstagingdb.location;"
            )    
                Postgresconn.commit()  
                Postgresconn.close()   
        except ValueError as e:
            print('--------------------Error Occurred in process ---------------------- \n'+ str(e))               
 
        return Status , Return_Arg
                    
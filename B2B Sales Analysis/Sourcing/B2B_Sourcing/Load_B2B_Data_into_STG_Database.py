# -*- coding: utf-8 -*-
"""
Created on Fri Oct  7 22:48:09 2022

@author: Tarviha.Fatima
"""

import json
import os
from datetime import datetime   
import psycopg2
from mysql.connector import MySQLConnection


class Load_B2B_Data():
    
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
        
        f = open("B2B - Data Load - Logfile.txt", "a")
        try:
            
            ######### Reading JSON Config ################
            Status , Return_Arg = self.Read_Configuration(Config_FileName)
 
            if Status:
 
                f.write(str(datetime.now())+" "+"Read Configurations from File\n")   
                
                ######## Creating PostgresSQL Connection ##########
                PostgresConfig = self.config_dict['PostgresDBCredentials']
                Postgresconn = psycopg2.connect(**PostgresConfig)
                Postgrescursor = Postgresconn.cursor()
                                              
                f.write(str(datetime.now())+" "+"Connected to Postgres Successfully\n")   
                
                ######## Creating MySQL Connection ##########
                MySQLConfig = self.config_dict['MysqlDBCredentials']
                MySQLconn = MySQLConnection(**MySQLConfig)
                MySQLcursor = MySQLconn.cursor()

                f.write(str(datetime.now())+" "+"Connected to Mysql Successfully\n")   
                                       
                ######## Get Data Lag ##########
                lag = str(self.config_dict['DataLag'])
                

                 
                ######## Truncate Staging Tables ##########     
                truncate_statement = "delete from b2bstagingdb.orderitems;"
                Postgrescursor.execute(truncate_statement) 
                truncate_statement = "delete from b2bstagingdb.ordertable;"
                Postgrescursor.execute(truncate_statement) 
                truncate_statement = "delete from b2bstagingdb.companycatalog;"
                Postgrescursor.execute(truncate_statement)
                truncate_statement = "delete from b2bstagingdb.suppliercatalog;"
                Postgrescursor.execute(truncate_statement)                  
                truncate_statement = "delete from b2bstagingdb.supplier;"
                Postgrescursor.execute(truncate_statement)
                truncate_statement = "delete from b2bstagingdb.company;"
                Postgrescursor.execute(truncate_statement)                
                truncate_statement = "delete from b2bstagingdb.customer;"
                Postgrescursor.execute(truncate_statement)
                truncate_statement = "delete from b2bstagingdb.product;"
                Postgrescursor.execute(truncate_statement)
                
                f.write(str(datetime.now())+" "+"Staging Tables Truncated\n")   
                
                
                ######## Company ########## 
                
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select CUITNumber, Name, username from b2bsourcedb.company where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.company (CUITNumber, Name, username) VALUES (%s, %s, %s)", \
                     (row[0], row[1], row[2]))
                    Postgresconn.commit()  
                
                f.write(str(datetime.now())+" "+"Data loaded into Company Statging Table\n")     
    
                   
                ######## Supplier ########## 
                
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select * from b2bsourcedb.supplier where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.supplier (SupplierID, CUITNumber) VALUES (%s, %s)", \
                      (row[0], row[1]))
                    Postgresconn.commit()           

                f.write(str(datetime.now())+" "+"Data loaded into Supplier Statging Table\n")                        
                        
                                 
                ######## Customer ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select DocumentNumber, FullName, DateOfBirth from b2bsourcedb.customer where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.customer (DocumentNumber, FullName, DateOfBirth) VALUES (%s, %s, %s)", \
                     (row[0], row[1], row[2]))
                    Postgresconn.commit()    
                    
                f.write(str(datetime.now())+" "+"Data loaded into Customer Statging Table\n")    
                                            
                    
                ######## Product ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select productid, productname, expirydate from b2bsourcedb.product where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.product (productid, productname, expirydate) VALUES (%s, %s, %s)", \
                     (row[0], row[1], row[2]))
                    Postgresconn.commit()    

                f.write(str(datetime.now())+" "+"Data loaded into Product Statging Table\n")  

                                    
                ######## CompanyCatalog ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select CompanyProductID, CUITNumber, ProductID, Price from b2bsourcedb.companycatalog where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.companycatalog (CompanyProductID, CUITNumber, ProductID, Price) VALUES (%s, %s, %s, %s)", \
                     (row[0], row[1], row[2], row[3]))
                    Postgresconn.commit()    

                f.write(str(datetime.now())+" "+"Data loaded into Company Catalog Statging Table\n")

                                                         
                ######## SupplierCatalog ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select SupplierProductID,SupplierID, ProductID, Price, AvailableQuantity from b2bsourcedb.suppliercatalog where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.suppliercatalog (SupplierProductID,SupplierID, ProductID, Price, AvailableQuantity) VALUES (%s, %s, %s, %s, %s)", \
                     (row[0], row[1], row[2], row[3], row[4]))
                    Postgresconn.commit()    

                f.write(str(datetime.now())+" "+"Data loaded into Supplier Catalog Statging Table\n")
                    
                                                         
                ######## Order ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select OrderNumber,OrderDateTime,OrderStatus,CustomerID,CompanyCUITNumber from b2bsourcedb.ordertable where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.ordertable (OrderNumber,OrderDateTime,OrderStatus,CustomerID,CompanyCUITNumber) VALUES (%s, %s, %s, %s, %s)", \
                     (row[0], row[1], row[2], row[3], row[4]))
                    Postgresconn.commit()    

                f.write(str(datetime.now())+" "+"Data loaded into Order Staging Table\n")

                                                         
                ######## OrderItems ########## 
 
                ######## Get Data from MySQL DB ##########                     
                select_statement = "select OrderItemNumber,OrderNumber,ProductID,SupplierID,ItemQuantity from b2bsourcedb.orderitems where last_updated = date_sub(curdate(), interval " + lag + " day) ;"
                MySQLcursor.execute(select_statement)

                ######## Populate B2B Data into Staging Table ##########
                for row in MySQLcursor.fetchall():
                    Postgrescursor.execute("INSERT INTO b2bstagingdb.orderitems (OrderItemNumber,OrderNumber,ProductID,SupplierID,ItemQuantity) VALUES (%s, %s, %s, %s, %s)", \
                     (row[0], row[1], row[2], row[3], row[4]))
                    Postgresconn.commit()    
                    
                f.write(str(datetime.now())+" "+"Data loaded into Order Items Statging Table\n")
                
        
                Postgresconn.close()
                MySQLconn.close()
                
                f.write(str(datetime.now())+" "+"MySQL and Postgres Connections Closed \n")
            else:
                print( Return_Arg, "Cannot Read Config file")
        except ValueError as e:
            print('--------------------Error Occurred in process ---------------------- \n'+ str(e))   
            
            ######## Logging Errors in Text File ##########  
            f.write(str(datetime.now())+" "+" [Error]: Exception occurred in process \n "+str(e)+"\n")   
            f.close()
 
        return Status , Return_Arg
    
    
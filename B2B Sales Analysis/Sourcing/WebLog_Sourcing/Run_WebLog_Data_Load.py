# -*- coding: utf-8 -*-
"""
Created on Fri Oct  7 23:49:32 2022

@author: Tarviha.Fatima
"""

import Load_WebLog_Data_into_Database

p = Load_WebLog_Data_into_Database.Load_WebLog_Data()
Status , Return_Arg = p.Process_Data("Configs.json")

# pip uninstall pandas -y
# pip uninstall numpy -y
# pip install pandas
# pip install numpy
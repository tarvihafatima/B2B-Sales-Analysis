# -*- coding: utf-8 -*-
"""
Created on Fri Oct  7 23:49:32 2022

@author: Tarviha.Fatima
"""

import Load_B2B_Data_into_STG_Database

p = Load_B2B_Data_into_STG_Database.Load_B2B_Data()
Status , Return_Arg = p.Process_Data("Configs.json")

# pip uninstall pandas -y
# pip uninstall numpy -y
# pip install pandas
# pip install numpy
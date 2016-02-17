#!/usr/bin/python

import sys
import csv
import pandas as pd
conc=[]
path=[]
my_matrix=[]
def get_config():
	with open("ccc") as fp:
		 for a_line in fp:
			if a_line is not None:
				line = a_line.rstrip().replace('/index.html:Number of clients              : ',' ').replace('<br>','')
				print line
				a_list = line.split(" ")
				my_matrix.append(a_list)

	
	
	my_df = pd.DataFrame(my_matrix)
	my_df.to_csv('Test_Config.txt', sep=" ", index=False, header=False)	
get_config()


#!/usr/bin/python

import sys
import csv
import pandas as pd
workloads=[]
tp=[]
rs=[]
def csv2dat():
	with open("TPRS.csv") as fp:
		 for a_line in fp:
			line = a_line.rstrip()
			if 'Workload' in line:
				workloads = line.split(' ')
				print workloads
			elif 'TP' in line:
				tp = line.split(' ')
				print tp
			elif 'RT' in line:
				rs = line.split(' ')
				print rs
			else:
				pass
	n_test = len(tp)
	my_list = []
	for i in xrange(1, n_test):
		my_list.append([workloads[i], rs[i], tp[i]])
	#with open("TPRS.dat", "wb") as outfile:
	#	wr = csv.writer(outfile, delimiter=',', lineterminator='\n' )
	#	wr.writerow(my_list)		
	my_df = pd.DataFrame(my_list)
	my_df.to_csv('TPRS.dat', index=False, header=False)	
csv2dat()


#! /usr/bin/env python

import math, time, sys, os

# Adjust this part to your data
#--------------------------------------------------------------------------------
# Input file
# plist_file = timeSpan + ".plist"
# plist_file = "detailRT-" + workload + ".csv"
def init(tier):	
	global stime_epoch, etime_epoch, HTTP_multi, AJP_multi, CJDBC_multi, MYSQL_multi, HTTP_multi_1sec, AJP_multi_1sec, CJDBC_multi_1sec
	global MYSQL_multi_10ms, multi_count_in_sec, HTTP_input, HTTP_output, HTTP_multi_longReqs
	global HTTP_in, HTTP_out_rs, plist_file, multiplicity, responsetime, inout
	
#	plist_file = tier + "_wl" + workload + ".csv"
	plist_file = "sdata.txt"
	# Output files
	# multiplicity =  timeSpan + "_Clienthttp_multiplicity_wl" + workload + "-50ms.csv"
	multiplicity = timeSpan + "_" + tier + "_multiplicity_wl" + workload + "-50ms.csv"
	responsetime = timeSpan + "_" + tier + "_responsetime_wl" + workload + "-50ms.csv"
	inout = timeSpan + "_" + tier + "_inout_wl" + workload + "-50ms.csv"
	
	# Start-time and End-time to be processed
	stime_epoch = time.mktime(time.strptime(startTime, '%Y%m%d%H%M'))
	etime_epoch = time.mktime(time.strptime(endTime, '%Y%m%d%H%M')) + 59.999999
	
	# The number of time windows in 1 sec.
	multi_count_in_sec = 20
	#--------------------------------------------------------------------------------
	
	# initialize dictionaries
	HTTP_multi = {}
	HTTP_multi_1sec = {}
	HTTP_multi_longReqs = {}
	AJP_multi = {}
	AJP_multi_1sec = {}
	CJDBC_multi = {}
	CJDBC_multi_1sec = {}
	MYSQL_multi = {}
	
	HTTP_input = {}
	HTTP_output = {}
	# response time
	HTTP_in = {}
	HTTP_out_rs = {}

models = ["total", "StoriesOfTheDay", "Browse", "BrowseCategories", "BrowseStoriesInCategory", "OlderStories", "ViewStory", "ViewComment", "Search", "SearchInStories", "SearchInComments", "SearchInUsers"]	
models_title = ["total", "StoriesOfTheDay", "Browse", "BrowseCategories", "BrowseStoriesInCategory", "OlderStories", "ViewStory", "ViewComment", "Search", "SearchInStories", "SearchInComments", "SearchInUsers"]		

def init_globle_dict():
	for model in models:
		HTTP_input[model] = {}
		HTTP_output[model] = {}
		HTTP_multi[model] = {}
		HTTP_multi_longReqs[model] = {}
		HTTP_in[model] = {}
		HTTP_out_rs[model] = {}
		#print model
		for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
			for ms in range(0, multi_count_in_sec):
				#print ms
				ms_time = target_time * multi_count_in_sec + ms
				#print ms_time
				ms_time_key=str(ms_time)
				HTTP_input[model][ms_time] = 0
				HTTP_output[model][ms_time] = 0
				HTTP_multi[model][ms_time] = 0		
				HTTP_multi_longReqs[model][ms_time] = 0		
				HTTP_in[model][ms_time] = [[], [], [], [], []]
				HTTP_in[model][ms_time][0] = 0                   
				HTTP_in[model][ms_time][1] = 0.0
				HTTP_in[model][ms_time][2] = 0
				HTTP_in[model][ms_time][3] = 0
				HTTP_in[model][ms_time][4] = 0
				
				HTTP_out_rs[model][ms_time] = [[], [], [], [], []]
				HTTP_out_rs[model][ms_time][0] = 0                   
				HTTP_out_rs[model][ms_time][1] = 0.0
				HTTP_out_rs[model][ms_time][2] = 0
				HTTP_out_rs[model][ms_time][3] = 0
				HTTP_out_rs[model][ms_time][4] = 0

def main():
	#print multi_count_in_sec,model
	#print os.getcwd()
	for line in open(plist_file):
		if "startingTime" in line \
			or "Users" in line:
			pass
		else:
			continue
		#print line
		#print type(line)	
		#print eval(line)
		#parts = (eval(line)) 
		parts = line.split(',')
		# reqID = parts[0]
		reqType = parts[2]
		#print parts
		stime = float(parts[0])
		etime = float(parts[1])
		reqRS = etime - stime
		#reqRS_tmp = float(parts[3])
		
		protocol = "client"
		
		# ## BrowseStoriesByCategory and BrowseStoriesInCategory are the same, some code use BrowseStoriesByCategory, for consistency, we transform all the BrowseStoriesByCategory to BrowseStoriesInCategory
		model = reqType.strip()
		if (model in "BrowseStoriesByCategory"):
			model = "BrowseStoriesInCategory"
			
		if protocol == 'client':
			incInOut(stime, model, HTTP_input)
			incInOut(etime, model, HTTP_output)
			calcMultiplicity(stime, etime, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_multi)
			if reqRS < 0:
				print line
			elif reqRS > 1.2:
				#print 'long resRS',(stime, etime)
				calcMultiplicity(stime, etime, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_multi_longReqs)
				#print '		', HTTP_multi_longReqs['total']
				continue
			else:
				calcResponseTime(stime, reqRS, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_in, True)
				calcResponseTime(etime, reqRS, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_out_rs, True)

	
	# open files for output
	OUTFILE3 = open("%s" % inout, 'w')
	# write headers on output files
	OUTFILE3.write("date_time")
	for model in models_title:
		OUTFILE3.write(",%s_http_start,%s_http_end" % 
                      (model, model))
	OUTFILE3.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			OUTFILE3.write("%f" % ms_time_f)
			for model in models:
				OUTFILE3.write(",%d,%d" % 
                               (HTTP_input[model][ms_time], HTTP_output[model][ms_time]))
			OUTFILE3.write("\n")
	OUTFILE3.close()
	
	# open files for output
	OUTFILE4 = open("%s" % multiplicity, 'w')
	# write headers on output files
	OUTFILE4.write("date_time")
	for model in models_title:
		OUTFILE4.write(",%s_http" % 
                      (model))
	OUTFILE4.write(",http_total_longReq")
	OUTFILE4.write(",http_adjustLoad")
	OUTFILE4.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			OUTFILE4.write("%f" % ms_time_f)
			for model in models:
				OUTFILE4.write(",%f" % 
                               (HTTP_multi[model][ms_time]))
            
			OUTFILE4.write(",%f,%f" % (HTTP_multi_longReqs["total"][ms_time], (HTTP_multi["total"][ms_time] - HTTP_multi_longReqs["total"][ms_time])))
			OUTFILE4.write("\n")
	OUTFILE4.close()

	# open files for output Response time
	OUTFILE2 = open("%s" % responsetime, 'w')
	# write headers on output files
	OUTFILE2.write("date_time")
	for model in models_title:
		OUTFILE2.write(",%s_http" % 
                      (model))
	for model in models_title:
		OUTFILE2.write(",%s_http_out_rs" % 
                      (model))
	OUTFILE2.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			# OUTFILE1.write("%s" % time.strftime("%Y/%m/%d %H:%M:%S"  ,time.localtime(ms_time_f)))
			for model in models:
				if (HTTP_in[model][ms_time][0] == 0):
					HTTP_in[model][ms_time][1] = 0
				else:
					HTTP_in[model][ms_time][1] = HTTP_in[model][ms_time][1] / HTTP_in[model][ms_time][0]
				# ## the response time average using etime
				if (HTTP_out_rs[model][ms_time][0] == 0):
					HTTP_out_rs[model][ms_time][1] = 0
				else:
					HTTP_out_rs[model][ms_time][1] = HTTP_out_rs[model][ms_time][1] / HTTP_out_rs[model][ms_time][0]
			OUTFILE2.write("%f" % ms_time_f)	
			for model in models:
				OUTFILE2.write(",%f" % 
			                   (HTTP_in[model][ms_time][1]))
			for model in models:
				OUTFILE2.write(",%f" % 
			                   (HTTP_out_rs[model][ms_time][1]))
			OUTFILE2.write("\n")
	OUTFILE2.close()
	

def incInOut(inc_time, model, dic_multi):
	inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
	if inc_time2 < stime_epoch * multi_count_in_sec:
		return
	if inc_time2 > etime_epoch * multi_count_in_sec:
		return
	dic_multi['total'][inc_time2] += 1
	dic_multi[model][inc_time2] += 1
	return

def calcMultiplicity(add_from, add_to, stime_epoch, etime_epoch, model,
              multi_count_in_sec, dic_multi):
	#print add_from, add_to, stime_epoch, etime_epoch, model,multi_count_in_sec
	#1447187511.08 1447187511.23 1447187280.0 1447187520.0 SearchInUsers 20
	if model == 0:
		print 'come here  **********************'
	if (add_to < stime_epoch):
	    return
	elif (add_from < stime_epoch):
	    add_from = stime_epoch
	if (add_from > etime_epoch):
	    return
	elif (add_to > etime_epoch):
	    add_to = etime_epoch
	
	add_from2 = int(math.ceil(add_from * multi_count_in_sec))  # the smallest integer value greater than or equal to x
	add_to2 = int(math.floor(add_to * multi_count_in_sec))   #the largest integer value less than or equal to x.
	#print add_from2, add_to2
	#28943750222 28943750224
	if (add_from2 <= add_to2):
	    if (add_from2 - 1 >= stime_epoch * multi_count_in_sec):
	        add_prev = math.ceil(add_from * multi_count_in_sec) - (add_from * multi_count_in_sec)
            #print add_prev
            #print dic_multi['total'][add_from2 - 1] 
            #print dic_multi[model][add_from2 - 1]         
            dic_multi['total'][add_from2 - 1] += add_prev
            dic_multi[model][add_from2 - 1] += add_prev
        add_post = (add_to * multi_count_in_sec) - math.floor(add_to * multi_count_in_sec)
        #print add_post
        #print dic_multi['total'][add_to2] 
        #print dic_multi[model][add_to2]         
        '''
1122 1447188356.000000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1123 1447188356.050000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1124 1447188356.100000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1125 1447188356.150000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1126 1447188356.200000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1127 1447188356.250000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,430.000000     ,370.000000
1128 1447188356.300000,3548.000037,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,3548.000037,2154.200     010,1393.800027
1129 1447188356.350000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,377.000000     ,423.000000
1130 1447188356.400000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,377.000000     ,423.000000
1131 1447188356.450000,1184.079988,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,1184.079988,377.0000     00,807.079988
1132 1447188356.500000,800.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,800.000000,377.000000     ,423.000000
1133 1447188356.550000,802.799997,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,802.799997,377.000000     ,425.799997
1134 1447188356.600000,3973.019971,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,3973.019971,2847.079     940,1125.940031
1135 1447188356.650000,3831.880002,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,3831.880002,3282.220     017,549.659985
		'''
        dic_multi['total'][add_to2] += add_post
        dic_multi[model][add_to2] += add_post
	    
        if add_to2 == 28943767090: # 8356: #1447188356  1447188356.60 * 20
            print "post: index = %d, add amount = %f, total = %f, from = %d" % (add_to2, add_post, dic_multi['total'][add_to2], add_from2)
	    #mycounter = 0;
        while (add_from2 < add_to2):
	        dic_multi['total'][add_from2] += 1.0
	        dic_multi[model][add_from2] += 1.0
	        add_from2 += 1
	        #mycounter += 1

        if add_to2 == 28943767090: # 8356: #1447188356  1447188356.60 * 20
            print "\t\tindex = %d, total = %f, from = %d" % (add_to2, dic_multi['total'][add_to2], add_from2)
	else:
	    res_time2 = (add_to - add_from) * multi_count_in_sec
	    #print "whole: index = %d, add amount = %f" % (add_to2, res_time2)
	    dic_multi['total'][add_to2] += res_time2
	    dic_multi[model][add_to2] += res_time2
	return


def calcResponseTime(inc_time, rs, stime_epoch, etime_epoch, model,
             multi_count_in_sec, dic_multi, switch):
    inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
    if inc_time2 < stime_epoch * multi_count_in_sec:
        return
    if inc_time2 > etime_epoch * multi_count_in_sec:
        return
    if(switch):       
        dic_multi['total'][inc_time2][0] += 1
        dic_multi['total'][inc_time2][1] += rs
        dic_multi[model][inc_time2][0] += 1
        dic_multi[model][inc_time2][1] += rs
        if(0.01 <= rs):
            dic_multi['total'][inc_time2][2] += 1
            dic_multi[model][inc_time2][2] += 1             
        if(0.1 <= rs):
            dic_multi['total'][inc_time2][3] += 1
            dic_multi[model][inc_time2][3] += 1
        if(1 <= rs):
            dic_multi['total'][inc_time2][4] += 1
            dic_multi[model][inc_time2][4] += 1              
    else:
        dic_multi['total'][inc_time2] += 1
        dic_multi[model][inc_time2] += 1            
    return


import unittest
def func(x):
	return x+1

class MyTest(unittest.TestCase): 
	def test_fun(self):
		func(2)

	def test_calcMultiplicity(self):
		tmp = {}
		calcMultiplicity(float(1447187511.08),float(1447187511.23),float(1447187280.0),float(1447187520.0),'SearchInUsers',20, tmp)
													

if __name__ == "__main__":
		
	print len(sys.argv)
	# process options
		

	if len(sys.argv) == 6:
#python aggregateInOutPut_ClientTier2.py 20151110152858-3151 201511101528 201511101531 800 utest
		timeSpan = sys.argv[1]
		startTime = sys.argv[2]
		endTime = sys.argv[3]
		workload = sys.argv[4]
		#test = sys.argv[5]
		
		init("detailRT-client")
		init_globle_dict()
		#unittest.main()

		calcMultiplicity(float(1447187511.08),float(1447187511.23),float(1447187280.0),float(1447187520.0),'SearchInUsers',20, HTTP_multi)

	elif len(sys.argv) == 5:
		timeSpan = sys.argv[1]
		startTime = sys.argv[2]
		endTime = sys.argv[3]
		workload = sys.argv[4]
		
		init("detailRT-client")
		init_globle_dict()
		main()
	else: 
		print "the input parameters for aggregateResponseTime is not correct"
		exit(0)

#	init("QueueLength2-Apache")
#	main()
#	init("QueueLength-CJDBC1")
#	main()
#	init("QueueLength-Tomcat")
#	main()

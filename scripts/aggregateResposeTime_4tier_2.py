#! /usr/bin/env python

import math, time, sys

global stime_epoch
global etime_epoch
global HTTP_multi
global AJP_multi
global CJDBC_multi
global MYSQL_multi
global HTTP_multi_1sec
global AJP_multi_1sec
global CJDBC_multi_1sec
global MYSQL_multi_10ms
global multi_count_in_sec


# process options
if len(sys.argv) == 5:
	timeSpan = sys.argv[1]
	startTime = sys.argv[2]
	endTime = sys.argv[3]
	workload = sys.argv[4]
else: 
	print "the input parameters for aggregateResponseTime is not correct"

# Adjust this part to your data
#--------------------------------------------------------------------------------
# Input file
plist_file = timeSpan + ".plist"

# Output files
output_file =  timeSpan + "_multiplicity_wl" + workload + ".csv"
output_file2 = timeSpan + "_responsetime_wl" + workload + ".csv"
output_file3 = timeSpan + "_inout_wl" + workload + ".csv"

# Start-time and End-time to be processed
#stime_epoch = time.mktime(time.strptime('201011300746', '%Y%m%d%H%M'))
#etime_epoch = time.mktime(time.strptime('201011300749', '%Y%m%d%H%M')) + 59.999999
stime_epoch = time.mktime(time.strptime(startTime, '%Y%m%d%H%M'))
etime_epoch = time.mktime(time.strptime(endTime, '%Y%m%d%H%M')) + 59.999999

# The number of time windows in 1 sec.
multi_count_in_sec = 10
#--------------------------------------------------------------------------------

# initialize dictionaries
HTTP_multi = {}
HTTP_multi_1sec = {}
AJP_multi = {}
AJP_multi_1sec = {}
CJDBC_multi = {}
CJDBC_multi_1sec = {}
MYSQL_multi = {}
MYSQL_multi_1sec = {}
MYSQL_multi_100ms = {}
MYSQL_multi_10ms = {}
HTTP_totalRT = {}
AJP_totalRT = {}
CJDBC_totalRT = {}

MYSQL_totalRT = {}
MYSQL_totalRT2 = {}
HTTP_input = {}
AJP_input = {}
CJDBC_input = {}
MYSQL_input = {}
MYSQL_input_EXEC = {}
MYSQL_input_1sec = {}
MYSQL_input_100ms = {}
MYSQL_input_10ms = {}
MYSQL_output = {}
MYSQL_output_1sec = {}
MYSQL_output_100ms = {}
MYSQL_output_10ms = {}


def main():
	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			HTTP_multi[ms_time] = 0.0
			HTTP_multi_1sec[ms_time] = 0.0
			AJP_multi[ms_time] = 0.0
			AJP_multi_1sec[ms_time] = 0.0
			CJDBC_multi[ms_time] = 0.0
			CJDBC_multi_1sec[ms_time] = 0.0
			MYSQL_multi[ms_time] = 0.0
			MYSQL_multi_1sec[ms_time] = 0.0
			MYSQL_multi_100ms[ms_time] = 0.0
			MYSQL_multi_10ms[ms_time] = 0.0
			HTTP_totalRT[ms_time] = 0.0
			AJP_totalRT[ms_time] = 0.0
			CJDBC_totalRT[ms_time] = 0.0
			MYSQL_totalRT[ms_time] = 0.0
			MYSQL_totalRT2[ms_time] = 0.0
			HTTP_input[ms_time] = 0
			AJP_input[ms_time] = 0
			CJDBC_input[ms_time] = 0
			MYSQL_input[ms_time] = 0
			MYSQL_input_EXEC[ms_time] = 0
			MYSQL_input_1sec[ms_time] = 0
			MYSQL_input_100ms[ms_time] = 0
			MYSQL_input_10ms[ms_time] = 0
			MYSQL_output[ms_time] = 0
			MYSQL_output_1sec[ms_time] = 0
			MYSQL_output_100ms[ms_time] = 0
			MYSQL_output_10ms[ms_time] = 0
	
	
	for line in open(plist_file):
		parts = line.split(',')
		stime = float(parts[1])
		etime = float(parts[2])
		parts2 = parts[4][1:-1].split(';')
		protocol = parts2[0]
		if protocol == 'HTTP':
			addMulti2(stime, etime, HTTP_multi)
			addRT(stime, etime, HTTP_totalRT)
			incInOut(stime, HTTP_input)
		elif protocol == 'AJP13':
			addMulti2(stime, etime, AJP_multi)
			addRT(stime, etime, AJP_totalRT)
			incInOut(stime, AJP_input)
		elif protocol == 'CJDBC':
			addMulti2(stime, etime, CJDBC_multi)
			addRT(stime, etime, CJDBC_totalRT)
			incInOut(stime, CJDBC_input)			
		elif protocol == 'MySQL':
			addMulti2(stime, etime, MYSQL_multi)
			addRT(stime, etime, MYSQL_totalRT)
			addRT2(stime, etime, MYSQL_totalRT2)
			incInOut(stime, MYSQL_input)
			incInOut(etime, MYSQL_output)
			request = parts[3][0:7]
			if request == 'M000009':
				incInOut(stime, MYSQL_input_EXEC)
		if ((etime - stime) > 1.0):
			if protocol == 'HTTP':
				addMulti2(stime, etime, HTTP_multi_1sec)
			elif protocol == 'AJP13':
				addMulti2(stime, etime, AJP_multi_1sec)
			elif protocol == 'CJDBC':
				addMulti2(stime, etime, CJDBC_multi_1sec)			
			elif protocol == 'MySQL':
				addMulti2(stime, etime, MYSQL_multi_1sec)
				incInOut(stime, MYSQL_input_1sec)
				incInOut(etime, MYSQL_output_1sec)
		if ((etime - stime) > 0.1) and (protocol == 'MySQL'):
			addMulti2(stime, etime, MYSQL_multi_100ms)
			incInOut(stime, MYSQL_input_100ms)
			incInOut(etime, MYSQL_output_100ms)
		if ((etime - stime) > 0.01) and (protocol == 'MySQL'):
			addMulti2(stime, etime, MYSQL_multi_10ms)
			incInOut(stime, MYSQL_input_10ms)
			incInOut(etime, MYSQL_output_10ms)
	
	
	# open files for output
	OUTFILE = open("%s" % output_file, 'w')
	# write headers on output files
	OUTFILE.write("date_time,HTTP,AJP,CJDBC,MySQL,HTTP(over 1s),AJP(over 1s),CJDBC(over 1s),MySQL(over 10ms),MySQL(over 100ms),MySQL(over 1sec)\n")
	
	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
	                ms_time_f = float(ms_time) / multi_count_in_sec
	                OUTFILE.write("%f" % ms_time_f)
			OUTFILE.write(",%f,%f,%f,%f" % (HTTP_multi[ms_time], AJP_multi[ms_time],CJDBC_multi[ms_time],
						     MYSQL_multi[ms_time]))
			OUTFILE.write(",%f,%f,%f,%f,%f,%f" % 
				      (HTTP_multi_1sec[ms_time], AJP_multi_1sec[ms_time],CJDBC_multi_1sec[ms_time],
				       MYSQL_multi_10ms[ms_time], MYSQL_multi_100ms[ms_time],
				       MYSQL_multi_1sec[ms_time]))
	                OUTFILE.write("\n")
	OUTFILE.close()
	
	# open files for output
	OUTFILE2 = open("%s" % output_file2, 'w')
	# write headers on output files
	OUTFILE2.write("date_time,HTTP,AJP,CJDBC,MySQL(starting time),MySQL(finishing time)\n")
	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
	                ms_time_f = float(ms_time) / multi_count_in_sec
	                OUTFILE2.write("%f" % ms_time_f)
			HTTP_RT = 0.0
			AJP_RT = 0.0
			CJDBC_RT = 0.0
			MYSQL_RT = 0.0
			MYSQL_RT2 = 0.0
			if HTTP_totalRT[ms_time] != 0 and HTTP_input[ms_time] != 0:
				HTTP_RT = HTTP_totalRT[ms_time] / HTTP_input[ms_time]
			if AJP_totalRT[ms_time] != 0 and AJP_input[ms_time] != 0:
				AJP_RT = AJP_totalRT[ms_time] / AJP_input[ms_time]
			if CJDBC_totalRT[ms_time] != 0 and CJDBC_input[ms_time] != 0:
				CJDBC_RT = CJDBC_totalRT[ms_time] / CJDBC_input[ms_time]
			if MYSQL_totalRT[ms_time] != 0 and MYSQL_input[ms_time] != 0:
				MYSQL_RT = MYSQL_totalRT[ms_time] / MYSQL_input[ms_time]
			if MYSQL_totalRT2[ms_time] != 0 and MYSQL_input[ms_time] != 0:
				MYSQL_RT2 = MYSQL_totalRT2[ms_time] / MYSQL_output[ms_time]
			OUTFILE2.write(",%f,%f,%f,%f,%f" % (HTTP_RT, AJP_RT, CJDBC_RT,MYSQL_RT, MYSQL_RT2))
	                OUTFILE2.write("\n")
	OUTFILE2.close()
	
	# open files for output
	OUTFILE3 = open("%s" % output_file3, 'w')
	# write headers on output files
	OUTFILE3.write("date_time,HTTPstart,AJPstart,CJDBCstart,MySQLstart(all),MySQLstart(10ms),MySQLstart(100ms),MySQLstart(1s),")
	OUTFILE3.write("MySQLfinish(all),MySQLfinish(10ms),MySQLfinish(100ms),MySQLfinish(1s),MySQLstart(EXEC)\n")
	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
	                ms_time_f = float(ms_time) / multi_count_in_sec
	                OUTFILE3.write("%f" % ms_time_f)
			OUTFILE3.write(",%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d" % 
				       (HTTP_input[ms_time], AJP_input[ms_time],CJDBC_input[ms_time],
					MYSQL_input[ms_time], MYSQL_input_10ms[ms_time],
					MYSQL_input_100ms[ms_time], MYSQL_input_1sec[ms_time],
					MYSQL_output[ms_time], MYSQL_output_10ms[ms_time],
					MYSQL_output_100ms[ms_time], MYSQL_output_1sec[ms_time],
					MYSQL_input_EXEC[ms_time]))
	                OUTFILE3.write("\n")
	OUTFILE3.close()
	



def addMulti2(add_from, add_to, dic_multi):
	if (add_to < stime_epoch):
		return
        elif (add_from < stime_epoch):
		add_from = stime_epoch
	if (add_from > etime_epoch):
		return
        elif (add_to > etime_epoch):
		add_to = etime_epoch

	add_from2 = int(math.ceil(add_from * multi_count_in_sec))
        add_to2 = int(math.floor(add_to * multi_count_in_sec))
        if (add_from2 <= add_to2):
		if (add_from2 - 1 >= stime_epoch * multi_count_in_sec):
			add_prev = math.ceil(add_from * multi_count_in_sec) - (add_from * multi_count_in_sec)
			#print "pre: index = %d, add amount = %f" % (add_from2 - 1, add_prev)
			dic_multi[add_from2 - 1] += add_prev
		add_post = (add_to * multi_count_in_sec) - math.floor(add_to * multi_count_in_sec)
		#print "post: index = %d, add amount = %f" % (add_to2, add_post)
		dic_multi[add_to2] += add_post
		while (add_from2 < add_to2):
			#print "inter: index = %d, add amount = %f" % (add_from2, 1.0)
			dic_multi[add_from2] += 1.0
			add_from2 += 1
	else:
		res_time2 = (add_to - add_from) * multi_count_in_sec
		#print "whole: index = %d, add amount = %f" % (add_to2, res_time2)
		dic_multi[add_to2] += res_time2
	return



def addRT(add_from, add_to, dic_rt):
    res_time2 = 0.0
    if (add_from < stime_epoch):
        return
    if (add_to < stime_epoch):
        return
    if (add_from > etime_epoch):
        return

    res_time2 = add_to - add_from
    if (res_time2 == 0):
        return
    add_from2 = int(math.floor(add_from * multi_count_in_sec))
    dic_rt[add_from2] += res_time2
    return



def addRT2(add_from, add_to, dic_rt):
    res_time2 = 0.0
    if (add_to > etime_epoch):
        return
    if (add_to < stime_epoch):
        return
    if (add_from > etime_epoch):
        return

    res_time2 = add_to - add_from
    if (res_time2 == 0):
        return
    add_to2 = int(math.floor(add_to * multi_count_in_sec))
    dic_rt[add_to2] += res_time2
    return



def addTP(add_from, add_to, dic_tp):
    if (add_to < stime_epoch):
        return
    if (add_from > etime_epoch):
        return

    res_time2 = (add_to - add_from) * multi_count_in_sec
    if (res_time2 == 0):
        return
    if (add_from < stime_epoch):
        add_from = stime_epoch
    if (add_to > etime_epoch):
        add_to = etime_epoch
    add_from2 = int(math.ceil(add_from * multi_count_in_sec))
    add_to2 = int(math.floor(add_to * multi_count_in_sec))
    if (add_from2 <= add_to2):
        if (add_from2 - 1 >= stime_epoch * multi_count_in_sec):
            add_prev = math.ceil(add_from * multi_count_in_sec) - (add_from * multi_count_in_sec)
            #print "pre: index = %d, add amount = %f" % (add_from2 - 1, add_prev / res_time2)
            dic_tp[add_from2 - 1] += add_prev / res_time2
        add_post = (add_to * multi_count_in_sec) - math.floor(add_to * multi_count_in_sec)
        #print "post: index = %d, add amount = %f" % (add_to2, add_post / res_time2)
        dic_tp[add_to2] += add_post / res_time2
        while (add_from2 < add_to2):
            #print "inter: index = %d, add amount = %f" % (add_from2, 1.0 / res_time2)
            dic_tp[add_from2] += 1.0 / res_time2
            add_from2 += 1
    else:
        #print "whole: index = %d, add amount = %f" % (add_to2, 1.0)
        dic_tp[add_to2] += 1.0
    return



def incInOut(inc_time, dic_multi):
	inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
	if inc_time2 < stime_epoch * multi_count_in_sec:
		return
	if inc_time2 > etime_epoch * multi_count_in_sec:
		return
	dic_multi[inc_time2] += 1
	return




if __name__ == "__main__":
        main()

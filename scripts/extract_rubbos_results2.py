#! /usr/bin/env python

import sys, os, commands, getopt,time, re
from datetime import datetime


def usage():
    print '''Usage: python extract_rubbos_result.py [options]
Options:
 -h, --help       Print this help message
 -d <directory>   Process data in the directory
 -c <number>      The number of clients [Defult: 2]
 -g <mili-second> The threshold which is the upper limit of goodput [Default: 1000]
 -r <second>      The length of run-time in second [Default: 300]
 -s               Output in a simple format
'''

def main():
    # process options
    global goodput_threshold
    
    client_num = 5 
    runtime_sec = 300
    goodput_threshold = 1000.0
    simple_mode = 0
    data_path = ''
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:c:g:r:hs', ['help'])
        for (opt, arg) in optlist:
            if opt == '-s':
                simple_mode = 1
            elif opt == '-d':
                data_path = arg
                if data_path.endswith('/'):
                    data_path.rstrip()
            elif opt == '-c':
                client_num = int(arg)
            elif opt == '-g':
                goodput_threshold = float(arg)
            elif opt == '-r':
                runtime_sec = int(arg)
            else:
                usage()
                return
    except:
        usage()
        sys.exit(1)

    # find directories of RUBBoS result
    if data_path == '':
        results = commands.getstatusoutput("find . -name '20*'")
    else:
        results = commands.getstatusoutput("find %s/ -name '20*'" % data_path)
    # check error_number
    if results[0] != 0:
        print "No match.\n"
        sys.exit(0)

    # replace string in the files
    dirs = results[1].split('\n')
    dirs.sort(cmp=None, key=None, reverse=False)
    for dir in dirs:
        if simple_mode == 0:
            print "\ndir = %s" % dir
        results = commands.getstatusoutput('grep \'Total number of clients for this experiment\' %s/index.html' % dir)
        if results[0] != 0:
            print "Error: %s" % results[1]
        aaa1 = results[1].split(': ')
        aaa2 = aaa1[1].split('<')
        workload = aaa2[0]

        results = commands.getstatusoutput('grep \'Average throughput\' %s/perf.html' % dir)
        if results[0] != 0:
            print "Error: %s" % results[1]
            continue
        lines = results[1].split('\n')
        if len(lines) != 4:
            print "Error: num=%d" % len(lines)
        runtime_result = lines[1]
        #find throughput
        aaa1 = runtime_result.split(' req/s')
        aaa2 = aaa1[0].split('<B>Average throughput</div></B><TD colspan=6><div align=center><B>')
        if len(aaa2) > 1:
            throughput = aaa2[1]
        else:
            throughput = "xxx"
        #find response time
        aaa1 = aaa2[0].split(' ms')
        aaa2 = aaa1[0].split('<B>')
        num = len(aaa2)
        if num > 1:
            response_time = aaa2[num - 1]
        else:
            response_time = "xxx"

        #Process stat_client#.html files
        detailRTfile = dir + "/" + "detailRT-client_wl" + workload + ".csv"
        OUTFILE = open(detailRTfile, 'w')
        OUTFILE.write("startingTime,endingTime,transactionType,RT\n")
        OUTFILE.close()
        stat_client = stat_client_log(dir,workload)
        rt_total = 0.0
        requests_num = 0
        good_requests_num = 0
        for clientid in range(0, client_num):
            (rt, num, gnum) = stat_client.analyzeLogFile(clientid)
            rt_total += rt
            requests_num += num
            good_requests_num += gnum
        average_rt = float(rt_total) / requests_num
        average_tp = float(requests_num) / runtime_sec
        average_gp = float(good_requests_num) / runtime_sec

        if simple_mode == 0:
            print "workload = %s" % workload
            print "Response time   = %s ms" % response_time
            print "Throughput      = %s req/s" % throughput
            print "RT(stat_client) = %f ms" % average_rt
            print "TP(stat_client) = %f req/s" % average_tp
            print "Goodput(%.1fms) = %f req/s" % (goodput_threshold, average_gp)
        else:
            print "%s\t%s\t%s\t%f\t%f\t%f" % (workload, response_time, throughput, average_rt, average_tp, average_gp)

    if simple_mode == 0:
        print

#    global goodput_threshold
#    goodput_threshold = 1000.0
#    path = os.getcwd()
#    dir = path + "/" + "data"
#    stat_client = stat_client_log(dir,"4000")
#    (rt, num, gnum) = stat_client.analyzeLogFile(1)


class stat_client_log:

    def __init__(self, dir, workload):
        self.data_dir = dir
        self.workload = workload
        
    def analyzeLogFile(self, clientid):
        
        stat_file = "stat_client%d.html" % clientid
        client_rt_total = 0
        client_requests_num = 0
        client_goodreq_num = 0
        
        # create path of stat file
        log_file_name = self.data_dir + "/" + stat_file
        detailRTfile = self.data_dir + "/" + "detailRT-client_wl" + self.workload + ".csv"
        
	try:
   	    with open(log_file_name):
	        print log_file_name
	except IOError:
   	    print log_file_name + ' doesnt exsit'
	    return (0,0,0)

	OUTFILE = open(detailRTfile, 'a')
        
            
        
        # read an input file #######################################################
        mode = 0
        # read each line of the log file
        for line in open(log_file_name):
            if "<h3>Runtime session statistics</h3>" in line:
                mode = 1
                continue
            if (mode == 1) and ("Transaction Details" in line):
                mode = 2
                continue
            if mode >= 2 and mode < 4:
                mode += 1
                continue
            if mode != 4:
                continue

            # This is a line for the log during runtime
            loglines = line.split("</TR>")
            logid = 0
            for logline in loglines:
                if "</table>" in logline:
                    mode += 1
                    break
                try:
                    parts = logline.split("<TD>")
                    #name = parts[1][:-5]
                    rt = int(parts[2][:-5])
                    #print rt
                    # add by Qingyang
                    transName = parts[1][:-5]
                    timestr = parts[3][:-5]        
                    print transName, rt, timestr

                    #time str ex 1455559738074         
                    p = re.compile('14[0-9]+')  #13->14
                    m = p.match(timestr)
                    stime_epoch = "";
                    etime_epoch = "";
                    #print m.group(0)
                    if m:
                    # due to some wired reason, the timestr is already in epoch time format such as: 1337931141596
                        etime_millisPart = int(float(timestr)%1000)
                        etime_integerPart = int((float(timestr) - etime_millisPart)/1000)
                        etime_epoch = str(etime_integerPart) + "." + self.inttostr(etime_millisPart)
                        
                        stime_datetime = float(timestr) - rt
                        stime_millisPart =  int(stime_datetime%1000)
                        stime_integerPart = int((stime_datetime - stime_millisPart)/1000)
                        stime_epoch = str(stime_integerPart) + "." + self.inttostr(stime_millisPart)
                    else:
                    ### time.mktime cannot get the microseonds value
                        a = datetime.strptime(timestr, '%Y-%m-%d %H:%M:%S.%f')
                        millisPart =  a.microsecond/1000
                    	integerPart = int(time.mktime(time.strptime(timestr, "%Y-%m-%d %H:%M:%S.%f")))
                        etime_epoch = str(integerPart) + "." + self.inttostr(millisPart)  
                        
                        stime_datetime = integerPart*1000 + millisPart - rt
                        stime_millisPart =  stime_datetime%1000
                        stime_integerPart = int((stime_datetime - stime_millisPart)/1000)
                        stime_epoch = str(stime_integerPart) + "." + self.inttostr(stime_millisPart)    
    		        #stime_epoch = etime_epoch - rt/1000
                    OUTFILE.write("%s,%s, %s,%d\n" % (stime_epoch, etime_epoch ,transName, rt))
                    client_rt_total += rt
                    client_requests_num += 1
                    if rt < goodput_threshold:
                        client_goodreq_num += 1
                except:
                    print "wrong format!!: %s" % logline
            if mode >= 5:
                break
        OUTFILE.close();
        return(client_rt_total, client_requests_num, client_goodreq_num)
    
    def inttostr(self, millsPart):
        if (millsPart/100 >= 1):
            return str(millsPart)
        elif(millsPart/10 >= 1):
            return "0" + str(millsPart)
        else:
            return "00" + str(millsPart)
            



if __name__ == "__main__":
    main()
        

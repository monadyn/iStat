'''
Created on Jul 7, 2011

@author: qingyang
'''

import math, time,array, string
import csv
import  sys, commands, os
from datetime import datetime
from datetime import timedelta

class analyzer:

    #--------------------------------------------------------------------------
    # ●パラメータ
    # data_dir:
    #     データディレクトリ(anaディレクトリのパス)
    #     data_dir   = '/work/sysviz/ana3'
    # upper_proto:
    #     上位のプロトコル
    #     upper_proto   = 'HTTP'
    # db_proto:
    #     DBのプロトコル
    #     db_proto   = 'Oracle'
    # ●定数
    # output_records:
    #     詳細レコード出力の要否
    #     True：要, False：不要
    # max_multiplicity:
    #     （プログラムが使用する内部パラメータ）
    #     多重度をカウントする為のハッシュが想定する最大多重度
    #     大きく設定しておけば安全だが、その分メモリを消費する
    #--------------------------------------------------------------------------
    def __init__(self,dir1):
        self.data_dir1 = dir1
        

    def generateCustmizedMultiplicity(self, source_dir, output_dir, workloadList, metricsList, epochTime):
        # open files for output
        for workload in workloadList:
            
            prefix = "DetailMultiplicity_stat"
            
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            csvfile = open(file_name)
            csvread = csv.DictReader(csvfile)
            OUTFILE = open('%s/%s_partial_%s.csv' % (output_dir,prefix,workload), 'w')
            
            # write file header
            OUTFILE.write("date_time")
            for metric in metricsList:
                OUTFILE.write(",%s" % (metric))
            OUTFILE.write("\n") 

            i = 0
            for row in csvread:
                #print row
                i = i+1
                if i == 1: 
                    print row
                OUTFILE.write("%s" % (row["date_time"]))
                for metric in metricsList:
                    OUTFILE.write(",%f" % (float(row[metric].strip())))
                OUTFILE.write("\n") 
                    
            
            csvfile.close();
            OUTFILE.close();
        return

    def generateCustmizedResponsetime(self, source_dir, output_dir, workloadList, metricsList, epochTime):
        # open files for output
        for workload in workloadList:
            
            prefix = "multi_inout_aveRS_stat"
            
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            csvfile = open(file_name)
            csvread = csv.DictReader(csvfile)
            OUTFILE = open('%s/%s_partialRS_%s.csv' % (output_dir,prefix,workload), 'w')
            
            # write file header
            OUTFILE.write("date_time")
            for metric in metricsList:
                OUTFILE.write(",%s" % (metric))
            OUTFILE.write("\n") 
            
            i = 1
            for row in csvread:
                if epochTime:
                    OUTFILE.write("%s" % (row["date_time"]))
                else:
                    OUTFILE.write("%d" % (i))
                if( i == 1801):
                    print i        
                for metric in metricsList:
                    OUTFILE.write(",%f" % (float(row[metric])))
                OUTFILE.write("\n") 
                
                i = i + 1
                            
            csvfile.close();
            OUTFILE.close();
        return
    
    def generateCustmizedInOutput(self, source_dir, output_dir, workloadList, metricsList, epochTime):
        # open files for output
        for workload in workloadList:
            
            prefix = "multi_inout_aveRS_stat"
            
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            csvfile = open(file_name)
            csvread = csv.DictReader(csvfile)
            OUTFILE = open('%s/%s_partialInOutput_%s.csv' % (output_dir,prefix,workload), 'w')
            
            # write file header
            OUTFILE.write("date_time")
            for metric in metricsList:
                OUTFILE.write(",%s" % (metric))
            OUTFILE.write("\n") 
            
            i = 1
            for row in csvread:
                if epochTime:
                    OUTFILE.write("%s" % (row["date_time"]))
                else:
                    OUTFILE.write("%d" % (i))
                            
                for metric in metricsList:
                    OUTFILE.write(",%f" % (float(row[metric])))
                OUTFILE.write("\n") 
                i = i + 1
                            
            csvfile.close();
            OUTFILE.close();
        return
    
    
    def fileLen(self, full_path):
        #""" Count number of lines in a file."""
        f = open(full_path)
        localcounter = 0
        for line in f:
            localcounter = localcounter + 1
        nr_of_lines = localcounter
        f.close()
        return nr_of_lines


    def generateSaturationDurationAna(self, source_dir, output_dir, workloadList, metricsList, epochTime):
        # open files for output
        for workload in workloadList:
            
            prefix = "fineCPU_fineGrainedMonitor_partial"
            
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            csvfile = open(file_name)
            csvread = csv.DictReader(csvfile)
            OUTFILE = open('%s/saturationDuration_%s.csv' % (output_dir,workload), 'w')
            
            # write file header
            OUTFILE.write("counter")
            for metric in csvread.fieldnames:
                OUTFILE.write(",%s" % (metric))
            OUTFILE.write("\n") 


            metricArray = {}
            for metric in csvread.fieldnames:
                metricArray[metric] = 0 

            counter = 0
            SaturationSwitch = False
            i = 1
            for row in csvread:  
                i = i +1
                if row == '':
                    continue
                if row["[CPU]Totl%"] == '':
                    continue
                tmpCPU = int(float(row["[CPU]Totl%"]))        
                if tmpCPU == 100:
                    counter = counter + 1
                    for metric in csvread.fieldnames:
                        if row[metric] =='':
                            print metric
                        metricArray[metric] = metricArray[metric] + float(row[metric]) 
                    SaturationSwitch = True     
                elif SaturationSwitch:
                    OUTFILE.write("%f" % counter)
                    for metric in csvread.fieldnames:
                        OUTFILE.write(",%f" % (metricArray[metric]/counter))
                    OUTFILE.write("\n")               
                    #reset the counter to calculate metric average during the saturation period
                    for metric in csvread.fieldnames:
                        metricArray[metric] = 0 
                    counter = 0
                    SaturationSwitch = False
                else:
                    OUTFILE.write("%f" % 0)
                    for metric in csvread.fieldnames:
                        OUTFILE.write(",%f" % float(row[metric]))
                    OUTFILE.write("\n")                         
            csvfile.close();
            OUTFILE.close();
        return

    
    def generateCustmizedFineGrainedMonitor(self, source_dir, output_dir, workloadList, cpuMetricsList, multiMetricsList, epochTime):
        # open files for output
        for workload in workloadList:
            prefix = "fineCPU"
            OUTFILE = open('%s/%s_fineGrainedMonitor_%s.csv' % (output_dir,prefix,workload), 'w')
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            datafile = open(file_name)
            
            switch = 0
            for line in datafile:
                if "#UTC" not in line and switch == 0:
                    continue
                switch = 1
                line = line.replace("#UTC", "date_time")
                newline = line.replace(' ',',')
                OUTFILE.write("%s" % newline)       
            OUTFILE.close()
        
        for workload in workloadList:          
            prefix = "fineCPU_fineGrainedMonitor"
            file_name = source_dir + "/" + prefix + "_" + workload + '.csv'
            csvfile = open(file_name)
            csvread = csv.DictReader(csvfile)
                    
            OUTFILE = open('%s/%s_partial_%s.csv' % (output_dir,prefix,workload), 'w')
            
            multiplicityFilePath = source_dir + "/multiplicity_stat" + "_" + workload + '.csv'
            multiplicityFile = open(multiplicityFilePath)      
            totallines = self.fileLen(multiplicityFilePath)
            #remove header line
            totallines = totallines -1
                          
            # write file header
            OUTFILE.write("date_time")
            for metric in multiMetricsList:
                OUTFILE.write(",%s" % (metric))
            for metric in cpuMetricsList:
                OUTFILE.write(",%s" % (metric))
            OUTFILE.write("\n")
            
            # python sucks, there is no default way to crease a multidementional array
            # a better way to do is as follows:
            #epochTimeArray = zeros([2,2]) 
            #xx = zeros([2,2], Float) 
            epochTimeArray = {}
            for i in range(0, totallines+1):
                epochTimeArray[i] = [[],[]]
                epochTimeArray[i][0] = 0.0
                epochTimeArray[i][1] = 0.0

            multiplicityFile = open(source_dir + "/multiplicity_stat" + "_" + workload + '.csv')
            multiCsvRead = csv.DictReader(multiplicityFile)          
  
            i = 0
            for row in multiCsvRead:                       
                epochTimeArray[i][0]= row["date_time"]
                epochTimeArray[i][1] = row["total:DBmsg"]
                i = i + 1
            #set the end point
            epochTimeArray[i][0] = "9999999999"
            epochTimeArray[i][1] = "0"
            i = 0
            for row in csvread:
                if i < totallines:           
                    while float(epochTimeArray[i+1][0]) < float(row["date_time"]):  
                        OUTFILE.write("%s," % (epochTimeArray[i][0]))
                        OUTFILE.write("%s" % (epochTimeArray[i][1]))                   
                        for metric in cpuMetricsList:
                            OUTFILE.write(",")
                        OUTFILE.write("\n") 
                        i = i + 1
                    if float(epochTimeArray[i][0]) < float(row["date_time"]):  
                        OUTFILE.write("%s," % (epochTimeArray[i][0]))
                        OUTFILE.write("%s" % (epochTimeArray[i][1]))                                                                    
                        for metric in cpuMetricsList:
                            OUTFILE.write(",%f" % (float(row[metric])))
                        OUTFILE.write("\n")
                        i = i + 1                                
            csvfile.close();
            OUTFILE.close();
        return
    
    def generateSysVizProcessingScripts(self, bonnServer_source_dir, sysvizServer_output_dir,data_output_name,tiers, importModule):
        
        workloadArray = []
        startTimeArray = []
        endTimeArray = []
        gexp_start_time = 0
        exp_end_time = 0
           
        bonnServer_source_dir_path = bonnServer_source_dir + '/' + data_output_name 
        expTimestampFile = open(bonnServer_source_dir_path + "/EXPERIMENTS_RUNTIME_START.csv")
        expTimestampFileCsv = csv.DictReader(expTimestampFile)
        for row in expTimestampFileCsv:
            workloadArray.append(row["workload"])
            runtimeStart = row["runtimeStart"]
            runtimeStart = string.strip(runtimeStart)
            parts = runtimeStart.split(' ')
            start_time = parts[0][0:len(parts[0])-2]
        
            downRampStart = row["downRampStart"]
            downRampStart = string.strip(downRampStart)
            parts = downRampStart.split(' ')
            end_time = parts[0][0:len(parts[0])-2]
            
            startTimeArray.append(start_time)
            endTimeArray.append(end_time)         
        expTimestampFile.close()
        
        exp_start_time = startTimeArray[0] + "00"
        exp_end_time = endTimeArray[len(endTimeArray)-1] + "00"
        
        
        # open files for output
        prefix = "rubbosAnalyze10_linux"
        protocalName = ""
        if tiers == 3:
            suffix = "middleTwoTier"
            protocalName = "('/ana3', 'HTTP', 'AJP', 'MySQL')"
        elif tiers == 4:
            suffix = "4tier_middleTwoTier"
            protocalName = "('/ana3','/ana2', 'HTTP', 'AJP', 'CJDBC', 'MySQL')"
        #importModule = "analyzer6_linux_middleTwoTier"
        multi_count_in_sec = "20"
        sysVizData_output_dir_path = sysvizServer_output_dir + "/" + data_output_name
        
        
       # workload = "wl3500"
       # start_time = "201106232140";
       # end_time = "201106232140";
        
        pythonFile = prefix + "_" + suffix + ".py"
              
        OUTFILE = open(pythonFile, 'w')
        OUTFILE.write("#! /usr/bin/env python\n")
        OUTFILE.write("import %s\n" % importModule)
        OUTFILE.write("rubbosAnalyzer = %s.analyzer%s\n" % (importModule, protocalName))
        OUTFILE.write("output_dir= '%s/'\n" % (sysVizData_output_dir_path))
        OUTFILE.write("multi_count_in_sec= %s\n\n\n" % (multi_count_in_sec))
        for i in range(0, len(startTimeArray)):
            OUTFILE.write("start_time = %s\n" % str(startTimeArray[i]))
            OUTFILE.write("end_time  = %s\n" % str(endTimeArray[i]))
            OUTFILE.write("suffix  = 'wl%s-50ms'\n" % (workloadArray[i]))
            OUTFILE.write('''rubbosAnalyzer.analyzeDetailedMultiplicityTimeseries(start_time, end_time, multi_count_in_sec, False, output_dir, suffix)
rubbosAnalyzer.analyzeMultiplicityTimeseries(start_time, end_time, multi_count_in_sec, False, output_dir, suffix)
rubbosAnalyzer.analyzeInputOutputAveRS(start_time, end_time, multi_count_in_sec, output_dir, suffix)
rubbosAnalyzer.analyzeInputOutput(start_time, end_time, multi_count_in_sec, output_dir, suffix)
rubbosAnalyzer.analyzeThroughput(start_time, end_time, multi_count_in_sec, output_dir, suffix)
#rubbosAnalyzer.analyzeModelCoverRatio(start_time, end_time, multi_count_in_sec, False, output_dir, suffix)
\n\n''')
        OUTFILE.close();  
        
        #--------------------------------------------
        #Generate shell script to generate SysViz Analysis results
        #--------------------------------------------
        scriptFile = "resultAnalysis.sh"
        script4TierDataGenarate = "sysviz-4tier-middleTwoTier"
        scriptdataPostProcess = "resultPostProcess.sh"
        
        OUTFILE = open('%s/%s' % (bonnServer_source_dir_path,scriptFile), 'w')
        OUTFILE.write("#!/bin/bash\n")
               
        if tiers == 3:
            OUTFILE.write("mkdir %s/%s\n" % (sysvizServer_output_dir, data_output_name))
            OUTFILE.write("cd %s/%s\n" % (sysvizServer_output_dir, data_output_name))
            OUTFILE.write("cp ~/hoge/%s.py ./\n" % (importModule))
            OUTFILE.write("cp ~/hoge/%s ./\n" % (scriptdataPostProcess))
            OUTFILE.write("cp ~/hoge/%s ./\n" % (scriptdataPostProcess))
            OUTFILE.write("python %s\n" % pythonFile)
            OUTFILE.write("./%s\n" % scriptdataPostProcess)
        elif tiers == 4:
            OUTFILE.write("mkdir %s/%s\n" % (sysvizServer_output_dir, data_output_name))
            OUTFILE.write("cd %s/%s\n" % (sysvizServer_output_dir, data_output_name))
            OUTFILE.write("cp ~/hoge/%s.py ./\n" % (importModule))
            OUTFILE.write("cp ~/hoge/%s.py ./\n" % (script4TierDataGenarate))
            OUTFILE.write("cp ~/hoge/%s ./\n" % (scriptdataPostProcess))
            OUTFILE.write("python %s.py %s %s\n" % (script4TierDataGenarate, exp_start_time, exp_end_time))
            OUTFILE.write("python %s\n" % pythonFile)
            OUTFILE.write("./%s\n" % scriptdataPostProcess)
        
        OUTFILE.close()    
        return
    
    def generateSysVizProcessingScripts_TimeWindows(self, bonnServer_source_dir, sysvizServer_output_dir,data_output_name,tiers, importModule):
        workloadArray = []
        startTimeArray = []
        endTimeArray = []
        sAdaptTimeArray = []
        eAdaptTimeArray = []
           
        bonnServer_source_dir_path = bonnServer_source_dir + '/' + data_output_name 
        expTimestampFile = open(bonnServer_source_dir_path + "/EXPERIMENTS_RUNTIME_START.csv")
        expTimestampFileCsv = csv.DictReader(expTimestampFile)
        for row in expTimestampFileCsv:
            #20160221180500 2016-02-21 18:05:19
            workloadArray.append(row["workload"])
            runtimeStart = row["runtimeStart"]
            runtimeStart = string.strip(runtimeStart)
            parts = runtimeStart.split(' ')
            start_time = parts[0][0:len(parts[0])-2]
            
            sAdaptTime = datetime.strptime(parts[1]+" "+parts[2], "%Y-%m-%d %H:%M:%S")
            sAdaptTime += timedelta(hours=6)
            sAdaptTimeArray.append(sAdaptTime.strftime("%Y%m%d%H%M%S"))

        
            downRampStart = row["downRampStart"]
            downRampStart = string.strip(downRampStart)
            parts = downRampStart.split(' ')
            end_time = parts[0][0:len(parts[0])-2]

            
            eAdaptTime = datetime.strptime(parts[1]+" "+parts[2], "%Y-%m-%d %H:%M:%S")
            eAdaptTime += timedelta(hours=6)
            eAdaptTimeArray.append(eAdaptTime.strftime("%Y%m%d%H%M%S"))
            
            startTimeArray.append(start_time)
            endTimeArray.append(end_time)         
        expTimestampFile.close()
        
        files=[]
        with  open(bonnServer_source_dir_path + "/Test_Config.txt") as fp:
            for line in fp:
                files.append(line.split(' ')[0])

        #--------------------------------------------
        #Generate shell script to generate SysViz Analysis results
        #--------------------------------------------   
        pythonDiffHTTPInOutReq = "aggregateInOutPut_HTTPtier.py "
        pythonClientTier = "aggregateInOutPut_ClientTier2.py "
        pythonClientTier_longReq = "aggregateInOutPut_ClientTier_longReq.py "
        pythonNginxParser = "nginx_parser.py"
        pythonNginxTier = "aggregateInOutPut_ClientTier2-nginx.py "
        pythonNginxTier_longReq = "aggregateInOutPut_ClientTier_longReq-nginx.py "
        if tiers == 3:
            pythonExtractLongReq = "extractLongReqsEachTier.py" 
            pythonAggreateResponsTime = "aggregateResposeTime_3tier_2.py "

            proto_alias = "proto_alias.txt" 
        elif tiers == 4:
            pythonExtractLongReq = "extractLongReqsEachTier.py" 
            pythonAggreateResponsTime = "aggregateResposeTime_4tier_2.py "
            proto_alias = "proto_alias.txt"
       
        scriptFile = "protoTimeWindows.sh"
        sysVizData_output_dir_path = sysvizServer_output_dir + "/" + data_output_name       
        OUTFILE = open('%s/%s' % (bonnServer_source_dir_path,scriptFile), 'w')
        OUTFILE.write("#!/bin/bash\n")
        OUTFILE.write("mkdir %s\n\n" % (sysVizData_output_dir_path))
        path_without_transMatch = sysVizData_output_dir_path + '/withoutTransMatch'
        OUTFILE.write("mkdir %s\n\n" % (path_without_transMatch))
        
        if tiers == 3:
            OUTFILE.write("cp ~/hoge/objalias_3tier.csv %s/objalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/resalias_3tier.csv %s/resalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/proto_alias_3tier.txt %s/proto_alias.txt\n" % (path_without_transMatch))
        elif tiers == 4:
            OUTFILE.write("cp ~/hoge/objalias_4tier.csv %s/objalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/resalias_4tier.csv %s/resalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/proto_alias_4tier.txt %s/proto_alias.txt\n" % (path_without_transMatch))
        OUTFILE.write("cp ~/hoge/*.py %s/\n\n\n" % (path_without_transMatch))
        OUTFILE.write("cp %s/detailRT*.csv %s/\n\n\n" % (sysVizData_output_dir_path,path_without_transMatch))
        #OUTFILE.write("cp %s/QueueLength*.csv %s/\n\n\n" % (sysVizData_output_dir_path,path_without_transMatch))
        
        print startTimeArray
        for i in range(0, len(startTimeArray)):         
            tmp_time = time.strptime(startTimeArray[i], '%Y%m%d%H%M')
            stime_epoch = int(time.mktime(tmp_time))
            tmp_time = time.strptime(endTimeArray[i], '%Y%m%d%H%M')
            etime_epoch = int(time.mktime(tmp_time)) + 59
     
            # add proto_proto data of experiments for one workload
            sourceProtoFiles = ''         
            while (stime_epoch <= etime_epoch):
                timeArray = time.localtime(stime_epoch)
                tmpTime = time.strftime('%Y%m%d%H%M', timeArray)
                date = tmpTime[0:8]
                hour = tmpTime[8:10]
                protoFilePath = '/ana/data/proto_proto/' + date + '/' + hour + '/' + tmpTime + '00.proto_proto'
                sourceProtoFiles = sourceProtoFiles + ' ' + protoFilePath
                # add one more minute 
                stime_epoch = stime_epoch + 60               
            timeSpan = startTimeArray[i] + '00-' + endTimeArray[i][len(endTimeArray[i])-2:len(endTimeArray[i])] + '59'

            sysVizData_output_fileName = timeSpan + '.proto_proto_wl' + workloadArray[i]
            destinationProtoFile = path_without_transMatch + '/' + sysVizData_output_fileName
                            
#            OUTFILE.write("cat %s > %s\n" % (sourceProtoFiles, destinationProtoFile))
#            OUTFILE.write("cd %s\n" % (path_without_transMatch))

            OUTFILE.write("cd %s/%s/\n\n\n" % (sysVizData_output_dir_path,files[i])
            OUTFILE.write("cp ../%s . %s" % (pythonClientTier, ""))
            OUTFILE.write("cp ../%s . %s" % (pythonClientTier_longReq, ""))
#            OUTFILE.write("/opt/viz-3.0.0/bin/pairing -o ./ -r %s \
#-p %s -x objalias.csv -y resalias.csv -S /opt/viz-3.0.0/etc/trnmodel/trnmodel.substitute -a 2 -e\n" % (sysVizData_output_fileName, proto_alias))
#            OUTFILE.write("python %s %s %s %s %s\n" % (pythonAggreateResponsTime,timeSpan, startTimeArray[i], endTimeArray[i],workloadArray[i]))
#            OUTFILE.write("python %s %s %s %s %s\n" % (pythonExtractLongReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
#            OUTFILE.write("python %s %s %s %s %s\n" % (pythonDiffHTTPInOutReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            #OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            #OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier_longReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier,timeSpan, sAdaptTimeArray[i], eAdaptTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier_longReq,timeSpan, sAdaptTimeArray[i], eAdaptTimeArray[i], workloadArray[i]))
#            OUTFILE.write("python %s -f `pwd`/zipkin_nginx_wl%s.log\n" % (pythonNginxParser, workloadArray[i]))
#            OUTFILE.write("python %s %s %s %s %s\n" % (pythonNginxTier,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
#            OUTFILE.write("python %s %s %s %s %s\n" % (pythonNginxTier_longReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
#            OUTFILE.write("rm %s \n\n\n\n" % (destinationProtoFile))
            #OUTFILE.write("echo  \n\n\n\n")

        OUTFILE.close()    
        return 

    def generateSysVizProcessingScripts_NoTranMatching(self, bonnServer_source_dir, sysvizServer_output_dir,data_output_name,tiers, importModule):
        workloadArray = []
        startTimeArray = []
        endTimeArray = []
           
        bonnServer_source_dir_path = bonnServer_source_dir + '/' + data_output_name 
        expTimestampFile = open(bonnServer_source_dir_path + "/EXPERIMENTS_RUNTIME_START.csv")
        expTimestampFileCsv = csv.DictReader(expTimestampFile)
        for row in expTimestampFileCsv:
            workloadArray.append(row["workload"])
            runtimeStart = row["runtimeStart"]
            runtimeStart = string.strip(runtimeStart)
            parts = runtimeStart.split(' ')
            start_time = parts[0][0:len(parts[0])-2]
        
            downRampStart = row["downRampStart"]
            downRampStart = string.strip(downRampStart)
            parts = downRampStart.split(' ')
            end_time = parts[0][0:len(parts[0])-2]
            
            startTimeArray.append(start_time)
            endTimeArray.append(end_time)         
        expTimestampFile.close()
        

        #--------------------------------------------
        #Generate shell script to generate SysViz Analysis results
        #--------------------------------------------   
        pythonDiffHTTPInOutReq = "aggregateInOutPut_HTTPtier.py "
        pythonClientTier = "aggregateInOutPut_ClientTier2.py "
        pythonClientTier_longReq = "aggregateInOutPut_ClientTier_longReq.py "
        pythonNginxParser = "nginx_parser.py"
        pythonNginxTier = "aggregateInOutPut_ClientTier2-nginx.py "
        pythonNginxTier_longReq = "aggregateInOutPut_ClientTier_longReq-nginx.py "
        if tiers == 3:
            pythonExtractLongReq = "extractLongReqsEachTier.py" 
            pythonAggreateResponsTime = "aggregateResposeTime_3tier_2.py "

            proto_alias = "proto_alias.txt" 
        elif tiers == 4:
            pythonExtractLongReq = "extractLongReqsEachTier.py" 
            pythonAggreateResponsTime = "aggregateResposeTime_4tier_2.py "
            proto_alias = "proto_alias.txt"
       
        scriptFile = "protoToprotoFiltering.sh"
        sysVizData_output_dir_path = sysvizServer_output_dir + "/" + data_output_name       
        OUTFILE = open('%s/%s' % (bonnServer_source_dir_path,scriptFile), 'w')
        OUTFILE.write("#!/bin/bash\n")
        OUTFILE.write("mkdir %s\n\n" % (sysVizData_output_dir_path))
        path_without_transMatch = sysVizData_output_dir_path + '/withoutTransMatch'
        OUTFILE.write("mkdir %s\n\n" % (path_without_transMatch))
        
        if tiers == 3:
            OUTFILE.write("cp ~/hoge/objalias_3tier.csv %s/objalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/resalias_3tier.csv %s/resalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/proto_alias_3tier.txt %s/proto_alias.txt\n" % (path_without_transMatch))
        elif tiers == 4:
            OUTFILE.write("cp ~/hoge/objalias_4tier.csv %s/objalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/resalias_4tier.csv %s/resalias.csv\n" % (path_without_transMatch))
            OUTFILE.write("cp ~/hoge/proto_alias_4tier.txt %s/proto_alias.txt\n" % (path_without_transMatch))
        OUTFILE.write("cp ~/hoge/*.py %s/\n\n\n" % (path_without_transMatch))
        OUTFILE.write("cp %s/detailRT*.csv %s/\n\n\n" % (sysVizData_output_dir_path,path_without_transMatch))
        OUTFILE.write("cp %s/QueueLength*.csv %s/\n\n\n" % (sysVizData_output_dir_path,path_without_transMatch))
        
        for i in range(0, len(startTimeArray)):         
            tmp_time = time.strptime(startTimeArray[i], '%Y%m%d%H%M')
            stime_epoch = int(time.mktime(tmp_time))
            tmp_time = time.strptime(endTimeArray[i], '%Y%m%d%H%M')
            etime_epoch = int(time.mktime(tmp_time)) + 59
            
            # add proto_proto data of experiments for one workload
            sourceProtoFiles = ''         
            while (stime_epoch <= etime_epoch):
                timeArray = time.localtime(stime_epoch)
                tmpTime = time.strftime('%Y%m%d%H%M', timeArray)
                date = tmpTime[0:8]
                hour = tmpTime[8:10]
                protoFilePath = '/ana/data/proto_proto/' + date + '/' + hour + '/' + tmpTime + '00.proto_proto'
                sourceProtoFiles = sourceProtoFiles + ' ' + protoFilePath
                # add one more minute 
                stime_epoch = stime_epoch + 60               
            timeSpan = startTimeArray[i] + '00-' + endTimeArray[i][len(endTimeArray[i])-2:len(endTimeArray[i])] + '59'

            sysVizData_output_fileName = timeSpan + '.proto_proto_wl' + workloadArray[i]
            destinationProtoFile = path_without_transMatch + '/' + sysVizData_output_fileName
                            
            OUTFILE.write("cat %s > %s\n" % (sourceProtoFiles, destinationProtoFile))
            OUTFILE.write("cd %s\n" % (path_without_transMatch))
            OUTFILE.write("/opt/viz-3.0.0/bin/pairing -o ./ -r %s \
-p %s -x objalias.csv -y resalias.csv -S /opt/viz-3.0.0/etc/trnmodel/trnmodel.substitute -a 2 -e\n" % (sysVizData_output_fileName, proto_alias))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonAggreateResponsTime,timeSpan, startTimeArray[i], endTimeArray[i],workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonExtractLongReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonDiffHTTPInOutReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonClientTier_longReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s -f `pwd`/zipkin_nginx_wl%s.log\n" % (pythonNginxParser, workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonNginxTier,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("python %s %s %s %s %s\n" % (pythonNginxTier_longReq,timeSpan, startTimeArray[i], endTimeArray[i], workloadArray[i]))
            OUTFILE.write("rm %s \n\n\n\n" % (destinationProtoFile))
        OUTFILE.close()    
        return 


    def getWorkloadList(self, output_dir):
        
        workloadArray = []
        startTimeArray = []
        endTimeArray = []
           
        expTimestampFile = open(output_dir + "/EXPERIMENTS_RUNTIME_START.csv")
        expTimestampFileCsv = csv.DictReader(expTimestampFile)
        for row in expTimestampFileCsv:
            workloadArray.append(row["workload"])
            runtimeStart = row["runtimeStart"]
            runtimeStart = string.strip(runtimeStart)
            parts = runtimeStart.split(' ')
            start_time = parts[0][0:len(parts[0])-2]
        
            downRampStart = row["downRampStart"]
            downRampStart = string.strip(downRampStart)
            parts = downRampStart.split(' ')
            end_time = parts[0][0:len(parts[0])-2]
            
            startTimeArray.append(start_time)
            endTimeArray.append(end_time)         
        expTimestampFile.close()
        
        return  workloadArray

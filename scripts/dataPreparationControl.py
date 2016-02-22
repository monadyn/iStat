'''
Created on Jul 7, 2011

@author: qingyang
'''
import dataPreparation
import csv
import sys
import os

RUBBOS_RESULTS_DIR_CONFIG_FILE = ''

def main():
    # process options
    RUBBOS_RESULTS_DIR_CONFIG_dir = os.getcwd()
    RUBBOS_RESULTS_DIR_CONFIG_FILE = RUBBOS_RESULTS_DIR_CONFIG_dir + '/' + 'set_elba_env.sh'
    
    rubbosAnalyzer = dataPreparation.analyzer('')


    H = {}
    for row in csv.reader(open(RUBBOS_RESULTS_DIR_CONFIG_FILE, "r"), delimiter="=" ):
        if len(row) == 2:
            H[row[0]] = row[1]
            
    bonnServer_out_dir = H["BONN_RUBBOS_RESULTS_DIR_BASE"]
    sysVizServer_output_dir = H["SYSVIZ_RUBBOS_RESULTS_DIR_BASE"]
    rubbosData_output_dir = H["RUBBOS_RESULTS_DIR_NAME"]
    
#    bonnServer_out_dir = '/mnt/sdc/qywang/rubbosResult/2011-06-28T103236-0400-QYW-121-oneCore-DBconn12'
#    sysVizServer_output_dir = '/home/qywang/AnaResult'
    tiers = int(H["EXPERIMENT_CONFIG_TIERS"])

    if tiers ==3:
        importModule = "analyzer6_linux_middleTwoTier" 
        rubbosAnalyzer.generateSysVizProcessingScripts(bonnServer_out_dir, sysVizServer_output_dir, rubbosData_output_dir, tiers, importModule)
    elif tiers == 4:
        importModule = "analyzer6_linux_4tier_middleTwoTier" 
        rubbosAnalyzer.generateSysVizProcessingScripts(bonnServer_out_dir, sysVizServer_output_dir, rubbosData_output_dir, tiers, importModule)

    rubbosAnalyzer.generateSysVizProcessingScripts(bonnServer_out_dir, sysVizServer_output_dir, rubbosData_output_dir, tiers, importModule)
    rubbosAnalyzer.generateSysVizProcessingScripts_NoTranMatching(bonnServer_out_dir, sysVizServer_output_dir, rubbosData_output_dir, tiers, importModule)
    rubbosAnalyzer.generateSysVizProcessingScripts_TimeWindows(bonnServer_out_dir, sysVizServer_output_dir, rubbosData_output_dir, tiers, importModule)
if __name__ == '__main__':
    main()
    


#!/bin/bash
#cd /home/hshan/rubbos_base/scripts
cd   /sshfsmount/elba_script/
source set_elba_env.sh

cd $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME



#generate results
cp /home/hshan/rubbos_base/scripts/extract-results_BO.prl ./
cp /home/hshan/rubbos_base/scripts/create-sarExcel_newSarFormat.prl ./
cp /home/hshan/rubbos_base/scripts/Experiments_finegrainedCPU_extract.py ./
cp /home/hshan/rubbos_base/scripts/Experiments_runtime_extract.py ./
cp /home/hshan/rubbos_base/scripts/oprofileExtract.py ./
cp /home/hshan/rubbos_base/scripts/sarResourceUtilExtractAve.py ./
cp /home/hshan/rubbos_base/scripts/javaGCextraction.py ./
cp /home/hshan/rubbos_base/scripts/dataPreparation*.py ./
cp /home/hshan/rubbos_base/scripts/extract_longReq_clientSide.py ./
cp /home/hshan/rubbos_base/scripts/extract_rubbos_results2.py ./
cp /home/hshan/rubbos_base/scripts/Experiments_files_AddworkloadPrefix.py ./
cp /home/hshan/rubbos_base/scripts/Experiments_esxtopProcessing.py ./
cp /home/hshan/rubbos_base/scripts/PowerDataFiltering.py ./
cp /home/hshan/rubbos_base/scripts/PowerExtraction.py ./
cp /home/hshan/rubbos_base/scripts/collectl*.py ./
cp /home/hshan/rubbos_base/scripts/parser.sh ./
cp /home/hshan/rubbos_base/scripts/chienAn_parser_Trace.py ./
cp /home/hshan/rubbos_base/scripts/TPRS_CSV2Dat.py ./
cp /home/hshan/rubbos_base/scripts/gen_graph.sh ./



#./extract-results_BO.prl > TPRS.csv
#./create-sarExcel_newSarFormat.prl

gunzip */zipkin*.gz

#python Experiments_finegrainedCPU_extract.py
#python Experiments_runtime_extract.py
#python oprofileExtract.py
#python dataPreparationControl.py $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME/set_elba_env.sh
#python sarResourceUtilExtractAve.py
#python javaGCextraction.py
#python extract_longReq_clientSide.py
#python extract_rubbos_results2.py

#python chienAn_parser_Trace.py
#python Experiments_files_AddworkloadPrefix.py
#python Experiments_esxtopProcessing.py
#python PowerDataFiltering.py
##python PowerExtraction.py
#python collectlExtract.py
#python collectlResultFilter.py

#python TPRS_CSV2DAT.py
./gen_graph.sh
#chmod +x protoToprotoFiltering.sh

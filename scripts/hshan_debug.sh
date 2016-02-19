#!/bin/bash



#cd /home/hshan/rubbos_base/scripts
source set_elba_env.sh
#cd -

exit 0

cat 'bbb'
cat 'ccc' 


python Pre_Config.py

echo 'plot TPRS'
echo $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME
pwd
./gen_graph_tprs.sh

echo 'plot collectl'

#BENCHMARK_HOST=hshan-bench
#CLIENT1_HOST=hshan-client
#HTTPD_HOST=hshan-control
#TOMCAT1_HOST=hshan-tomcat
#MYSQL1_HOST=hshan-mysql
echo 'each server'
plot_rs(){
	srvName=$1	
	if [ "$srvName" == "" ]
	then
		echo "error"	
	else
			echo "------>"
			#echo $a_path
			cp $3/gen_graph_one_*.sh $3/$2/
			cd $3/$a_path
			#pwd
			#ls | grep '\.sh'
		
			collectl_file=$(find . -iname "detailRT*.csv"	)
			echo $collectl_file
			pwd
			./gen_graph_one_rs.sh  $collectl_file 
			
	fi
}


plot_srv(){
	srvName=$1	
	if [ "$srvName" == "" ]
	then
		echo "error"	
	else
			echo "------>"
			#echo $a_path
			cp $3/gen_graph_one_*.sh $3/$2/
			cd $3/$a_path
			#pwd
			#ls | grep '\.sh'
		
			collectl_file=$(find . -iname "${srvName}*.csv"	)
			#echo $collectl_file
			pwd
			./gen_graph_one_server.sh $collectl_file $srvName
			
	fi
}

BASIC_DIR=$(pwd)
eval all_paths=($(cat 'Test_Config.txt' | awk '{print $1}'))
#echo ${all_paths[@]}

for a_path in "${all_paths[@]}" 
do
	echo '-->'
	plot_rs "client" $a_path $BASIC_DIR
	for a_srv in $TOMCAT1_HOST $HTTPD_HOST $MYSQL1_HOST $BENCHMARK_HOST $CLIENT1_HOST
	do
		plot_srv $a_srv $a_path $BASIC_DIR
	done
done

#python rubbosAnalyze10_linux_4tier_middleTwoTier.py


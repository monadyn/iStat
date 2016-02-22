#!/bin/bash



#cd /home/hshan/rubbos_base/scripts
source set_elba_env.sh
#cd -
#cat 'bbb'
#cat 'ccc' 

year=2016
comsrvName=hshan-Comb
###########################
#all
python Pre_Config.py

echo 'plot TPRS'
echo $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME
pwd
./gen_graph_tprs.sh

###########################
#each srv
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

gen_data_file(){
#gen header and dat files

 	srvName=$1
                      
        cp $3/gen_graph_one_*.sh $3/$2/
        cd $3/$a_path
 
        csvFile=$(find . -iname "${srvName}*.csv" )
	echo $csvFile
	tail -n +1 $csvFile > ${srvName}.dat
	head -n1 $csvFile > ${srvName}.header
	head -n1 $csvFile > ${comsrvName}.header
	#header=$(head -n1 $csvFile)
	#res_arr=(${header// / })
	#echo  ${res_arr[@]}
}

gen_RT_csvfile(){
        srvName=$1
 
        #cp $3/gen_graph_one_*.sh $3/$2/
        cd $3/$a_path

	awk -F',' '{print ($2,$4)}' detailRT-client_*.csv > 'hshan-RT.csv'
}

gen_gplot(){
	srvName=$1

        cp $3/gen_graph_one_*.sh $3/$2
	cp $3/gen_gplot_one*.sh $3/$2
        cd $3/$a_path
	
	conc1=$(find . -iname 'detailRT-client_wl*csv')
        conc=$(echo $conc1 | egrep -o '[0-9]*')
	
	headerFile=${srvName}.header
	header=$(head -n1 ${headerFile})
	#echo $header
	res_arr=(${header// / })

	
	for key  in "${!res_arr[@]}"
	do  
		#pwd
		#echo "$srvName $key ${res_arr[$key]}"
		#picType=$(echo ${res_arr[$key]} | sed -e "s/\/sec/\\/g")
		picType=${res_arr[$key]//\/sec/}
		#echo '---->'
		echo $conc $srvName $picType
  		./gen_gplot_one_srv.sh ${srvName}.dat  $conc  $srvName  $picType $[key+1]
  		#echo ./gen_gplot_one_srv.sh ${srvName}.dat  $conc  $srvName  $picType $[key+1]
		
		outputFileName=${conc}-${srvName}-${picType}
		gplotFile=${outputFileName}.txt
		gnuplot $gplotFile

                outputCombFileName=${conc}-${comsrvName}-${picType}
                gplotCombFile=${outputCombFileName}.tail.txt
		tail -n7  $gplotFile >> $gplotCombFile
		#cat $gplotFile >> $gplotCombFile
                
		#gen_comb_gplot_header  $conc $comsrvName   $picType 
		
	done  

}



 
gen_comb_gplot_header(){

	comConc=$1
	comsrvName=$2
	comPicType=$3

        comOutputFileName=${comConc}-${comsrvName}-${comPicType}
        gplotcomFile=${comOutputFileName}.header.txt



 	echo "set term png size 1200,1800" >> $gplotcomFile;
    	echo set output '"'${comOutputFileName}.png'"' >> $gplotcomFile;
    	echo set multiplot layout 8, 1 title '"' WL$comConc $comsrvName $comPicType '"' >> $gplotcomFile;
 
	#plot
	cat ${comOutputFileName}.header.txt ${comOutputFileName}.tail.txt >> ${comOutputFileName}.txt
	gnuplot ${comOutputFileName}.txt

}

plot_comb_graph(){
	srvName=$1

        cd $3/$a_path
	
	conc1=$(find . -iname 'detailRT-client_wl*csv')
        conc=$(echo $conc1 | egrep -o '[0-9]*')
	
	headerFile=${srvName}.header
	header=$(head -n1 ${headerFile})
	#echo $header
	res_arr=(${header// / })

	
	
	for key  in "${!res_arr[@]}"
	do  
		picType=${res_arr[$key]//\/sec/}
                
		gen_comb_gplot_header  $conc $comsrvName   $picType 
		#echo gen_comb_gplot_header  $conc $comsrvName   $picType 


	done  

}

plot_combination(){
	srvName=$1

        cd $3/$a_path


	conc1=$(find . -iname 'detailRT-client_wl*csv')
        conc=$(echo $conc1 | egrep -o '[0-9]*')

	picType=$4

	outputFileName=${conc}-${srvName}-${picType}
        gplotFile=${outputFileName}.txt

	#merge header
	cat ${outputFileName}.header.txt ${outputFileName}.tail.txt >> ${outputFileName}.txt
	gnuplot $gplotFile

}


plot_comb_customed(){
	srvName=$1

        cd $3/$a_path
	
	conc1=$(find . -iname 'detailRT-client_wl*csv')
        conc=$(echo $conc1 | egrep -o '[0-9]*')
	
	headerFile=${srvName}.header
	header=$(head -n1 ${headerFile})
	#echo $header
	res_arr=(${header// / })


	#1000-hshan-RT-RT.txt  + 1000-hshan-Comb-[CPU]Totl%.txt
	#head
	outputFileName=${conc}-customed2
        echo "set term png size 1200,1800" >> ${outputFileName}.header.txt;
        echo set output '"'${outputFileName}.png'"' >> ${outputFileName}.header.txt;
        echo set multiplot layout 8, 1 title '"' WL$conc'"' >> ${outputFileName}.header.txt;	

	#tail
	#1000-hshan-Comb-RT.tail.txt
	#1000-hshan-Comb-[CPU]Totl%.tail.txt
	#3000-hshan-Comb-total_http.tail.txt
	#3000-hshan-Comb-total_http.tail.txt
	#3000-hshan-Comb-total_http_end.tail.txt	
	echo 'merge gplot -->'
	cat  ${conc}-hshan-Comb-total_http.tail.txt ${conc}-hshan-Comb-total_http_end.tail.txt ${conc}-hshan-Comb-[CPU]Totl%.tail.txt >> ${outputFileName}.tail.txt
	
        cat ${outputFileName}.header.txt ${outputFileName}.tail.txt >> ${outputFileName}.txt
        gnuplot ${outputFileName}.txt

	

}


change_delimiter(){
        srvName=$1

        cd $3/$a_path
	a_file=$(find . -iname "${srvName}*.csv" )
	echo $a_file 

# 1120  find . -iname 'detailRT-client_multiplicity.csv' | xargs rm -f
# 1121  find . -iname 'detailRT-client_inout.csv' | xargs rm -f
# 1122  find . -iname 'detailRT-client_responsetime.csv' | xargs rm -f
        rm -f ${srvName}.csv

	sed 's/,/ /g' $a_file > ${srvName}.csv

 	#rm 
	rm $a_file -f
	echo rm $a_file -f
}

BASIC_DIR=$(pwd)
eval all_paths=($(cat 'Test_Config.txt' | awk '{print $1}'))
#echo ${all_paths[@]}

for a_path in "${all_paths[@]}" 
do
	echo '-->'
	echo $a_path
	#plot_rs "client" $a_path $BASIC_DIR
	#gen_RT_csvfile  'hshan-RT' $a_path $BASIC_DIR
	

	#$CLIENT1_HOST    'hshan-RT' 
	for a_srv in  $TOMCAT1_HOST $HTTPD_HOST $MYSQL1_HOST $BENCHMARK_HOST 
	#for a_srv in 'detailRT-client_inout' 'detailRT-client_multiplicity' 'detailRT-client_responsetime' 
	do
		echo $a_srv
		#change_delimiter  $a_srv $a_path $BASIC_DIR
		gen_data_file  $a_srv $a_path $BASIC_DIR
		gen_gplot $a_srv $a_path $BASIC_DIR	
	done

	for a_srv in  'detailRT-client_inout' 'detailRT-client_multiplicity' 'detailRT-client_responsetime' 
	#for a_srv in 'detailRT-client_inout' 'detailRT-client_multiplicity' 'detailRT-client_responsetime' 
	do
		echo $a_srv
		change_delimiter  $a_srv $a_path $BASIC_DIR
		gen_data_file  $a_srv $a_path $BASIC_DIR
		gen_gplot $a_srv $a_path $BASIC_DIR	
	done
	
	#from combination header files 
	plot_comb_graph	  $comsrvName  $a_path $BASIC_DIR

	#plot client + srv cpu
	plot_comb_customed $comsrvName  $a_path $BASIC_DIR
done

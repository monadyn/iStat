#!/bin/bash
#cd   /sshfsmount/elba_script

#source set_elba_env.sh
#cd -

####
#1 csv file, 2 srv_name


tmpFile=gplot_collectl.txt
dataFile=tmp.dat
csvFile=$1
srvName=$2
echo $@
echo 
tail -n +1 $csvFile > $dataFile

header=$(head -n1 $csvFile)
#echo $header
res_arr=(${header// / })
#echo  ${res_arr[@]}


plot(){
  res=$1 
  indx=$2
  ((indx++))
  
  #echo "$indx $res"
  if [ $indx -gt 1 ]
  #if [[ "$res" =~ ^(cat|dog|horse)$ ]]; 
  then
    #echo $res
    #echo "Generating servers CPU usage graph";
    echo "set term png size 1200,1800" >> $tmpFile;
    echo "set terminal jpeg enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf' 12" > $tmpFile;
    echo set output '"'$3-${res}.jpeg'"' >> $tmpFile;
    echo set title '"'$res'"' >> $tmpFile;
    echo 'set xlabel "Timeline"' >> $tmpFile;
    echo set ylabel '"'$res'"' >> $tmpFile;
    echo "set xdata time" >> $tmpFile;
    echo "set timefmt '%s'" >> $tmpFile;
    echo "set format x '%M:%S'" >> $tmpFile;
    echo 'set key 6000,20' >> $tmpFile;
    #echo "set yrange [0:100]" >> $tmpFile;
    echo plot '"'./$dataFile'"' using 1:$indx with linespoints title '"'$res'"'  >> $tmpFile;
    #echo plot '"'./TPRS.dat'"' using 1:2 with linespoints title '"'Response Time'"' axes x1y1, '"'./TPRS.dat'"' using 1:3 with linespoints title '"'Throughput'"' axes x1y2
    /usr/bin/gnuplot $tmpFile
  fi
}

for key  in "${!res_arr[@]}"
do 
  #echo "$key ${res_arr[$key]}"
  plot ${res_arr[$key]} $key $srvName
done


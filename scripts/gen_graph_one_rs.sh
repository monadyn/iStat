#!/bin/bash
#cd   /sshfsmount/elba_script

#source set_elba_env.sh
#cd -

tmpFile=gplot_rs.txt
csvFile=$1  #'detailRT-client_wl10000.csv'
dataFile=tmp.dat
echo $@
echo 
tail -n +2 $csvFile > $dataFile

header=$(head -n1 $csvFile)
#echo $header
res_arr=(${header// / })
#echo  ${res_arr[@]}


plot(){
    echo "set terminal jpeg enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf' 12" > $tmpFile;
    echo set output '"'client_RS.jpeg'"' >> $tmpFile;
    echo set title '"'Response Time'"' >> $tmpFile;
    echo set datafile separator '"','"' >>$tmpFile
    echo 'set xlabel "Timeline"' >> $tmpFile;
    echo set ylabel '"'Response Time'"' >> $tmpFile;
    echo "set xdata time" >> $tmpFile;
    echo "set timefmt '%s'" >> $tmpFile;
    echo "set format x '%M:%S'" >> $tmpFile;
    echo 'set key 6000,20' >> $tmpFile;
    #echo "set yrange [0:100]" >> $tmpFile;
    echo plot '"'./$dataFile'"' using 1:4 with linespoints title '"'Response Time'"'  >> $tmpFile;
    #echo plot '"'./TPRS.dat'"' using 1:2 with linespoints title '"'Response Time'"' axes x1y1, '"'./TPRS.dat'"' using 1:3 with linespoints title '"'Throughput'"' axes x1y2
    /usr/bin/gnuplot $tmpFile
}

plot

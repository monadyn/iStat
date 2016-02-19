#!/bin/bash
#cd   /sshfsmount/elba_script

#source set_elba_env.sh
#cd -

####
#1 csv file, 2 srv_name


dataFile=$1
conc=$2
srvName=$3
picType=$4
indx=$5
outputFileName=${conc}-${srvName}-${picType}
gplotFile=${outputFileName}.txt
picFile=${outputFileName}.jpeg
rm  $picFile -f
rm  con*.txt -f
gen_gplot(){
    echo "set term png size 1200,1800" >> $gplotFile;
    echo "set terminal jpeg enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf' 12" > $gplotFile;
    echo set output '"'${picFile}'"' >> $gplotFile;
    echo set title '"' WL$conc $srvName $picType '"' >> $gplotFile;
    echo 'set xlabel "Timeline"' >> $gplotFile;
    echo set ylabel '"'$picType'"' >> $gplotFile;
    echo "set xdata time" >> $gplotFile;
    echo "set timefmt '%s'" >> $gplotFile;
    echo "set format x '%M:%S'" >> $gplotFile;
    echo 'set key 6000,20' >> $gplotFile;
    #echo "set yrange [0:100]" >> $gplotFile;
    echo plot '"'./${dataFile}'"' using 1:$indx with linespoints title '"'$picType'"'  >> $gplotFile;
    echo plot '"'./$dataFile'"' using 1:4 with linespoints title '"'Response Time'"'  >> $gplotFile;
    #echo plot '"'./TPRS.dat'"' using 1:2 with linespoints title '"'Response Time'"' axes x1y1, '"'./TPRS.dat'"' using 1:3 with linespoints title '"'Throughput'"' axes x1y2
    #/usr/bin/gnuplot $gplotFile
}

gen_gplot

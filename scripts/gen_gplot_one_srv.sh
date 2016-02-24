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
    #echo '#set key 6000,20' >> $gplotFile;
    echo "f(x)=mean_y" >> $gplotFile;
    echo fit f'('x')' '"'./${dataFile}'"' using 1:$indx via mean_y  >> $gplotFile;
#fit f(x) "./detailRT-client_inout.dat"  u ($1):($3) via mean_y
#plot "./detailRT-client_inout.dat" using 1:3 with linespoints title gprintf("detailRT-client_inout(mean=%g)", mean_y)
    #echo "set yrange [0:100]" >> $gplotFile;
    #echo plot '"'./${dataFile}'"' using 1:$indx with linespoints title '"'$srvName'"'  >> $gplotFile;
    echo plot '"'./${dataFile}'"' using 1:$indx with linespoints title gprintf'("'$srvName'('mean=%g')"', mean_y')'  >> $gplotFile;
    #echo plot '"'./TPRS.dat'"' using 1:2 with linespoints title '"'Response Time'"' axes x1y1, '"'./TPRS.dat'"' using 1:3 with linespoints title '"'Throughput'"' axes x1y2
    #/usr/bin/gnuplot $gplotFile
}

gen_gplot

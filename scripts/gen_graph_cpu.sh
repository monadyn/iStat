#!/bin/bash
#cd   /sshfsmount/elba_script

#source set_elba_env.sh
#cd -

tmpFile=gplot_cpu.txt
dataFile=CPU.dat
cpu_total(){
  python CSV2Dat_CPU.py  

  echo "Generating performance graph";
  echo "set terminal jpeg enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf' 12" > $tmpFile;
  echo set output '"'TEST_TPRS.jpeg'"' >> $tmpFile;
  #echo set grid x y2 >>$tmpFile
  #echo set logscale xy >>$tmpFile
  #echo set log y2 >>$tmpFile
  #echo set datafile separator '"','"' >>$tmpFile
  echo 'set title "CPU total of Different Workloads"' >> $tmpFile;
  echo 'set xlabel "Workloads"' >> $tmpFile;
  echo 'set ylabel "Response Time(ms)"' >> $tmpFile;
  echo 'set y2label "Throughput(req/s)"'>>$tmpFile
  echo  set ytics nomirror >>$tmpFile
  echo  set y2tics >>$tmpFile
  echo  set tics out>>$tmpFile
  echo  'set key top left'>>$tmpFile
  echo  set autoscale y >>$tmpFile
  echo  set autoscale y2 >>$tmpFile
  echo plot '"'./$dataFile'"' using 1:2 with linespoints title '"'Response Time'"' axes x1y1, '"'./$dataFile'"' using 1:3 with linespoints title '"'Throughput'"' axes x1y2 >> $tmpFile;
  /usr/bin/gnuplot $tmpFile  
}

#$1 $2 $3 $4 $5
cpu_total

#!/bin/bash
hdfs dfs -rmr $1
hdfs dfs -mkdir $1
for i in `cat /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/myscripts/worknodes`; do \
 echo $i;  \
 ssh -t $i "/home/yhuang9/hadoop-2.2.0/bin/hadoop dfs -put /home/yhuang9/2010bsp2/*.edge $1"
done

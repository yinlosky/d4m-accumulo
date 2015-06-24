#!/bin/bash
nodes=(hec-48 hec-49 hec-50 hec-51 hec-55 hec-56 hec-58 hec-59)
for i in ${nodes[@]}
do
echo $i;
ssh -t $i "rm -rf /home/yhuang9/2010bsp2/mydata*/*.txt"
done
echo "now starting calculationg log in Main262144_512_16Processors.log"
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M
touch Main262144_512_16Processors.log
echo "Commands: nohup matlab -nodesktop -nosplash -r MainForEigenSolver(9,17,262144,20,6,1,0,1); exit; > Main262144_512_16Processors.log 2>&1 &" >> Main262144_512_16Processors.log
nohup matlab -nodesktop -nosplash -r "MainForEigenSolver(9,17,262144,20,6,1,0,1); exit;" >> Main262144_512_16Processors.log 2>&1 &

#!/bin/bash
nodes=(hec-48 hec-49 hec-50 hec-51 hec-55 hec-56 hec-58 hec-59)
for i in ${nodes[@]}
do
echo $i;
ssh -t $i "rm -rf /home/yhuang9/2010bsp2/mydata*/*.txt"
done

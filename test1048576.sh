#!/bin/bash
# This script will test 8 nodes with 16 processors on 262144 matrix with 512 edges per vertex

# Frist we generate the input matrix 
# This script will generate the input matrix using $1 machines; $2 processors; the matrix has 2^$3 nodes and each nodes has $4 edges
cd /home/yhuang9/MeasureTimeOfAccumuloAndD4M
#mkdir -p finalResults
#echo "Commands: initMatrix(8,22,20,512)" >> finalResults/1048576Input.log
#nohup matlab -nodesktop -nosplash -r "initMatrix(8,22,20,512); exit;" >> finalResults/1048576Input.log 2>&1 &
echo "Commands: MainForEigenSolver(15,15,1048576,20,6,1,1,0)" >> finalResults/better1048576_15machines.log
nohup matlab -nodisplay -nodesktop -nosplash -r "MainForEigenSolver(15,15,1048576,20,6,1,1,0); exit;" >> finalResults/better1048576_15machines.log 2>&1 & 

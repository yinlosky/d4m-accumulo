#!/bin/bash
# This script will test 8 nodes with 16 processors on 262144 matrix with 512 edges per vertex

# Frist we generate the input matrix 
# This script will generate the input matrix using $1 machines; $2 processors; the matrix has 2^$3 nodes and each nodes has $4 edges
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M
matlab -nodesktop -nosplash -r "initMatrix(8,16,18,512); exit;";
matlab -nodesktop -nosplash -r "MainForEigenSolver(9,9,262144,20,6,1,1,0); exit;";

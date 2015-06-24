#!/bin/bash
# This script will generate the input matrix using $1 machines; the matrix has 2^$2 nodes and each nodes has $3 edges
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M
matlab -nodesktop -nosplash -r "initMatrix($1,$2,$3); exit;";

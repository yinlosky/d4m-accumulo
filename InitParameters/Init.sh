#!/bin/bash
echo "Now You are running the initialization of parameters before benchmarking!"
echo "Command: InitParameters($1, $2, $3, $4,$5,$6,$7,$8)"
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/InitParameters
matlab -nodesktop -nosplash -r "InitParameters($1, $2, $3, $4,$5,$6,$7,$8); exit;";

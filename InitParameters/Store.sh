#!/bin/bash
echo "Now You are storing the input matrix to each node's local storage"
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/InitParameters
matlab -nodesktop -nosplash -r " NumOfProcessors = 9; machines={'hec-45' 'hec-48' 'hec-49' 'hec-50' 'hec-51' 'hec-55' 'hec-56' 'hec-58' 'hec-59'} ;eval(pRUN('store',NumOfProcessors,machines)); exit;";

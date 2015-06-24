#!/bin/bash
cd ~/MeasureTimeOfAccumuloAndD4M
nohup matlab -nodesktop -nosplash -r "NumOfProcessors=15;   machines={'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128' 'n129' 'n130' 'n131' 'n132'}; eval(pRUN('store',NumOfProcessors,machines)); exit;" >> finalResults/1048576Run_15machines.log 2>&1 &

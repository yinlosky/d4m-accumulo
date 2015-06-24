#!/bin/bash
cd /home/yhuang9/MeasureTimeOfAccumuloAndD4M
nohup matlab -nodesktop -nosplash -r "machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125'}; NumOfProcessors=9; eval(pRUN('store',NumOfProcessors,machines));exit;" >> finalResults/1048576store.log 2>&1 &

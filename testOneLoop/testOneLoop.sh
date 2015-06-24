#!/bin/bash
echo "Now You are testing matrix multiply a vector in one loop"
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/testOneLoop
matlab -nodesktop -nosplash -r "myDB; cur_it = DB('cur_it'); NumOfProcessors=9; machines={'hec-45' 'hec-48' 'hec-49' 'hec-50' 'hec-51' 'hec-55' 'hec-56' 'hec-58' 'hec-59'}; it=1;  it_assoc = Assoc('1,','1,',sprintf('%d,',it)); put(cur_it,it_assoc); temp = DB('mv_temp'); delete(temp);temp = DB('mv_temp');  this = tic; eval(pRUN('Row_mv',NumOfProcessors,machines)); that = toc(this); disp(['Iteration ' num2str(it) ' Row_mv takes: '  num2str(that)]); exit;";

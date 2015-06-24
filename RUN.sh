#!/usr/bin/env bash
cd /mnt/common/yhuang9/Yinigen
matlab -nodesktop -nosplash -r "initMatrix(8,10,36); diary 1024Ex.txt; startYingen(8,8,1024,9,6,0); diary off; exit;";
matlab -nodesktop -nosplash -r "initMatrix(8,12,512); diary 4096Ex.txt; startYingen(8,8,4096,9,6,0); diary off; exit;";
matlab -nodesktop -nosplash -r "initMatrix(8,14,640); diary 16384Ex.txt; startYingen(8,8,16384,9,6,0); diary off; exit;";

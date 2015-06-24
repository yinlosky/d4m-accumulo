
matlab -nodesktop -nosplash -r "initMatrix(8,13,128); diary 4096Ex.txt; startYingen(8,56,8192,9,6,0,0); diary off; exit;";
matlab -nodesktop -nosplash -r "initMatrix(8,14,128); diary 16384Ex.txt; startYingen(8,56,16384,9,6,0,0); diary off; exit;";
matlab -nodesktop -nosplash -r "initMatrix(8,15,128); diary 16384Ex.txt; startYingen(8,56,32768,9,6,0,0); diary off; exit;";

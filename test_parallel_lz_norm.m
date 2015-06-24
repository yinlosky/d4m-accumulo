%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  File name: test_parallel_lz_norm
%%%
%%%  Paralell run parallel_lz_norm_p1 and then serial p2
%%%  p1 will be running using pRUN to run locally with 2 processors
%%%  p2 will read temp values from table and get the norm value for the input vector.
%%%
myDB;
temp_t = DB('lz_norm_temp');
delete(temp_t); % remove the temp table if exisits already 

eval(pRUN('parallel_lz_norm_p1',2,{})); %% This will run p1 locally using 2 processors. 
parallel_lz_norm_p2;




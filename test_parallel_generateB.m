%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: test_parallel_generateB.m
%% Funciton: this function will test pMatlab to generate random vector B in parallel locally with the NumOfProcessor. 
%%
%% Author:Yin Huang
%% Date: Dec,9,2014

NumOfProcessors = 2;
eval(pRUN('parallel_Generate_B',NumOfProcessors,{})); %% This will run parallel_Generate_B locally using 2 processors. 


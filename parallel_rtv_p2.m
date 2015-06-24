%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%% File Name: parallel_rtv_p2.m
%% Function: This is p2 for calculating rtv, reading data from rtv_temp and sum them up and write to scalar_rtv and 'scalar_rtv'
%%
%% Author: Yin Huang
%% Date: Dec 11, 2014

final = 0;
myDB;
temp = DB('rtv_temp');
output = DB('scalar_rtv');
p = DB('NumOfProcessors');
NumOfProcessors = str2num(Val(p(:,:)));
 [tempR,tempC,tempV] = temp(sprintf('%d,',1:NumOfProcessors),:);
	if(isempty(tempV))
	final = 0;
	else
	final = sum(str2num(tempV));
	end


 Result = Assoc('1,','1,',sprintf('%.15f,',final));
 put(output, Result);

scalar_rtv =  str2num(Val(output('1,','1,')));

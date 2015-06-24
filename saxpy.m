function Path= saxpy(py, px, alph, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: saxpy.m
%% This is the function for calculating  py - px * alph
%% Input:  
%%   	para1: path of y (y is a NumOfNodes-length vector)
%% 	para2: path of x (x is also a NumOfNodes-length vector)
%%	para3: value of alph
%%	para4: path of output
%%	para5: NumOfNodes dimension for the vector
%%	para6: NumOfMachines for parallelization purpose
%% Output: 
%%	Path is the output path of the result
%%      Default will be written to saxpy_output
%%	However, consider y = y - v_i-1*beta_i-1-v_i*alph_i;
%% 	Both will reuse the function, if output is dupilcate as the previous output, we will write to saxpy_output1
%%
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
%% Author: Yin Huang
%% Date: Nov,30,2014
%%
disp(['!!!!!!!Now running saxpy !!!!!!!!!!!!!']);
Default = 'saxpy_output';

myDB;
y = DB(py); 
x = DB(px);

if (strcmp(py,Default))
Path = 'saxpy_output1';
else Path = Default;
end

output = DB(Path);

gap = floor(NumOfNodes / NumOfMachines);
myMachine = 1:NumOfMachines;

for i = myMachine
	tic;
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

for j = start_node:end_node  
% j is the row_id for the vector! We need to set Output = y - x*alph  
% y = str2num(Val(y(sprintf('%d,',j),'1,'))); 
% x = str2num(Val(x(sprintf('%d,',j),'1,')));
% newV = y - x * alph;
% newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
% put(output,newAssoc);
%% This operation might need optimization 
     vy = str2num(Val(y(sprintf('%d,',j),'1,'))); 
     vx = str2num(Val(x(sprintf('%d,',j),'1,')));
     newV = vy - vx * alph;
     newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
     put(output,newAssoc);
end
end
end





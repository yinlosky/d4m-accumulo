function mv_p2(NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: mv_p2.m
%% This is the function for phase 2 of matrix and vectro multiplication
%% Input: 
%%    	 mv_temp table name as hard coded.
%%   	para1: Num of nodes in the graph
%% 	para2: Num of machines for parallelization
%% Output: 
%%      mv_output table will be created and saved 
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
%% Author: Yin Huang
%% Date: Nov,30,2014
%%
disp(['!!!!!!!Now running matrix multiply the vector P2 !!!!!!!!!!!!!']);
disp(['********matrix: mv_temp ************']);
myDB;
temp = DB('mv_temp'); %%hard coded temporary output table
output = DB('mv_output');

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

for j = start_node:end_node  % j is the row_id for the matrix! We need to sum the elements in the same row. 
%% consider each column might be too big we want to do one column at one time 
%% This operation might need optimization 

%%  myCol = str2num(Col(temp('8,',:))) Get all columns in row 8 and myRow is a num matrix !Note: j is the row
%   myCol = str2num(Col(temp(sprintf('%d,',j),:)));   Get all columns in m in row j
 

%  [M,N] = size(myCol) N will be the total number of non-zero elements in the matrix
%  sum = 0;
%  if(N>0)
% 	 for i=1:N   // myCol(i) will be the col of a non-zero element in the matrix, j is the row
%   	 matrix_i = str2num(Val(temp(sprintf('%d,',j),myCol(i))));
%    	sum = sum + matrix_i;
%  	end
%    newAssoc = Assoc(sprintf('%d,',j),sprintf('%d,','1,'),sprintf('%.15f,',sum));           
%    put(output,newAssoc);
%  end

	myCol = str2num(Col(temp(sprintf('%d,',j),:)));   %myCol = str2num(Col(temp(sprintf('%d,',j),:)));   Get all columns in m in row j
 
	[M,N] = size(myCol); %M will be the total number of non-zero elements in the matrix
	mysum = 0;
	if(M>0)
		for i=1:M
		matrix_i = str2num(Val(temp(sprintf('%d,',j),sprintf('%d,',myCol(i)))));
		mysum = mysum + matrix_i;
		end
		newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',mysum));
		put(output,newAssoc);
	end
end
	
	fileTime = toc;
	disp(['Time: ' num2str(fileTime)]);
 end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_scalarmult_B.m
%% Function: This file will calculate the scalar_B multipy the vector B and the result will be written in table lz_q1
%%
%% Author: Yin Huang
%% Date: Dec 10, 2014

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables defintion %%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the tables 

myDB;

machines_t = DB('NumOfProcessors');
nodes_t = DB('NumOfNodes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));

input_v =DB(['B' num2str(NumOfNodes)]);
scalar_b_path = DB('scalar_b'); % local variable for scalar_b 
output=DB([num2str(NumOfNodes) 'lz_q1']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_s = str2num(Val(scalar_b_path('1,','1,'))); %% get the input scalar
s = 1./input_s; %% read the scalar value and divided by 1 because v= b/||b||

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Scalar value is: ' num2str(s)]);


gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First split the reading from the input table, and calculate the norm(result)^2 and written to local results 
%% Later, all local results are summed up and sqr root for the final norm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
	tic;
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	length = end_node - start_node+1;
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node) 'length: ' num2str(length)]);
	%%%%%%%%%%%%%%%%%Below read one value from the table once and change the value and then insert back to the database%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Below might need optimization for performance

 	[vectorRow,vectorCol,vectorVal] = input_v(sprintf('%d,',start_node:end_node),:);
        vectorVal = str2num(vectorVal);
        vectorVal = vectorVal * s; %vector_i * alpha_i
        valStr = sprintf('%.15f,',vectorVal);
        rowStr = sprintf('%d,',str2num(vectorRow));
        colStr = sprintf('%d,',str2num(vectorCol));
        put(output,Assoc(rowStr,colStr,valStr));
	
	fileTime = toc;
	disp(['Time for parallel_scalarmult_B is: ' num2str(fileTime)]);
 end
agg(w); %% wait for processors to finish all the work! This could possibly optimze for performance!!!

 

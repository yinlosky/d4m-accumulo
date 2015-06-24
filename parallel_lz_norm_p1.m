%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This function is a test case for running lz_norm in parallel mode.
%%
%%
%% Author: Yin Huang
%% Date: Dec 9, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Input_table = 'B';
NumOfNodes = 16;
NumOfMachines = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: lz_norm
%% This function is used to calculate the norm of a vector table.
%% 
%% Input vector will be divided into equal chunks among different processors based on the cluster information!
%% Results from different sections will be written to the same accumulo table named lz_norm_temp.
%% After calculating the sum of square of the elements in the vector, and stored the temp result in the lz_norm_temp table. we need read the table and sum the value up and then run a sqrt to get the norm of the input table. lz_norm_temp table will be removed. 
%%
%% Input:
%%	
%%  	para1: The input_table name
%%	para2: Number of nodes in the graph, dimension for the vector
%%	para3: Number of machines in the cluster
myDB;
InputT = DB(Input_table); % create a database binding to the input table.
temp_t = DB('lz_norm_temp'); % create a database binding to the temp table

%%% Parallel read the input_table, and set the range for each reader, each reader will write the sum of sqr in a local directory called lz_norm/iv.txt(i is the id of each reader)

gap = floor(NumOfNodes / NumOfMachines);
%global sum=0;
%myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First split the reading from the input table, and calculate the norm(result)^2 and written to local results 
%% Later, all local results are summed up and sqr root for the final norm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
	tic;
	%fname = ['lz_norm/' num2str(i)]; disp(fname);
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	length = end_node - start_node+1;
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node) 'length: ' num2str(length)]);
	
	
	queryRange = sprintf('%d,',start_node:end_node);
	tempStr=Val(InputT(queryRange,:));
	res = cell2mat(textscan(tempStr,'%.15f','Delimiter','\n')); %% textscan will read well-formatted data into a cell array with new line as delimiter; the result will be transfered into a matrix
	tempSum = norm(res)^2;  %% This is the norm(result)^2. tempSum is to be written on local temp file 
	
	valStr = sprintf('%.15f,', tempSum);
	disp(['Result in ' num2str(i) ' th processor is ' valStr]);
	resultAssoc = Assoc(sprintf('%d,',i),'1,',valStr);
	put(temp_t, resultAssoc);
	%fidVal = fopen([fname 'v.txt'],'w'); %% written to lz_norm/iv.txt
	
	%fwrite(fidVal,valStr); 
	%fclose(fidVal);
	fileTime = toc;
	disp(['Time: ' num2str(fileTime)]);
end
agg(w); %% wait for processors to finish all the work! This could possibly optimze for performance!!!



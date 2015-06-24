function mv_p1(matrix,vector,NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: mv_p1.m
%% This is the function for phase 1 of matrix and vectro multiplication
%% Input: 
%%    	para1: Input_matrix table name
%%   	para2: Vector table name
%%	para3: Num of nodes in the graph
%% 	para4: Num of machines for parallelization
%% Output: 
%%      mv_temp table will be created and populated as the same size of matrix
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['********matrix: ' matrix ' times vector: ' vector ' into mv_temp ************']);
myDB; %% connect to DB and return a binding named DB.
m = DB(matrix);
v = DB(vector);
temp = DB('mv_temp'); %%hard coded temporary output table

gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For now split is evenly distributed among the machines
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
	tic;
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

%%%Query both m and v to multiply the value and store back to mv_temp 
%%%% Below might need optimization for performance

	for j = start_node:end_node
%% consider each column might be too big we want to do one column at one time 
%% This operation might need optimization 

%%  myRow = str2num(Row(m(:,'8,'))) Get all rows in column 8 and my is a num matrix !Note: j is the column
%   myRow = str2num(Row(m(:,sprintf('%d,',j))));   Get all rows in m in column j
%  vector_j = str2num(Val(v(sprintf('%d,',j),'1,')));          // vector_j will be the corresponding vector element to be multiplied 

%  [M,N] = size(myRow) M will be the total number of non-zero elements in the matrix
%  for i=1:M   // myRow(i) will be the row of a non-zero element in the matrix, j is the column 
%    matrix_i = str2num(Val(m(myRow(i),sprintf('%d,'j))));
%    newVal= matrix_i * vector_j;           
%    newAssoc = Assoc(sprintf('%d,',myRow(i)),sprintf('%d,'j),sprintf('%.15f,',newVal));
%    put(temp,newAssoc);
	myRow = str2num(Row(m(:,sprintf('%d,',j))));
	vector_j = str2num(Val(v(sprintf('%d,',j),'1,')));
	[M,N] = size(myRow);
		for i=1:M
		matrix_i = str2num(Val(m(sprintf('%d,',myRow(i)),sprintf('%d,',j))));
		newVal= matrix_i * vector_j;
		newAssoc = Assoc(sprintf('%d,',myRow(i)),sprintf('%d,',j),sprintf('%.15f,',newVal));
		put(temp,newAssoc);
		end
	end
	
	fileTime = toc;
	disp(['Time: ' num2str(fileTime)]);
 end


end

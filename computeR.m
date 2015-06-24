function Rpath = computeR(row,col,Q, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is internal function for selective_orthogonalize.m 
%% r <-- V-row * Q[:,col] Q is the eigenVector matrix, Vi should be reading from lz_q{i} tables
%	Q
%
%
%
%% Output: r should be a n*1 vector and stored in r table
%% Input: 1.row is the number to determing the number of tables to read from lz_q
%%        2.col determines the Q's column index   
%%        3.Q is the right vector for multiplication
%%        4.NumOfNodes is the dimension of V: nx1
%%        5.NumOfMachines for parallization

%%%%%%%%%%%%%%Below is to get the matrix from lz_q{1:row}
v_prefix = 'lz_q';   %% v_prefix is lz_q to retrieve the tables named from lz_q{1:row}
table_names = cell(row,1);
for i = 1:row
	table_names{i} = [v_prefix num2str(i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myDB;
output_table = 'so_matrix_vectorq';
output = DB(output_table);

tables = cell(row,1);
for i = 1:row
	tables{i} = DB(table_names{i});
end

gap = floor(NumOfNodes / NumOfMachines);
%global sum=0;
myMachine = 1:NumOfMachines;
%myMachine = global_ind(zeros(myMachine,1,map([Np 1],{},0:Np-1))); %Parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First split the reading from the input table, and calculate the norm(result)^2 and written to local results 
%% Later, all local results are summed up and sqr root for the final norm.
%%
%%  
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
	tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
%%% Above is for splitting the rows of the matrix v
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     for j = start_node:end_node  % j is the row id for output
	row_sum = 0;
        for k = 1:row             % k is the matrix row iterator id we need read elements from lz_q{1:row} also k is the row id for vector Q	
           v_k = Q(k,col);	  % v_k is the k-th row from col-th column of Q; v_k will multiply j-th row from lz_q{1:row}
	   table = tables{k};
           m_k = str2num(Val(table(sprintf('%d,',j),'1,'))); 
	   row_sum = row_sum + v_k*m_k;
	end
	outAssoc = Assoc(sprintf('%d,',j),'1,', sprintf('%.15f,',row_sum));
	put(output, outAssoc);   %% construct the result and store in the output table 'so_matrix_vectorq'
    end
end
Rpath = output_table;
end





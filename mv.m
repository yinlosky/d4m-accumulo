function aqnpath=mv(Input_matrix, Vector,NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: mv.m
%% This is the function for matrix and vectro multiplication.
%% This will first call mv_p1 to multiply each column with corresponding vector element 
%% and then sum the rows of the mv_temp into mv_output
%% Input: 
%%    	para1: Input_matrix table name
%%   	para2: Vector table name
%%	para3: Num of nodes in the graph
%% 	para4: Num of machines for parallelization
%% Output: 
%%	aqnpath is the path that output is written
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['Two phases are involved in this computation']);
mv_p1(Input_matrix, Vector, NumOfNodes, NumOfMachines);
mv_p2(NumOfNodes,NumOfMachines);
aqnpath = 'mv_output';
end



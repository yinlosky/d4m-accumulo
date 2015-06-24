function R = dotproduct(table1, table2, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: dotproduct.m
%% This is the function for alph_i = v_i'.*v (two vectors dotproduct) // both vectors are dense.
%% Input: 
%%  	para1: vector 1
%%	para2: vector 2
%%   	para3: Num of nodes in the graph
%% 	para4: Num of machines for parallelization
%% Output: 
%%      Return the value of dot_prodcut R
%%      dot_output table will be created and saved 
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
%%
%%
%% This is an embarassing parallel job, need attention for parallelization
%%
%% Author: Yin Huang
%% Date: Nov,30,2014
%% Usage: dotprodcut('test_dot1','test_dot2',3,2)
disp(['!!!!!!!Now running dot product for vectors: ' table1 ' and ' table2 ]);
disp(['********output table is: dot_output ************']);
myDB;
v = DB(table1); 
vi = DB(table2);

temp = DB('dot_temp');
output = DB('dot_output');
gap = floor(NumOfNodes / NumOfMachines);
myMachine = 1:NumOfMachines;

for i = myMachine
	
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Two approaches for this embarassing parallel job, one is to multiply one pair once and then sum them up, the other is use iterator 
% Not sure which is faster!!! For now I am taking the first approach.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp_sum = 0;
for j = start_node:end_node  % j is the row_id for the vector! We need to multiply the element from the same row_id. 
	x = str2num(Val(v(sprintf('%d,',j),'1,')));
	y = str2num(Val(vi(sprintf('%d,',j),'1,')));
	temp_sum = temp_sum + x * y;
	end 
  newAssoc = Assoc(sprintf('%d,',i),'1,',sprintf('%.15f,',temp_sum));
  put(temp,newAssoc);
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Above will write NumOfMachines result in the temp table
%  Now we need read all of them and add them up into 
final = 0;
for i = 1:NumOfMachines
	tempV = str2num(Val(temp(sprintf('%d,',i),'1,')));
	final = final + tempV;
end
 Result = Assoc('1,','1,',sprintf('%.15f,',final));
 put(output, Result);

R =  str2num(Val(output('1,','1,')));

end







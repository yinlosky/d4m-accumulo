function TestIterator(MatrixName, NumOfMachines,NumOfProcessors,NumOfNodes)
%%%
%% Author: Yin Huang
%% Date: Feb, 11, 2015
%% 
%% This function amis at testing the performance of query the accumulo table using iterator as against using simple for loop.
%% We will multiply 2 with the values returned from the result and then write them back
%% 
%% Input: 1. The matrix to be searched
%%        2. The maximum number of results for a single query 
%%
tic;
disp([sprintf('\tEvaluating the query performance %s using iterator and simple for loop\n',MatrixName)]);
myDB;
matrix = DB(MatrixName);
Np = NumOfProcessors;
tic;
%myV = 1:NumOfNodes;
myV = global_ind(zeros(NumOfMachines,1,map([Np 1],{},0:Np-1)));    % PARALLEL.
myIt = Iterator(matrix,'elements', ceil((NumOfNodes^2)/Np));

queryStr = sprintf('%d,',myV);
A = myIt(:,queryStr);

gap = floor(NumOfNodes / NumOfMachines);

rowStr='';
colStr='';
valStr='';
tic;
while nnz(A)
	[r,c,v] = A(:,:);
	if(~isempty(v))
		r=str2num(r); c = str2num(c);
		v= str2num(v);
		v = v * 2;
		valStr = strcat(valStr,sprintf('%.15f,',v));
		rowStr = strcat(rowStr, sprintf('%d,',r));
		colStr = strcat(colStr,sprintf('%d,',c));
	end 
	A =myIt();
end
itT = toc;
disp(['iterator time: ' num2str(itT)]);
output = DB([MatrixName '_it']);
delete(output);
output = DB([MatrixName '_it']);
put(output,Assoc(rowStr,colStr,valStr));

output2 = DB([MatrixName '_stupid']);
delete(output2);
output2 = DB([MatrixName '_stupid']);

tic;
for i = myV

    start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
    
    for j= start_node:end_node
    	for jj = 1:NumOfNodes
    	[mr,mc,mv] = matrix(sprintf('%d,',jj),sprintf('%d,',j));
	    	if(~isempty(mv))
		         mr = str2num(mr);
			 	 mc = str2num(mc);
			     mv = str2num(mv);
			     mv = mv *2;
			     put(output2,Assoc(sprintf('%d,',mr),sprintf('%d,',mc),sprintf('%.15f,',mv)));
		     end
		end 
	end 
end 
stupidT=toc;

disp(['Stupid  time: ' num2str(stupidT)]);
totalT =toc;
disp(['Total running time: ' num2str(totalT)]);



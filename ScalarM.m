function A = ScalarM(x, y, z, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Scalar times vector function
%%% x: input vector table
%%% y: output table
%%% z: scalar table
%%% Internal function for ScalarMult.m 
%%% Note: this function will automatically calculate y = x/z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Now running scalar multiply the vector']);
disp(['********vector: ' x ' times scalar: ' num2str(z) ' into ' y ' ************']);
myDB; %% connect to DB and return a binding named DB.

output=DB(y); %% create the output_table;
input_v =DB(x); %% connect to the input vector
input_s = z; %% connect to the input scalar

s = 1./z; %% read the scalar value and divided by 1 because v= b/||b|| 
disp(['Scalar value is: ' num2str(s)]);
gap = floor(NumOfNodes / NumOfMachines);
%global sum=0;
myMachine = 1:NumOfMachines;
%myMachine = global_ind(zeros(myMachine,1,map([Np 1],{},0:Np-1))); %Parallel

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
	for j = start_node:end_node
		newVal = str2num(Val(input_v(sprintf('%d,',j),'1,')))*s; %% Multiply the vector with the s
		newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newVal))
		put(output,newAssoc);
	end
	
	fileTime = toc;
	disp(['Time: ' num2str(fileTime)]);
 end


end

myDB;
format long e;



%%%%%%%%%%%%%%%%%%%%%%%%%%
NumOfNodes = 2.^14;
NumOfMachines =8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B=DB('B16384');
gap = floor(NumOfNodes/NumOfMachines);
w=zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w);
%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
	start_node = (i-1)*gap+1;
	if(i<NumOfMachines)
	end_node = i*gap;
	else
	end_node = NumOfNodes;
	end
	length = end_node - start_node+1;
	disp(length);
	rowStr = sprintf('%d,',start_node:end_node);
	disp(rowStr);
	valStr = sprintf('%.15f,', rand(1,length,'double'));
	colStr = sprintf('%d,',ones(1,length));

	newAssoc = Assoc(rowStr,colStr,valStr);
	put(B,newAssoc);
end
agg(w);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

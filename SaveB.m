myDB;
format long e;

%%%%%%%%%%%%%%%%%%%%%%%%
MyNodes_t = DB('NumOfNodes');
NumOfNodes = str2num(Val(MyNodes_t('1,','1,')));
BtableName = ['B' num2str(NumOfNodes)];
machines_t = DB('NumOfProcessors');
NumOfMachines = str2num(Val(machines_t('1,','1,')));
B=DB(BtableName);

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
	%disp(length);
	rand('seed',i);
	rowStr = sprintf('%d,',start_node:end_node);
	%disp(rowStr);
	valStr = sprintf('%.15f,', rand(1,length,'double'));
	colStr = sprintf('%d,',ones(1,length));

	newAssoc = Assoc(rowStr,colStr,valStr);
	put(B,newAssoc);
end
agg(w);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%File name: parallel_Generate_B.m
%%This function is used to generate the initial vector B in parallel
%%Input:(para2, para3)
%%	
%%	para2: number of nodes in the graph
%%	para3: number of nodes for parallelization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



myDB;

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
B = DB('B'); % create the table B to store the initial random vector.

%%%% Below parameters are for splitting the file into different parts 
 format long e;
 gap = floor(NumOfNodes / NumOfMachines);
%%%%

myMachine = 1: NumOfMachines;
w = map([Np 1],{},0:Np-1);
myMachine = global_ind(zeros(NumOfMachines,1,w)); %Parallel

for i = myMachine
	tic;

        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	length = end_node - start_node+1;
	disp(length);
	rowStr = sprintf('%d,',start_node:end_node);
	disp(rowStr);
	valStr = sprintf('%.15f,', rand(1,length,'double'));
	colStr = sprintf('%d,',ones(1,length));

	newAssoc = Assoc(rowStr,colStr,valStr);
	put(B,newAssoc);
	fileTime = toc;
	disp(['Time: ' num2str(fileTime) ', Edges/sec: ' num2str(numel(rowStr)./fileTime)]);
end
agg(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    int gap = number_nodes / nmachines;
%% 
%%   String file_name = "lanczos.initial_b.temp";
%%    FileWriter file = new FileWriter(file_name);
%%    BufferedWriter out = new BufferedWriter(file);
%%    out.write("# number of nodes in graph = " + number_nodes + "\n");
%%    System.out.println("creating initial b vector (total nodes = " + number_nodes + ")");

 %%   for (int i = 0; i < nmachines; i++)
 %%   {
 %%     int start_node = i * gap;
 %%     int end_node;
 %%     int end_node;
 %%     if (i < nmachines - 1)
 %%       end_node = (i + 1) * gap - 1;
 %%     else {
 %%       end_node = number_nodes - 1;
 %%     }
 %%     out.write("" + i + "\t" + start_node + "\t" + end_node + "\n");
 %%   }
 %%   out.close();

 %%   FileSystem fs = FileSystem.get(getConf());
 %%   fs.copyFromLocalFile(true, new Path("./" + file_name), new Path(initial_input_path.toString() + "/" + file_name));
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

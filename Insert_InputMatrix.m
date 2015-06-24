function y=Insert_InputMatrix(NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%File name: Insert_InputMatrix.m
%%This function is used to parallelize the read of .mat file from different nodes into table InputMatrix
%%Input:(NumOfMachines)
%%	NumOfMachines: total number of nodes in the cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Below is for connecting the table 
DB = DBserver('localhost:2181','Accumulo','myaccumulo','root','123456');
%%%%
InputMatrix = DB(['InputMatrix']); % create the table inputMatrix to store the initial matrix.

myMachine = 1: NumOfMachines;
%myMachine = global_ind(zeros(myRows,1,map([Np 1],{},0:Np-1))); %Parallel
for i = myMachine
	tic;
	fname = ['data/' num2str(i)]; disp(fname);
	
	load([fname '.mat']);
	disp('Loading the file done!');
	disp('starting insert associative array');
	disp(A);
    
        put(InputMatrix,num2str(A));
	disp('insert done!');
	insertTime = toc;
	disp(['Time: ' num2str(insertTime) ', Edges/sec: ' num2str((nnz(A)./insertTime))]);
end
disp(['Table entries: ' num2str(nnz(InputMatrix))]);


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
function y=InitB(B, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%File name: InitB.m
%%This function is used to generate the initial vector B in parallel
%%Input:(para1, para2, para3)
%%	para1: table name as the output
%%	para2: number of nodes in the graph
%%	para3: number of nodes for parallelization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tableName = 'B';
DB = DBserver('localhost:2181','Accumulo','myaccumulo','root','123456');
B = DB([tableName]);

%%%% Below parameters are for splitting the file into different parts 
 gap = floor(NumOfNodes / NumOfMachines);
%%%%

myMachine = 1: NumOfMachines;
%myRows = global_ind(zeros(myRows,1,map([Np 1],{},0:Np-1)));
for i = myMachine
	tic;
	fname = ['myData/' num2str(i)]; disp(fname);
        start_node = i*gap;
	if (i<NumOfMachines)
	end_node = (i+1)*gap -1;
	else 
	end_node = NumOfNodes -1;
	end
	rowStr = sprintf('%d,',start_node:end_node);
	valStr = sprintf('%d,', rand(1,end_node - start_node+1));
	fidRow = fopen([fname 'r.txt'],'w');
	fidVal = fopen([fname 'v.txt'],'w');
	fwrite(fidRow, rowStr); fwrite(fidVal,valStr);
	fclose(fidRow); fclose(fidVal);
	fileTime = toc;
	disp(['Time: ' num2str(fileTime) ', Edges/sec: ' num2str(numel(rowStr)./fileTime)]);
end


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

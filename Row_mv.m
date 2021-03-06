%%%%%%%%%%%%%%%Filename: Row_mv.m%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function: This file will read rows of matrix from accumulo table  and multiply the vector {NumOfNodes}lz_q{cur_it} row by row, the result will be saved to NumOfNodeslz_vpath
%% {NumOfNodes}lz_vpath = matrix * {NumOfNodes}lz_q{cur_it}
%%

myDB; %% connect to DB and return a binding named DB.
disp(['****************** Now Running Row_mv.m ***********************']);
 
%% create a mydata folder in the installation directory of matlab

root = matlabroot;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it= DB('cur_it');
initM_edges = DB('edges');
proc_t=DB('NumOfProcessors');

EdgesPerVertex = str2num(Val(initM_edges('1,','1,')));
NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];
NumOfProcessors = str2num(Val(proc_t('1,','1,')));

m = DB(['M' num2str(NumOfNodes) '_' num2str(EdgesPerVertex)]);
cut_t = DB(['Cut' num2str(NumOfNodes)]);   %% Cut table assigns the tasks to the processors
 output = DB([num2str(NumOfNodes) 'lz_vpath']);
v = DB(vector);
num = DB(['Entries' num2str(NumOfNodes)]);  %% This table stores the elements for each column

w = zeros(Np,1,map([Np 1],{},0:Np-1));

myProc = global_ind(w); %Parallel
	
 %%% TO log the performance%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   if(~exist([root '/timing'],'dir'))
        	mkdir([root '/timing']);
	   else 
		rmdir([root '/timing'],'s')
		mkdir([root '/timing']);
            end

	%fname = ([root '/timing' '/stat.txt']);
	%fstat = fopen(fname,'a+');

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % find the corresponding column numbers for each process 
 
 gap = floor( NumOfNodes / (NumOfProcessors-1)) % Main processor is just waiting

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 
 
for i = myProc
        if(i>1)

                disp(['My i is: ' num2str(i)]);

        if(i==2)
        start_col = 1;
        end_col = (i-1)*gap;
        else
                if(i<Np)
                        start_col = (i-2)*gap+1;
                        end_col = (i-1)*gap;
                end
        end
        if(i==Np)
        start_col = (i-2)*gap+1;
        end_col = NumOfNodes;
        end
        
        disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);
		     fname = ([root '/timing/' 'Machines'  num2str(NumOfMachines) '_'  num2str(i)  '_stat.txt']);
                  fstat = fopen(fname,'a+');

		            %% Read the vector
                        this = tic;
                        [vecr,vecc,vecv] = v(:,'1,');
                        vecr = sscanf(vecr,'%f');
                        %vecc = str2num(vecc);
                        vecv = sscanf(vecv,'%f');
                        myVector = sparse(vecr,1,vecv,NumOfNodes,1);
                        readv = toc(this);
                         fwrite(fstat, ['Read vector: ' num2str(readv) 's' sprintf('\t') ]);
			%%%%%%
     disp('Now start reading from Accumulo and do the calculation');
     
     tmark = tic;
     

     %%%% Below we try to read all rows at one time and see
     %%%% performance

            this = tic;
            
            [localr,localc,localv] = m(sprintf('%d,',start_col:end_col),:);
            
            readdb = toc(this);
            
            fwrite(fstat, ['Read from accumulo: ' num2str(readdb) 's' sprintf('\t') ]);
                           
            this = tic;
			localc = sscanf(localc,'%d');
            localv = sscanf(localv,'%f');
            localr = sscanf(localr,'%d');
            trans = toc(this);
            
            fwrite(fstat, ['Transfer to string: ' num2str(trans) 's' sprintf('\t') ]);
			  
			this = tic;
		    myMatrix = sparse(localr-start_col+1,localc,localv,end_col-start_col+1,NumOfNodes);
			const = toc(this);
			 fwrite(fstat, ['Construct sparse: ' num2str(const) 's' sprintf('\n') ]);
				
			this = tic;
            myresult = myMatrix * myVector;
			multt = toc(this);
			 fwrite(fstat, ['Multiplication: ' num2str(multt) 's' sprintf('\t') ]);
			this = tic;
			 put(output, Assoc(sprintf('%d,',start_col:end_col),'1,',sprintf('%.15f,',full(myresult)))); %% columns is actually the row id
			putt = toc(this);
			   fwrite(fstat, ['Write back: ' num2str(putt) 's' sprintf('\n') ]); 

     totaltime= toc(tmark);
     disp(['Multiplication takes ' num2str(totaltime) ' s!']);
     fwrite(fstat, ['Multiplication takes ' num2str(totaltime) ' s!']);
     fclose(fstat);
        else
        disp('I am just waiting!');
        end
end
disp('Waiting to be agged!');
agg(w);

%{
  if(exist([root '/mydata' num2str(NumOfNodes) '_' num2str(NumOfMachines)  '/' num2str(i) '.txt']))  %% We have one row to multiply
		
			this = tic;
                        inputData = dlmread([root '/mydata' num2str(NumOfNodes) '_' num2str(NumOfMachines)  '/' num2str(i) '.txt']);
			readlocal = toc(this);
			fwrite(fstat, ['Read processor id: ' num2str(i) ' from file costs: ' num2str(readlocal) 's' sprintf('\t') ]);
			
			this = tic;
			onepartofmatrix = sparse(inputData(:,1)-start_col+1,inputData(:,2),inputData(:,3),end_col-start_col+1,NumOfNodes);
			const = toc(this);
			 fwrite(fstat, ['Construct sparse: ' num2str(const) 's' sprintf('\n') ]);
				
			this = tic;
                        myresult = onepartofmatrix * myVector;
			multt = toc(this);
			 fwrite(fstat, ['Multiplication: ' num2str(multt) 's' sprintf('\t') ]);
			this = tic;
			 put(output, Assoc(sprintf('%d,',start_col:end_col),'1,',sprintf('%.15f,',full(myresult)))); %% columns is actually the row id
			putt = toc(this);
			   fwrite(fstat, ['Write back: ' num2str(putt) 's' sprintf('\n') ]); 
                   end
%}


%{
Read row by row is lame!!
 %for rows = start_col:end_col
         disp(['Row is ' num2str(rows)]);
         [mr,mc,maxCol] = num(sprintf('%d,',rows),:);
		 maxCol= str2num(maxCol);
			if(maxCol~=0)
			mIt = Iterator(m,'elements',maxCol);
            
            this = tic;
            
            [localr,localc,localv] = mIt(sprintf('%d,',rows),:);
            
            readdb = toc(this);
            
            fwrite(fstat, ['Read from accumulo: ' num2str(readdb) 's' sprintf('\t') ]);
                           % localr = str2num(localr);
			%for the row we use 1, because we are doing row of matrix times the vector
            
            this = tic;
			localc = sscanf(localc,'%d');
            localv = sscanf(localv,'%f');
            trans = toc(this);
            
            fwrite(fstat, ['Transfer to string: ' num2str(trans) 's' sprintf('\t') ]);
			   % localr = ones(size(localc,1),1);
			   % localr = sscanf(localr,'%d');
            myMatrix = sparse(1,localc,localv,1,NumOfNodes);
                
            this = tic;
            myresult = myMatrix * myVector;
			multt = toc(this);
			fwrite(fstat, ['Multiplication: ' num2str(multt) 's' sprintf('\t') ]);
            this = tic;
			put(output, Assoc(sprintf('%d,',rows),'1,',sprintf('%.15f,',full(myresult)))); %% columns is actually the row id
			putt = toc(this);
            fwrite(fstat, ['Write back: ' num2str(putt) 's' sprintf('\n') ]); 

            end
    % end


%}

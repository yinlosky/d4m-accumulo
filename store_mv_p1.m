%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filename: store_mv_p1.m
%% Function: This file will save the corresponding part of input matrix to local disk for speeding up future computation. 
myDB; %% connect to DB and return a binding named DB.

%% create a mydata folder in the installation directory of matlab
root = matlabroot;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it= DB('cur_it');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];


disp(['****************** Now Running store_mv_p1.m ***********************']);

m = DB(['M' num2str(NumOfNodes)]);
cut_t = DB(['Cut' num2str(NumOfNodes)]);   %% Cut table assigns the tasks to the processors
temp = DB('mv_temp'); %%hard coded temporary output table
v = DB(vector);
num = DB(['Entries' num2str(NumOfNodes)]);  %% This table stores the elements for each column

w = zeros(Np,1,map([Np 1],{},0:Np-1));

myProc = global_ind(w); %Parallel



%%% Split the tasks based on the cut{numofnodes} table, cut_t(i-1,:) is the end column for current i and cut_t(i-2,:)+1 is the start_col for current i

for i = myProc
	if(i>1)

		disp(['My i is: ' num2str(i)]);

        if(i==2)
        start_col = 1;
        end_col = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
        else
                if(i<Np)
                        start_col = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
                        end_col = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
                end
        end
        if(i==Np)
        start_col = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
        end_col = NumOfNodes;
        end
        disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);

		for columns = start_col:end_col
			if(exist([root '/mydata/' num2str(i) '_' num2str(columns)  '.txt']))	
			inputData = dlmread([root '/mydata/' num2str(i) '_' num2str(columns)  '.txt']);
     			   rowStr = sprintf('%d,',inputData(:,1));
       			 colStr = sprintf('%d,',inputData(:,2));
       			 valStr = sprintf('%d,',inputData(:,3));


			
			ArowStr = '';
			AcolStr = sprintf('%d,',columns);
			AvalStr = '';
			
 			if(~isempty(Val(v(sprintf('%d,',columns),:))))
                        %disp(['columns is ' num2str(columns)]);
                     	Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
					
		
			localv = inputData(:,3) * Jvector;
		
			 ArowStr = colStr;
                           % AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                            AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                            put(temp,Assoc(ArowStr,AcolStr,AvalStr));

			end
		   end
		end

	else
	disp(['I am just waiting!']);
	end
end
agg(w);

%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For now split is evenly distributed among the machines
%p = floor(NumOfNodes / NumOfMachines);
%colGap = floor(NumOfNodes / NumOfMachines);
%NpPerMachine = floor(Np/NumOfMachines);
%lazy = ceil(Np/NumOfMachines);

colGap = floor(NumOfNodes / (Np-1)); %% Actually working processors = Np - 1; Because the process 0 is just waiting.

%rowCut = floor(Np/NumOfMachines);
%colCut = NumOfMachines;
w = zeros(Np,1,map([Np 1],{},0:Np-1));

myProc = global_ind(w); %Parallel
%SecondD = global_ind(w,2);

%We will let the first machine serve as a namenode to wait for all worknodes to finish, the first ceil(Np/NumOfMachines) will be left to the rest nodes to finish
for i = myProc
	disp(['My processes # is :' num2str(i)]);
    if (i>1)
        start_col = (i-1-1)*colGap+1;
        if (i<Np)
        end_col = (i-1)*colGap ;
        else
        end_col = NumOfNodes ;
        end
            disp(['start_col: ' num2str(start_col) ' end_col: ' num2str(end_col)]);

            ArowStr = '';
	    AcolStr = '';
            AvalStr = '';
	   tic;	
	    allM = m(sprintf('%d,',start_col:end_col),:);
	   queryT = toc;
	  disp(['Query time is: ' num2str(queryT)]);	
            for columns = start_col:end_col
                %// We are gonna assume that our memory is big enough to hold one column of the input matrix. 

                %//Jvector is the corresponding vector row value to be multiplied to our input matrix m.
                %// if Jvector is zero there is no need to do the calculation because all elements will become zero.
                %// columns is the row index for our vector
		%tic;
                %disp(['Current column is ' num2str(columns)])
	%	tic;
                    if(~isempty(Val(v(sprintf('%d,',columns),:))))
                     Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
			%tic;
                        % allM = m(sprintf('%d,',columns),:);
		 	%queryT=toc;
			%disp(['Query time is: ' num2str(queryT)]);
		%	tic;
                         [localr,localc,localv] = allM(sprintf('%d,',columns),:);
                         if(~isempty(localv))
                            localv = str2num(localv);
                            localv = localv * Jvector;
                           % ArowStr = localr
                           % AcolStr = sprintf('%d,',columns)
                           % AvalStr = sprintf('%.15f,',localv)
			     ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                            AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                            AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                           % put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                          end
		%	calT=toc;
		%	disp(['Cal time is: ' num2str(calT)]); 
                    end
	%	iterationT=toc;
	%	disp(['One iteration time is: ' num2str(iterationT)]);
		
           end
	   put(temp,Assoc(ArowStr,AcolStr,AvalStr));
		else
		disp(['I am just waiting']);
		end	   
	 
	end % end for lazy
	
   %% End for w
totalT=toc;
disp(['Total Running time is: ' num2str(totalT)]);
tic;
agg(w);
waitingT=toc;
disp(['Total syn time is: ' num2str(waitingT)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name: my_parallel_mv.m
% Function: This function is to test my idea of computing in a row fashion to multiply the vector.
%% So one pass we will be able to generate {NumOfNodes}lz_vpath

%% We assume that one full vector can be held in main memory %%%%%%%%%%%%%%%%%%

%% Output {NumOfNodes}lz_vpath 

myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];


disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['********matrix:  InputMatrix  times vector: ' vector ' into mv_temp ************']);

m = DB(['M' num2str(NumOfNodes)]);
v = DB(vector);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  We read the vector array first
myVector = v(:,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


temp = DB([num2str(NumOfNodes) 'lz_vpath']); %%hard coded output table
    cut_t = DB(['Cut' num2str(NumOfNodes)]);
%%parallel part%%%

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
		% result string to be written
	        ArowStr = sprintf('%d,',start_col:end_col);;
            	AcolStr = '1,';
            	AvalStr = '';
		%%
		%% Query the input chunk for this processor
           	%tic;
            	%allM = m(sprintf('%d,',start_col:end_col),:);
           	%queryT = toc;
          	%disp(['Query time is: ' num2str(queryT)]);
		%%
	
	%% Begin to work	
	 for columns = start_col:end_col
		tempSum = 0;   %% To sum up the multiplication in the same row
                    if(~isempty(Val(m(sprintf('%d,',columns),:))))
                         [mr,mc,mv] = m(sprintf('%d,',columns),:); %%% mc(k) is the non-zero element's index
			 row_ind = columns;
			 mc = transpose(str2num(mc));
			 mv = transpose(str2num(mv));              %%% 
                         mcSize = size(mc,2);                      %% Total number of non-zero elements in m(columns,:)
			 for k = 1:mcSize
                            if(~isempty(Val(myVector(sprintf('%d,',mc(k)),:))))
				tempSum = tempSum + str2num(Val(myVector(sprintf('%d,',mc(k)),:)))*mv(k);
				end
			 end
		         AvalStr = strcat(AvalStr, sprintf('%.15f,',tempSum));
		    else
			AvalStr = strcat(AvalStr, sprintf('%.15f,',0))	
		    end
	   end 		
                            
                           % ArowStr = localr
                           % AcolStr = sprintf('%d,',columns)
                           % AvalStr = sprintf('%.15f,',localv)
                            put(temp,Assoc(ArowStr,AcolStr,AvalStr));
             
                %       calT=toc;
                %       disp(['Cal time is: ' num2str(calT)]); 
        
        %       iterationT=toc;
        %       disp(['One iteration time is: ' num2str(iterationT)]);
           %put(temp,Assoc(ArowStr,AcolStr,AvalStr));
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name:parallel_mv_p1.m
% Function: this is the p1 of mv in parallel, input matrix is 'InputMatrix', input vector table should read the current iteration value from cur_it table
% Our assumption is that the main memory of one processor is able to hold NumOfNodes/Np 

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
temp = DB('mv_temp'); %%hard coded temporary output table
    cut_t = DB(['Cut' num2str(NumOfNodes)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Extra work distribution%%%%%%
%% Extra columns id are last_index+1: NumOfNodes
extra_table = DB('extra');
last_index = str2num(Val(extra_table(:,:))) + 1;
TotalExtra = NumOfNodes - last_index;
ExtraGap = floor(TotalExtra/(Np-2)); %% Only Np-2 are working for extra.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
	extra_start = last_index + 1 +(i-2)*ExtraGap;
	extra_end = extra_start + (i-1)* ExtraGap -1;
	  disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);	
	  
		for columns = start_col:end_col
                  ArowStr = '';
                AcolStr = '';
                AvalStr = '';
                    if(~isempty(Val(v(sprintf('%d,',columns),:))))
                     Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                         [localr,localc,localv] = m(sprintf('%d,',columns),:);
                         if(~isempty(localv))
                            localv = str2num(localv);
                            localv = localv * Jvector;
                             ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                            AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                            AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                            put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                          end
                    end
           	end% End for
		for columns = extra_start:extra_end
		    ArowStr = '';
                    AcolStr = '';
                    AvalStr = '';
                    if(~isempty(Val(v(sprintf('%d,',columns),:))))
                       Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                         [localr,localc,localv] = m(sprintf('%d,',columns),:);
                         if(~isempty(localv))
                            localv = str2num(localv);
                            localv = localv * Jvector;
                             ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                            AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                            AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                            put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                          end
                    end
		end  %End for

	else 
		if(i<Np)   %% 2<i<Np-1
			start_col = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
			end_col = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
			 disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);
				  for columns = start_col:end_col
                  				ArowStr = '';
                				AcolStr = '';
                				AvalStr = '';
                    			if(~isempty(Val(v(sprintf('%d,',columns),:))))
                     				Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                         			[localr,localc,localv] = m(sprintf('%d,',columns),:);
                         			if(~isempty(localv))
                            			localv = str2num(localv);
                            			localv = localv * Jvector;
                            			 ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                            			AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                            			AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                            			put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                         			 end
                    			end
                			end% End for
					
			if(ExtraGap~=0)  %% We have extra work
			extra_start = last_index+1+(i-2)*ExtraGap;
			extra_end = extra_start+(i-1)*ExtraGap -1;
			disp(['Extra_start : extra_end ' num2str(extra_start) ' : ' num2str(extra_end)]);
				for columns = extra_start:extra_end
                 		   ArowStr = '';
                    			AcolStr = '';
                    			AvalStr = '';
                    		if(~isempty(Val(v(sprintf('%d,',columns),:))))
                      			 Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                         		[localr,localc,localv] = m(sprintf('%d,',columns),:);
                         		if(~isempty(localv))
                            		localv = str2num(localv);
                            		localv = localv * Jvector;
                             		ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                            		AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                           		 AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                          		  put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                        		  end
                  		  end
                		end  %End for
			end % end extra work
		end %% End 2<i<Np -1
		
		if(i == Np-1)
			start_col = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
                        end_col = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
                         disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);
                                  for columns = start_col:end_col
                                                ArowStr = '';
                                                AcolStr = '';
                                                AvalStr = '';
                                        if(~isempty(Val(v(sprintf('%d,',columns),:))))
                                                Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                                                [localr,localc,localv] = m(sprintf('%d,',columns),:);
                                                if(~isempty(localv))
                                                localv = str2num(localv);
                                                localv = localv * Jvector;
                                                 ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                                                AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                                                AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                                                put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                                                 end
                                        end
                                        end% End for

                        if(ExtraGap~=0)  %% We have extra work
                        extra_start = last_index+1+(i-2)*ExtraGap;
                        extra_end = NumOfNodes; %% Last column for Np-1 is the last column
                        disp(['Extra_start : extra_end ' num2str(extra_start) ' : ' num2str(extra_end)]);
                                for columns = extra_start:extra_end
                                   ArowStr = '';
                                        AcolStr = '';
                                        AvalStr = '';
                                if(~isempty(Val(v(sprintf('%d,',columns),:))))
                                         Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                                        [localr,localc,localv] = m(sprintf('%d,',columns),:);
                                        if(~isempty(localv))
                                        localv = str2num(localv);
                                        localv = localv * Jvector;
                                        ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                                        AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                                         AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                                          put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                                          end
                                  end
                                end  %End for
			end % End for extra work
		
		end %% End i ==Np-1
		
		if(i == Np)
			start_col = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
                	end_col = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
		  	disp(['Start_col : end_col ' num2str(start_col) ' : ' num2str(end_col)]);
		        for columns = start_col:end_col
                                                ArowStr = '';
                                                AcolStr = '';
                                                AvalStr = '';
                                        if(~isempty(Val(v(sprintf('%d,',columns),:))))
                                                Jvector = str2num(Val(v(sprintf('%d,',columns),:)));
                                                [localr,localc,localv] = m(sprintf('%d,',columns),:);
                                                if(~isempty(localv))
                                                localv = str2num(localv);
                                                localv = localv * Jvector;
                                                 ArowStr = strcat(ArowStr,sprintf('%d,',str2num(localc)));
                                                AcolStr =  strcat(AcolStr,sprintf('%d,',str2num(localr)));
                                                AvalStr = strcat(AvalStr, sprintf('%.15f,',localv));
                                                put(temp,Assoc(ArowStr,AcolStr,AvalStr));
                                                 end
                                        end
                                        end% End for
		end	%%End i == Np
	end %% End i >2

   else  %% i == 1
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name:parallel_mv_p2.m
%% Function: p2 of parallel matrix 'InputMatrix' multiply the vector (lz_q{i}), this function will read data from 'mv_temp' and write result in 'lz_vpath' 
%%
%%

myDB; %% connect to DB and return a binding named DB.
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];

disp(['!!!!!!!Now running matrix multiply the vector ' vector ' P2 !!!!!!!!!!!!!']);
disp(['********matrix: mv_temp ************']);

temp = DB('mv_temp'); %%hard coded temporary output table
output = DB([num2str(NumOfNodes) 'lz_vpath']);

   cut_t = DB(['Cut' num2str(NumOfNodes)]);


machines_t = DB('NumOfMachines');
NumOfMachines = str2num(Val(machines_t('1,','1,')));



w = zeros(Np,1,map([Np 1],{},0:Np-1));


myProc = global_ind(w); %Parallel
%% We will sum all rows into the vector, if one row is empty we simply add 0 to the row to avoid mistaken value for the next step vi' * v 

for i = myProc    
    if(i>1)
        if(i==2)
        start_node = 1;
        end_node = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
        else
                if(i<Np)
                        start_node = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
                        end_node = str2num(Val(cut_t(sprintf('%d,',i-1),:)));
                end
        end
        if(i==Np)
        start_node = str2num(Val(cut_t(sprintf('%d,',i-2),:)))+1;
        end_node = NumOfNodes;
        end
     
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);
	%We can do batch writing here because the output is a n vector 
	ArowStr = '';
	AcolStr = '';
	AvalStr = '';    
	for j = start_node:end_node  % j is the row_id for the matrix! We need to sum the elements in the same row. 


     [JR,JC,JVal] = temp(sprintf('%d,',j),:);
	     if(~isempty(JVal)) 
	      JVal = str2num(JVal);
	   	  mysum = sum(JVal);
	     else
	      mysum = 0;
	     end

  	     % rowStr = sprintf('%d,',j);
	     % valStr = sprintf('%.15f,',mysum);
		ArowStr = strcat(ArowStr, sprintf('%d,',j));
		AvalStr = strcat(AvalStr,sprintf('%.15f,',mysum));
	     % put(output,Assoc(rowStr,colStr,valStr));
    end 
	put(output,Assoc(ArowStr,'1,',AvalStr));	
	else 
         disp(['I am just waiting']);
end
end
agg(w);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel
%% We will sum all rows into the vector, if one row is empty we simply add 0 to the row to avoid mistaken value for the next step vi' * v 

for i = myMachine
    start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

	% fetch all rows of value from the mv_temp
 %	RowsOfMatrix = temp(sprintf('%d,',start_node:end_node),:);
    
    % Store the result for building up the associative arrays
      ArowStr ='';
      AcolStr ='';
      AvalStr ='';

	for j = start_node:end_node  % j is the row_id for the matrix! We need to sum the elements in the same row. 
     [JR,JC,JVal] = temp(sprintf('%d,',j),:);
	     if(~isempty(JVal)) 
	      JVal = str2num(JVal);
	   	  mysum = sum(JVal);
	     else
	      mysum = 0;
	     end
		  rowStr = sprintf('%d,',j);
	      colStr = '1,';
	      valStr = sprintf('%.15f,',mysum);
	      ArowStr = strcat(ArowStr,rowStr);
	      AcolStr = strcat(AcolStr,colStr);
	      AvalStr = strcat(AvalStr,valStr);
    end
    	
    	put(output,Assoc(ArowStr,AcolStr,AvalStr));
end
agg(w);
%}	


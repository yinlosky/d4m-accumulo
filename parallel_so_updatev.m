%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name:parallel_so_updatev
%% Function: This is internal function for parallel_selective_orthogonalize.m to calculate 'lz_vpath' = 'lz_vpath' - 'so_rrtv'
%%
%% Author: Yin Huang
%% Date: Dec 11, 2014

myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines'); % we parallel on processors level
np_t = DB('NumOfProcessors');
nodes_t = DB('NumOfNodes');



p_so_rrtv=DB('so_rrtv');

Np = str2num(Val(np_t('1,','1,')));
NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));

%	 cut_t = DB(['Cut' num2str(NumOfNodes)]);


parallel_so_v = DB([num2str(NumOfNodes) 'lz_vpath']);
%parallel_so_rrtv = DB('so_rrtv'); This cause the bug because parallel_so_rrtv is file name

disp(['Calcuating lz_vpath = lz_vpath - so_rrtv' ]);

	colGap = floor(NumOfNodes / (Np-1));
w = zeros(Np,1,map([Np 1],{},0:Np-1));

	myMachine = global_ind(w); %Parallel

	for i = myMachine
		
	         if(i>1)
        start_node = (i-1-1)*colGap+1;
        if (i<Np)
        end_node = (i-1)*colGap ;
        else
        end_node = NumOfNodes ;
        end
		

	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

		valVector = [];
		for j = start_node:end_node  
     	   if(~isempty(parallel_so_v(sprintf('%d,',j),'1,')))	
     		vv = str2num(Val(parallel_so_v(sprintf('%d,',j),'1,')));
		   else
			vv = 0;
		   end
		   if(~isempty(p_so_rrtv(sprintf('%d,',j),'1,')))
			vrrtv = str2num(Val(p_so_rrtv(sprintf('%d,',j),'1,')));
		   else
		    vrrtv = 0;
		   end
     	   newV = vv - vrrtv;
		   valVector(size(valVector,2)+1) = newV;
     	
		end	
		put(parallel_so_v,Assoc(sprintf('%d,',start_node:end_node),'1,',sprintf('%.15f,',valVector)));
	else 
         disp(['I am just waiting']);
	end
end
agg(w);


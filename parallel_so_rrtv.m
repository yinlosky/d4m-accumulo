%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: parallel_so_rrtv.m
%% Function: internal function for parallel_selective_orthogonalize.m
%%
%% This function times 'so_rpath' with 'scalar_rtv' into 'so_rrtv'

%% variables defintion %%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the tables 
disp('Calculating so_rrtv ....')
myDB;
input_v =DB('so_rpath');
scalar_rtv = DB('scalar_rtv'); % local variable for scalar_rtv 
output=DB('so_rrtv');

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
np_t = DB('NumOfProcessors');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
Np = str2num(Val(np_t('1,','1,')));
 
%  cut_t = DB(['Cut' num2str(NumOfNodes)]);
   
scalar_rtvv = str2num(Val(scalar_rtv('1,','1,')));
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
       
    [inVR,inVC,inVV] = input_v(sprintf('%d,',start_node:end_node),:);
	if(~isempty(inVV))
		newV = str2num(inVV) * scalar_rtvv;
		rowStr = sprintf('%d,',str2num(inVR));
		valStr =sprintf('%.15f,',newV);
        put(output,Assoc(rowStr,'1,',valStr));
	end
else 
         disp(['I am just waiting']);
	end
end
agg(w);
%%%%%**********  Old code ************************
%		for j = start_node:end_node  
%		% j is the row_id for the vector! We need to set Output = y - x*alph  
%		% y = str2num(Val(y(sprintf('%d,',j),'1,'))); 
%		% x = str2num(Val(x(sprintf('%d,',j),'1,')));
%		% newV = y - x * alph;
%		% newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
%		% put(output,newAssoc);
%		%% This operation might need optimization 
 %		if(~isempty(input_v(sprintf('%d,',j),'1,')))    		
  %   		vx = str2num(Val(input_v(sprintf('%d,',j),'1,')));
%		else
%		vx = 0;
%		end
 %    		newV = vx * scalar_rtvv;
  %   		newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
%		
 %    		put(output,newAssoc);
%		end	
%	end
%agg(w);
% ******************************************************************

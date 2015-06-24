%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: parallel_sax_beta.m
%% Function: This function will calculate beta_i-1 * v_i-1
%% 			beta is the table 'beta_t';
%% 			v is the table 'lz_q'
%% 			i is read from table 'cur_it'
%%	     Output in 'beta_sax_temp'
%% Author: Yin Huang
%% Date: Dec 11, 2014

myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines'); % we parallel on processors level
np_t = DB('NumOfProcessors');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');
parallel_sax_beta_beta_t = DB('beta');

parallel_sax_beta_output = DB('beta_sax_temp');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
Np = str2num(Val(np_t('1,','1,')));
it = str2num(Val(cur_it('1,','1,')));
	
	%  cut_t = DB(['Cut' num2str(NumOfNodes)]);
	
vector = [num2str(NumOfNodes) 'lz_q' num2str(it - 1)];
parallel_sax_beta_v_t = DB(vector);  %% v_i-1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only calculate when it is not 1 because it is 0, otherwise there is no 0 situation

   	[betaRow,betaCol,betaVal]=parallel_sax_beta_beta_t(sprintf('%d,',it-1),:); 
   	if(~isempty(betaVal))
		parallel_sax_beta_value = str2num(betaVal);
    else
    	parallel_sax_beta_value = 0;
    end 
	
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
	disp(['Iteration ' num2str(it) ' beta ' num2str(parallel_sax_beta_value) ' times ' vector]);
	
	[vectorRow,vectorCol,vectorVal] = parallel_sax_beta_v_t(sprintf('%d,',start_node:end_node),:);
			if (~isempty(vectorVal))	
				vectorVal = str2num(vectorVal);
			else 
				vectorVal = 0;
			end
		vectorVal = vectorVal * parallel_sax_beta_value;  % vector_i-1 * beta_i-1
		valStr = sprintf('%.15f,',vectorVal);
		rowStr = sprintf('%d,',str2num(vectorRow));
		colStr = sprintf('%d,',str2num(vectorCol));
	put(parallel_sax_beta_output,Assoc(rowStr,colStr,valStr));
else %lazy
        disp(['I am just waiting']);	
	end
end
agg(w);

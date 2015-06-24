%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: parallel_sax_v.m
%% Function: This function will calculate v = v - beta_sax_temp - alpha_sax_temp ; if it>1
%%					  v = v - alpha_sax_temp; if i==1
%% input:    alpha_sax_temp is the table 'alpha_sax_temp';
%% 	     beta_sax_temp is the table 'beta_sax_temp'
%%	     v is from 'mv_output'
%% 			
%% Output:  'lz_vpath'
%%
%% Author: Yin Huang
%% Date: Dec 11, 2014

myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines');% we parallel on the processors' level
np_t = DB('NumOfProcessors');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
Np = str2num(Val(np_t('1,','1,')));
parallel_sax_v_alpha_t = DB('alpha_sax_temp');
parallel_sax_v_beta_t = DB('beta_sax_temp');
parallel_sax_v_t = DB([num2str(NumOfNodes) 'lz_vpath']);

NumOfMachines = str2num(Val(machines_t('1,','1,')));

	%cut_t = DB(['Cut' num2str(NumOfNodes)]);

it = str2num(Val(cur_it('1,','1,')));
	colGap = floor(NumOfNodes / (Np-1));
disp(['Calcuating lz_vpath = lz_vpath - beta_sax_temp - alpha_sax_temp with colGap: ' num2str(colGap)]);
	

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

%%% we keep the for loop because we need make sure the query return value sequence is the same or it will give the wrong answer.
        valVector=[];
		for j = start_node:end_node  
		 
              if(~isempty(Val(parallel_sax_v_t(sprintf('%d,',j),'1,'))))    		
     			vv = str2num(Val(parallel_sax_v_t(sprintf('%d,',j),'1,')));
			  else
				vv = 0;
			  end
				if(~isempty(Val(parallel_sax_v_alpha_t(sprintf('%d,',j),'1,'))))
					valpha = str2num(Val(parallel_sax_v_alpha_t(sprintf('%d,',j),'1,')));
				else
					valpha = 0;
				end
				if (it == 1)
					vbeta = 0;
				  else
				  if(~isempty(Val(parallel_sax_v_beta_t(sprintf('%d,',j),'1,'))))
				  vbeta = str2num(Val(parallel_sax_v_beta_t(sprintf('%d,',j),'1,')));
				  else vbeta = 0;
			 	  end
			    end

     		newV = vv - vbeta - valpha;
        	valVector(size(valVector,2)+1)=newV;
     		%newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
     		%put(parallel_sax_v_t,newAssoc);
		end	
		put(parallel_sax_v_t,Assoc(sprintf('%d,',start_node:end_node),'1,',sprintf('%.15f,',valVector)));
	else 
         disp(['I am just waiting']);
	end
	end

	agg(w);


function InitParameters(NumOfMachines,  NumOfProcessors, NumOfNodes, max_iteration,eig_k,KeepB,Nostat,Store)
%%
%% Trying to use scheduler to optimize the performance, but this is an I/O bound problem, so scheduler doesn't seem to help too much. 
%% Nostat == 1 will not re-run scheduler
%% If one = 1, we will run my row based matrix* vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: startYingen.m
%% usage: startYingen(2,16,9,1,6) for serial
%%	      startYingen(2,16,9,2,6) for local 2 processors 
%% Function: This file is used to test my parallel version of eigensovler in Accumulo and D4M since pRUN only supports program rather than function, I need utilize Accumulo table as a global storage for programs to get input value for each iteration. 
%% 

%% Note 1: the main process can read the variables in m files.
%% Note 2: the parallel version should not delete the temporary table, it will mess up other processes' opertaions. So I move the delete temporary table in the main process.
%% Note 3: The inputmatrix will be set as automatically as 'M{NumOfNodes}' say M4096
% Note 4: The random vector B will be set as automatically 'B{NumOfNodes}' say B4096
%% Note 5: The first lz_q1 will be named as {NumOfNodes}lz_q1

%% Author: Yin Huang
%% Date: Dec, 10 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%BUG1: parallel_mv_p1.m needs inputmatrix to be renamed.
if ~exist('benchmark','dir')
        mkdir('benchmark');
end
fname = ('benchmark/stat.txt');
fstat = fopen(fname,'a+');

disp(['Start time: ' sprintf('\n')]);
StartTime = datestr(now);
fwrite(fstat,['***********************************************' sprintf('\n') 'Begin time: ' StartTime sprintf('\n*******************************************')]);
diary (['TwoD' num2str(NumOfNodes) 'logs.txt']);
fwrite(fstat,['**Commands:  startYingen( ' num2str(NumOfMachines) ',' num2str(NumOfProcessors) ',' num2str(NumOfNodes) ','  num2str(max_iteration) ',' num2str(eig_k) ',' num2str(KeepB) ',' num2str(Nostat) ')' ]);
 
lz_allTime = tic;
myDB;
  
	
	switch NumOfMachines
        case 4
                machines = {'hec-63' 'hec-62' 'hec-60' 'hec-59'};
        case 1
                machines={};
        case 3
                machines ={'hec-63' 'hec-62' 'hec-60'};
        case 5
                machines ={'hec-63' 'hec-62' 'hec-60' 'hec-59' 'hec-58'};
        case 6
                machines ={'hec-63' 'hec-62' 'hec-60' 'hec-59' 'hec-58' 'hec-56'};
        case 7
                machines ={'hec-63' 'hec-62' 'hec-60' 'hec-59' 'hec-58' 'hec-56' 'hec-55'};
        case 2
                machines  ={'hec-63' 'hec-62'};
        case 8
                machines={'hec-63' 'hec-62' 'hec-60' 'hec-59' 'hec-58' 'hec-56' 'hec-55' 'hec-53'};
               % machines={'hec-53' 'hec-55' 'hec-56' 'hec-58' 'hec-59' 'hec-60' 'hec-62' 'hec-63'};
end

% Connect to DB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL variables need be accessed by all processors. I store them in the table every processor will read from the table.
NumOfMachines; % num of machines for computation
NumOfNodes; %nodes in the graph
max_iteration; % iteration times 

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
proc_t=DB('NumOfProcessors');

cur_it = DB('cur_it');
alpha_t = DB('alpha'); %% store the alpha array in accumulo table 'alpha'
beta_t = DB('beta'); %% store the beta array in accumulo table 'beta'
parallel_sax_alpha_output = DB('alpha_sax_temp'); % delete temp tables in main note2
parallel_sax_beta_output = DB('beta_sax_temp');   % delete temp tables in main note2
norm_v_temp = DB(['lz_norm_v' num2str(NumOfNodes) '_temp']);
norm_b_temp = DB(['lz_norm_B' num2str(NumOfNodes) '_temp']);
so_rpath = DB('so_rpath');  %% selective orthogonalize intermidate output table
cur_loop_j = DB('cur_loop_j'); %% so inside loop identifier j every process need to know this value to computeR
rtv_temp = DB('rtv_temp'); %% so inside we need calculate the dotproduct of rtv, this table is used to save the temp result
so_rrtv = DB('so_rrtv'); %% so to store the vector 'rrtv' which is used to update lz_vpath, lz_vpath = lz_vpath - so_rrtv;
temp_lz_vpath = DB([num2str(NumOfNodes) 'lz_vpath']);
temp_mv_temp=DB('mv_temp');
temp_dot_temp=DB('dot_temp');

extra_table = DB('extra'); %% This is used as a flag to tell if our partition is not equal and we need set the rest cols to previous machines this is used for scheduler.

delete(alpha_t);
delete(beta_t);
delete(parallel_sax_alpha_output);
delete(parallel_sax_beta_output);
delete(norm_v_temp);
delete(norm_b_temp);
delete(so_rpath);
delete(cur_loop_j);
delete(rtv_temp);
delete(so_rrtv);
delete(temp_lz_vpath);
delete(temp_mv_temp);
delete(temp_dot_temp);
delete(extra_table);

alpha_t = DB('alpha');
beta_t = DB('beta');
parallel_sax_alpha_output = DB('alpha_sax_temp');
parallel_sax_beta_output = DB('beta_sax_temp');
norm_v_temp = DB(['lz_norm_v' num2str(NumOfNodes) '_temp']);
norm_b_temp = DB(['lz_norm_B' num2str(NumOfNodes) '_temp']);
so_rpath = DB('so_rpath');
cur_loop_j = DB('cur_loop_j');
rtv_temp = DB('rtv_temp');
so_rrtv = DB('so_rrtv');
temp_dot_temp=DB('dot_temp');
temp_lz_vpath = DB([num2str(NumOfNodes) 'lz_vpath']);
extra_table = DB('extra');

m_assoc = Assoc('1,','1,',sprintf('%d,',NumOfMachines));
put(machines_t,m_assoc);
n_assoc = Assoc('1,','1,',sprintf('%d,',NumOfNodes));
put(nodes_t,n_assoc);
p_assoc = Assoc('1,','1,',sprintf('%d,',NumOfProcessors));
put(proc_t,p_assoc);
extra_assoc = Assoc('1,','1,','0,'); %% we assume no extra happens 
put(extra_table,extra_assoc);

% 'scalar_b' is the norm of the random vector B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% local variables to construct the Tridigonal matrix%%%%%%%%
alpha = zeros(1,max_iteration);
bet = zeros(1,max_iteration);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hard coded variables
v_prefix = [num2str(NumOfNodes) 'lz_q'];   %% v_prefix is lz_q to retrieve the tables named from lz_q{1:row}
q_path = cell(max_iteration+1,1);
scalar_b_path = 'scalar_b';
B_path = ['B' num2str(NumOfNodes)];

%%% initialize q_path array with the name lz_q{i}%%%%%%%%%%
for i = 1:max_iteration+1
	q_path{i} = [v_prefix num2str(i)];
end
for i = 2:max_iteration+1
	tempary = DB(q_path{i});
	delete(tempary);
end
for i = 1:max_iteration+1
        tempary =DB(q_path{i});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% assume InputMatrix has already been initilized and stored in 'InputMatrix' in my case yes it is the test case.%%%%%

disp([sprintf('\tRunning Yingen with the following configuration:\n')]);
disp([num2str(NumOfMachines) 'machines:' machines sprintf('\n')]);
disp([num2str(NumOfProcessors) sprintf(' processors\t')]);
disp([num2str(NumOfNodes) sprintf(' nodes\t')])
disp([num2str(max_iteration) sprintf(' max iterations\t')]);
disp([num2str(eig_k) sprintf(' top eigen values')]);


%%% initialize random vector b stored in table 'B{NumOfNodes}'
disp(['Initializing the random vector b in table B' num2str(NumOfNodes)]);
% initB.m :
%	1.create the random vector B in table B{NumOfNodes}
%   2.calculate the norm of vector B in scalar_b table
%	3.save the normalized vector B in {NumOfNodes}lz_q1 

if (KeepB ~= 1)
	this = tic;
	initB(NumOfMachines,NumOfProcessors, NumOfNodes,machines);
	that = toc(this);
	disp(['InitB takes: ' num2str(that)]);
	fwrite(fstat,['InitB takes: ' num2str(that) sprintf('\n')]);
end


%%%% Below is to schedule the tasks evenly among all processors %%%%%%%
%%%% The cut of input matrix will be stored in the table Cut{NumOfNodes}
%%%% For parallel part, each processor will read through cut('previous cut',:)+1 until cut('current cut',:)



scheduler = DB(['Cut' num2str(NumOfNodes)]);
totalentries = DB(['Entries' num2str(NumOfNodes)]);
	if(Nostat ~= 1)
		delete(scheduler);
		delete(totalentries);

		scheduler = DB(['Cut' num2str(NumOfNodes)]);
		totalentries = DB(['Entries' num2str(NumOfNodes)]);

		this = tic;
		eval(pRUN('myscheduler',NumOfProcessors,machines));
		that =toc(this);
		disp(['Scheduler 1 running time: ' num2str(that) 's' sprintf('\n')]);
		fwrite(fstat,['Scheduler 1 running time: ' num2str(that) 's' sprintf('\n')]);

		this = tic;
		%myscheduler_p2();
		testscheduler;
		that = toc(this);
		disp(['Scheduler 2 running time: ' num2str(that) 's']);
		fwrite(fstat, ['Scheduler 2 running time: ' num2str(that) 's' sprintf('\n')]);
	end

%%%%% Now we store the input matrices to corresponding work node %%%%
if(Store == 1)
%	this = tic;
%	eval(pRUN('store',NumOfProcessors,machines));
%	that = toc(this);
%	disp(['Store running time: ' num2str(that) 's']);
 %       fwrite(fstat, ['Store running time: ' num2str(that) 's' sprintf('\n')]);
end


%%Now start the for loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fname = ('benchmark/stat.txt');
fstat = fopen(fname,'a+');

for it = 1:max_iteration
	thistic=tic;
	disp('**************myEigen iterations***********************');
	disp(['computing v=Aq ' num2str(it) ' ...']);

    %%%%%%%%%%%%%%%%%%%%%%  matrix * vector begin **********************

	it_assoc = Assoc('1,','1,',sprintf('%d,',it));
	put(cur_it,it_assoc); %% globalize the current iteration so all processors will be able to read the right lz_q{it}
	temp = DB('mv_temp'); delete(temp);temp = DB('mv_temp');  %% remove the temp table from previous operation for paralell_mv_p1.m

%	if(One == 1)
%	this = tic;
%	eval(pRUN('my_parallel_mv',NumOfProcessors,machines));
%	that = toc(this);
%	fwrite(fstat,['Iteration ' num2str(it) ' Matrix * Vector total  takes: '  num2str(that) sprintf('\n')])
%	else	
  if(Store ~= 1)
	this = tic;
  %  eval(pRUN('parallel_mv_p1',NumOfProcessors,machines));
        eval(pRUN('iterator_mv',NumOfProcessors,machines)); 
	that = toc(this);
	disp(['Iteration ' num2str(it) ' Matrix * vector p1 takes: '  num2str(that)]);
        fwrite(fstat,['Iteration ' num2str(it) ' Matrix * vector p1 takes: '  num2str(that) sprintf('\n')]);
		
	           this =tic;
        eval(pRUN('parallel_mv_p2',NumOfProcessors,machines)); %% mv result will be stored in table '{NumOfNodes}lz_vpath'
        that = toc(this);
        fwrite(fstat,['Iteration ' num2str(it) ' Matrix * vector p2 takes: '  num2str(that) sprintf('\n')]);
        disp(['Iteration ' num2str(it) ' Matrix * vector p2 takes: '  num2str(that)]);
%       end
        disp(['Result of v = Aq ' num2str(it) ' is saved in table ' num2str(NumOfNodes) 'lz_vpath']);

		
	else
	  this = tic;
  %  eval(pRUN('parallel_mv_p1',NumOfProcessors,machines));
        eval(pRUN('Row_mv',NumOfProcessors,machines));
        that = toc(this);
        disp(['Iteration ' num2str(it) ' Row_mv takes: '  num2str(that)]);
        fwrite(fstat,['Iteration ' num2str(it) ' Row_mv takes: '  num2str(that) sprintf('\n')]);
	
        disp(['Result of v = Aq ' num2str(it) ' is saved in table ' num2str(NumOfNodes) 'lz_vpath']);
	end

%	   this =tic;
%        eval(pRUN('parallel_mv_p2',NumOfProcessors,machines)); %% mv result will be stored in table '{NumOfNodes}lz_vpath'
%        that = toc(this);
%        fwrite(fstat,['Iteration ' num2str(it) ' Matrix * vector p2 takes: '  num2str(that) sprintf('\n')]);
%        disp(['Iteration ' num2str(it) ' Matrix * vector p2 takes: '  num2str(that)]);
%	end
%	disp(['Result of v = Aq ' num2str(it) ' is saved in table ' num2str(NumOfNodes) 'lz_vpath']);
    
    %%%%%%%%%%%%%  matrix * vector done! ***************************************   

	%% alpha(it) = dotproduct(aqnpath,q_path{it}, NumOfNodes, NumOfMachines);
	%% dotproduct should save the output in table 'dot_output' ('1,','1,'), also result could be read from dot_product;
	%% alpha(it) will read from the dot_output table.

    % num2str(NumOfNodes)
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% vi * v begin **********************************************
	disp(['Computing dotproduct of vi * v ... and saving the result in alpha(' num2str(it) ')']);
	
	parallel_dotproduct_p1_temp = DB('dot_temp');
	this = tic;
	eval(pRUN('parallel_dotproduct_p1',NumOfProcessors,machines));
	alpha(it) = parallel_dotproduct_p2();
	that = toc(this);
	disp(['Iteration ' num2str(it) ' Calculating alpha takes: '  num2str(that)]); 
	fwrite(fstat,['Iteration ' num2str(it) ' Calculating alpha takes: '  num2str(that) sprintf('\n')]);
	delete(parallel_dotproduct_p1_temp);
	disp('Saving alpha to alpha_t');
	alpha_temp_Assoc = Assoc(sprintf('%d,',it),'1,',sprintf('%.15f,',alpha(it)));
	put(alpha_t, alpha_temp_Assoc);
	disp(['Result of alpha[' num2str(it) '] =' num2str(alpha(it)) ' is saved.']);
	
	%%%%%%%%%%%%%%%%%%% vi * v done! *****************************************************

    %%%%%%%%%%%%%%%%%%% Calculating v = v - beta{i-1}*v{i-1} - alpha{i}*v{i} **********************
    %{	
	if(it ~= 1) 
	parallel_sax_beta_output = DB('beta_sax_temp');
	this = tic;
	eval(pRUN('parallel_sax_beta',NumOfProcessors,machines));
	that = toc(this);
	disp(['Iteration ' num2str(it) ' sax_beta: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' sax_beta: '  num2str(that) sprintf('\n')]);
	end 
	parallel_sax_alpha_output = DB('alpha_sax_temp');
	this = tic;
	eval(pRUN('parallel_sax_alpha',NumOfProcessors,machines));
	that = toc(this);
	disp(['Iteration ' num2str(it) ' sax_alpha takes: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' sax_alpha takes: '  num2str(that) sprintf('\n')] );
	this = tic;
	eval(pRUN('parallel_sax_v',NumOfProcessors,machines));
	that = toc(this);
	disp(['Iteration ' num2str(it) ' sax_v takes: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' sax_v takes: '  num2str(that) sprintf('\n')]);
	 delete(parallel_sax_beta_output);
	 delete(parallel_sax_alpha_output);
     %}
	
	
	 this = tic;
        eval(pRUN('onetime_saxv',NumOfProcessors,machines));
        that = toc(this);
        disp(['Iteration ' num2str(it) ' onetime_saxv: '  num2str(that)]);
        fwrite(fstat,['Iteration ' num2str(it) ' onetime_saxv: '  num2str(that) sprintf('\n')]);

	disp(['v is saved in ' num2str(NumOfNodes) 'lz_vpath table']);
     

	%%%%%%%%%%%%%%%%%%% Calculating v = v - beta{i-1}*v{i-1} - alpha{i}*v{i}  Done!**********************

	%*************  Calculating beta{i} = ||v|| *************************************************************

        disp(['Computing beta[' num2str(it) ']...']);
	parallel_lz_norm_v_tempt = DB(['lz_norm_v' num2str(NumOfNodes) '_temp']);
	this = tic;
	eval(pRUN('parallel_lz_norm_v_p1',NumOfProcessors,machines));
	parallel_lz_norm_v_p2; %% scalar_v is written to beta_i in the table beta_t('i,','1,')
	that = toc(this);
	disp(['Iteration ' num2str(it) ' beta takes: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' beta takes: '  num2str(that) sprintf('\n')]);	
	bet(it) = scalar_v;
	delete(parallel_lz_norm_v_tempt);
	disp(['beta[' num2str(it) '] = ' num2str(bet(it))]);
	
	%******** Calculating beta{i} Done locally %%%%%%%%%%%%%%%%%%%


	disp(['Constructing the Tridigonal matrix...']);
	num_ortho = 0;
	tempTmatrix = constructT(it, alpha, bet); 
	[Q,D] = eig(tempTmatrix);
        D = diag(D);
	%% Do selective_orthogonalize locally%%%%
	v_path = ([num2str(NumOfNodes) 'lz_vpath']);
	disp(['NumOfMachines in SO: ' num2str(NumOfMachines) 'Starting so, iterations # is ' num2str(it) ' beta_it value is: ' num2str(bet(it))]);
	this = tic;
	num_ortho = parallel_selective_orthogonalize(it, bet(it), v_path, Q,D, NumOfNodes, NumOfMachines,NumOfProcessors);
	that = toc(this);
	disp(['Iteration ' num2str(it) ' SO takes: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' SO takes: '  num2str(that) sprintf('\n')]);
	disp(['Number of orthongalization: ' num2str(num_ortho)]);

   	

	if(num_ortho > 0)
		disp(['Recomputing beta[' num2str(it) ']']);
		 parallel_lz_norm_v_tempt = DB(['lz_norm_v' num2str(NumOfNodes) '_temp']);
		eval(pRUN('parallel_lz_norm_v_p1',NumOfProcessors,machines));
		parallel_lz_norm_v_p2; %% scalar_v is written to beta_i in the table beta_t('i,','1,')
		bet(it) = scalar_v;
		disp(['beta[' num2str(it) ']=' num2str(bet(it))]);
		delete(parallel_lz_norm_v_tempt);
	end

	if(num_ortho > it - 1)
	disp('The new vector converged. Finishing ...');
        compute_eigval(it, alpha, bet, eig_k);
	save_tridiagonal_matrix(alpha, bet, it);
	break
	end 
	if(bet(it) == 0.0)
	disp(['beta[' num2str(it) ']=0. finishing']);
	disp('Saving the tridiagonal matrix');
	compute_eigval(it, alpha, bet, eig_k);
	save_tridiagonal_matrix(alpha, bet, it);
	break
	end
	
	disp(['Computing q' num2str(it+1) '...']);

	%%%%%%%%%%%%%%  Update {NumOfNodes}lz_vpath %%%%%%%%%%%%%%%%%%%%%%
	this = tic;
	eval(pRUN('parallel_update_q',NumOfProcessors,machines));
	that = toc(this);
	disp(['Iteration ' num2str(it) ' Update Q takes: '  num2str(that)]);
	fwrite(fstat,['Iteration ' num2str(it) ' Update Q takes: '  num2str(that) sprintf('\n')]);
	disp(['q_{' num2str(it+1) '} is calcualted']);

	compute_eigval(it, alpha, bet, eig_k);
	disp('Saving the tridiagonal matrix');
	save_tridiagonal_matrix(alpha, bet, it);
    oneIterationTime=toc(thistic);
    disp(['Iteration: ' num2str(it) ': ' num2str(oneIterationTime) 's']);
	fwrite(fstat,['Iteration: ' num2str(it) ': ' num2str(oneIterationTime) 's' sprintf('\n')]);
end  %% end for loop
%}	
	eval(pRUN('deletefiles',NumOfMachines,machines));
	disp('!!!!!!Reached the max iterations. Finishing...');
	
	disp('Summarizing alpha[] and bet[]...');
	disp(sprintf('\n\talpha\tbeta'));
	for n = 1:max_iteration
	disp([num2str(n) sprintf('\t') num2str(alpha(n)) sprintf('\t\t') num2str(bet(n))]);
	end
	
	alltime = toc(lz_allTime);
	disp(['Total running time is: ' num2str(alltime)]);
	  endtime = datestr(now);

	disp(['Ending time: ' endtime  sprintf('\n')]);
	
	fwrite(fstat,['Ending time: ' endtime  sprintf('\n')]);
	disp(['Begin time: ' StartTime]);
	diary off;
	fclose(fstat);
end %end function

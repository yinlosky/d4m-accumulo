function InitParameters(NumOfMachines,  NumOfProcessors, NumOfNodes, max_iteration,eig_k,KeepB,Nostat,Store)
%% This function will generate all requirements before running the for loop. 
%% This function should run before testing or benchmarking

%% NumOfMachines: The total number of machines to be run
%% NumOfProcessors: The total number of processors to be run
%% NumOfNodes: The size of the matrix
%% max_iteration: The number of iterations
%% eig_K: top K eigenvalues to be calculated
%% KeepB: 1 means keep the random vector B
%% Nostat: 0 means scheduling the workload
%% Store: 1 means store the data from Accumulo to local disk


%% Author: Yin Huang
%% Date: 23,May 2015

%% For example: InitParameters(9, 9, 2^18, 20, 6, 0, 0, 1)
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
	case 9 
		machines={'hec-45' 'hec-48' 'hec-49' 'hec-50' 'hec-51' 'hec-55' 'hec-56' 'hec-58' 'hec-59'};
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
	this = tic;
	eval(pRUN('store',NumOfProcessors,machines));
	that = toc(this);
	disp(['Store running time: ' num2str(that) 's']);
        fwrite(fstat, ['Store running time: ' num2str(that) 's' sprintf('\n')]);
end


%%Now start the for loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fclose(fstat);
end %end function

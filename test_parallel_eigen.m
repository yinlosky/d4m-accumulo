function test_parallel_eigen(NumOfMachines, NumOfNodes, max_iteration, NumOfProcessors,eig_k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: test_parallel_eigen.m
%% usage: test_parallel_eigen(2,16,9,1,6) for serial
%%	  test_parallel_eigen(2,16,9,2,6) for local 2 processors 
%% Function: This file is used to test my parallel version of eigensovler in Accumulo and D4M since pRUN only supports program rather than function, I need utilize Accumulo table as a global storage for programs to get input value for each iteration. 
%% 

%% Note 1: the main process can read the variables in m files.
%% Note 2: the parallel version should not delete the temporary table, it will mess up other processes' opertaions. So I move the delete temporary table in the main process.
%%
%% Author: Yin Huang
%% Date: Dec, 10 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NumOfProcessors; 
tic;
myDB;  % Connect to DB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL variables need be accessed by all processors. I store them in the table every processor will read from the table.
NumOfMachines; % num of machines for computation
NumOfNodes; %nodes in the graph
max_iteration; % iteration times 


machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

alpha_t = DB('alpha'); %% store the alpha array in accumulo table 'alpha'
beta_t = DB('beta'); %% store the beta array in accumulo table 'beta'
parallel_sax_alpha_output = DB('alpha_sax_temp'); % delete temp tables in main note2
parallel_sax_beta_output = DB('beta_sax_temp');   % delete temp tables in main note2
norm_v_temp = DB('lz_norm_v_temp');
norm_b_temp = DB('lz_norm_B_temp');
so_rpath = DB('so_rpath');  %% selective orthogonalize intermidate output table
cur_loop_j = DB('cur_loop_j'); %% so inside loop identifier j every process need to know this value to computeR
rtv_temp = DB('rtv_temp'); %% so inside we need calculate the dotproduct of rtv, this table is used to save the temp result
so_rrtv = DB('so_rrtv'); %% so to store the vector 'rrtv' which is used to update lz_vpath, lz_vpath = lz_vpath - so_rrtv;

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

alpha_t = DB('alpha');
beta_t = DB('beta');
parallel_sax_alpha_output = DB('alpha_sax_temp');
parallel_sax_beta_output = DB('beta_sax_temp');
norm_v_temp = DB('lz_norm_v_temp');
norm_b_temp = DB('lz_norm_B_temp');
so_rpath = DB('so_rpath');
cur_loop_j = DB('cur_loop_j');
rtv_temp = DB('rtv_temp');
so_rrtv = DB('so_rrtv');

m_assoc = Assoc('1,','1,',sprintf('%d,',NumOfMachines));
put(machines_t,m_assoc);
n_assoc = Assoc('1,','1,',sprintf('%d,',NumOfNodes));
put(nodes_t,n_assoc);

% 'scalar_b' is the norm of the random vector B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% local variables to construct the Tridigonal matrix%%%%%%%%
alpha = zeros(1,max_iteration);
bet = zeros(1,max_iteration);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hard coded variables
v_prefix = 'lz_q';   %% v_prefix is lz_q to retrieve the tables named from lz_q{1:row}
q_path = cell(max_iteration+1,1);
input_matrix = 'InputMatrix';
scalar_b_path = 'scalar_b';
B_path = 'B';

%%% initialize q_path array with the name lz_q{i}%%%%%%%%%%
for i = 1:max_iteration+1
	q_path{i} = [v_prefix num2str(i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% assume InputMatrix has already been initilized and stored in 'InputMatrix' in my case yes it is the test case.%%%%%

%%% initialize random vector b stored in table 'B'
eval(pRUN('parallel_Generate_B',NumOfProcessors,{})); %% This will run parallel_Generate_B locally using 2 processors. A random vector B will be created in DB table 'B'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Below is to calculate  v1 %%%%%%%%%%%%%%%%%%%%%%%%%
% First calculate the norm of b %%%%%%%%%%%%%%%%%%%%%
%disp(['***************Calculating v1***************************']);
%scalar_b = lz_norm(B_path, NumOfNodes, NumOfMachines);  % value will be returned to scalar_b, and also input the B, output will be written to l2norm_output
%smult_output = ScalarMult(B_path,scalar_b, NumOfNodes, NumOfMachines);
%myDB;
%v1_table = DB(smult_output);
%new_path = DB(q_path{1});
%delete(new_path);
%rename(v1_table,q_path{1}); %% store the result into q_path{1}.


eval(pRUN('parallel_lz_norm_B_p1',NumOfProcessors,{}));
parallel_lz_norm_B_p2;
disp(['In main process Sum is: ' sprintf('%.15f',scalar_b)]);   %% result is in scalar_b
disp(['Store scalar_b in table scalar_b']);

eval(pRUN('parallel_scalarmult_B',NumOfProcessors,{})); %% running the scalar_b times the B vector and reuslt is stored in lz_q1.
%%%%%%%%%%%%%%%%% v1 is initialized %%%%%%%%%%%%%%%%%%%%%%%

%%Now start the for loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for it = 1:max_iteration
	disp('**************myEigen iterations***********************');
	disp(['computing v=Aq ' num2str(it) ' ...']);
	it_assoc = Assoc('1,','1,',sprintf('%d,',it));
	put(cur_it,it_assoc); %% globalize the current iteration so all processors will be able to read the right lz_q{it}
	%aqnpath= mv(input_matrix, q_path{it},NumOfNodes, NumOfMachines); %% the parameter that is changing is q_path{it} lz_q{i} || so the parallel code will read this value from the table lz_q {this value will store the result from last step.}
        eval(pRUN('parallel_mv_p1',NumOfProcessors,{}));
	eval(pRUN('parallel_mv_p2',NumOfProcessors,{})); %% mv result will be stored in table 'lz_vpath'
 	
	disp(['Result of v = Aq ' num2str(it) ' is saved in table lz_vpath']);
        
	%% alpha(it) = dotproduct(aqnpath,q_path{it}, NumOfNodes, NumOfMachines);
	%% dotproduct should save the output in table 'dot_output' ('1,','1,'), also result could be read from dot_product;
	%% alpha(it) will read from the dot_output table.
	disp(['Computing dotproduct of vi * v ... and saving the result in alpha(' num2str(it) ')']);
	eval(pRUN('parallel_dotproduct_p1',NumOfProcessors,{}));
	parallel_dotproduct_p2;
	alpha(it) = dot_result;
	disp('Saving alpha to alpha_t');
	alpha_temp_Assoc = Assoc(sprintf('%d,',it),'1,',sprintf('%.15f,',alpha(it)));
	put(alpha_t, alpha_temp_Assoc);
	disp(['Result of alpha[' num2str(it) '] =' num2str(alpha(it)) ' is saved.']);
	
	%% v = v - beta_i-1 * vi-1 - alpha_i* vi (vi is the lz_q(i)): three steps: 1. paralell_sax_beta.m 2. parallel_sax_alpha.m 3. parallel_sax_v.m
	%% v will be written to 'lz_vpath' in parallel_sax_v.m   Note: if i == 1, v = v - alpha_sax_temp
	%% beta_sax_temp will store the beta_i-1 * vi-1 vector; 
	%% alpha_sax_temp will store the alpha_i * vi vector; 
	eval(pRUN('parallel_sax_beta',NumOfProcessors,{})); 
	eval(pRUN('parallel_sax_alpha',NumOfProcessors,{}));
	eval(pRUN('parallel_sax_v',NumOfProcessors,{}));
	disp('v is saved in lz_vpath table');

        disp(['Computing beta[' num2str(it) ']...']);
	%bet(it) = lz_norm(v_path,NumOfNodes,NumOfMachines);
	eval(pRUN('parallel_lz_norm_v_p1',NumOfProcessors,{}));
	parallel_lz_norm_v_p2; %% scalar_v is written to beta_i in the table beta_t('i,','1,')
	bet(it) = scalar_v;
	disp(['beta[' num2str(it) '] = ' num2str(bet(it))]);
	
	%% Done locally %%%%%%%%%%%%%%%%%%%
	disp(['Constructing the Tridigonal matrix...']);
	num_ortho = 0;
	tempTmatrix = constructT(it, alpha, bet); 
	[Q,D] = eig(tempTmatrix);
        D = diag(D);
	%% Do selective_orthogonalize locally%%%%
	v_path = 'lz_vpath';
	disp(['Starting so, iterations # is ' num2str(it) ' beta_it value is: ' num2str(bet(it))]);
	num_ortho = parallel_selective_orthogonalize(it, bet(it), v_path, Q,D, NumOfNodes, NumOfMachines,NumOfProcessors);
	disp(['Number of orthongalization: ' num2str(num_ortho)]);

   	

	if(num_ortho > 0)
	disp(['Recomputing beta[' num2str(it) ']']);

	eval(pRUN('parallel_lz_norm_v_p1',NumOfProcessors,{}));
	parallel_lz_norm_v_p2; %% scalar_v is written to beta_i in the table beta_t('i,','1,')
	bet(it) = scalar_v;
	disp(['beta[' num2str(it) ']=' num2str(bet(it))]);
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
	%qnp1_path_temp = ScalarMult(v_path, bet(it), NumOfNodes, NumOfMachines);
	%disp(['Renaming ' qnp1_path_temp ' to ' q_path{it+1}]);
	%temp_db = DB(qnp1_path_temp);
	%old_table = DB(q_path{it+1});
	%delete(old_table);
	%rename(temp_db,q_path{it+1});
	%% lz_q{it+1} = lz_vpath * (1/beta_it);
	%%
	eval(pRUN('parallel_update_q',NumOfProcessors,{}));
	disp(['q_{' num2str(it+1) '} is calcualted']);

	compute_eigval(it, alpha, bet, eig_k);
	disp('Saving the tridiagonal matrix');
	save_tridiagonal_matrix(alpha, bet, it);
	
	end  %% end for loop
	
	if(it>max_iteration)
	disp('!!!!!!Reached the max iterations. Finishing...');
	end
	disp('Summarizing alpha[] and bet[]...');
	disp(sprintf('\n\talpha\tbeta'));
	for n = 1:max_iteration
	disp([num2str(n) sprintf('\t') num2str(alpha(n)) sprintf('\t\t') num2str(bet(n))]);
	end
	alltime = toc;
	disp(['Total running time is: ' num2str(alltime)]);
end %end function
	
	




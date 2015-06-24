function testEigen(NumOfMachines, max_iteration, eig_k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the main method to call eigenSolver to calculate the eigenValues and the Tridiagonalmatrix this version is not parallel
% Tridiagonalmatrix will be saved in the table "lanczos.trimat", alpha and beta will be saved in "lanczos.ab", alpha is in col 1 and beta in col 2
%
% Input: 1. InputMatrix: Input matrix will be generated by Generate_input.m, these data will be written to local disk named data/{ic,ir,iv}.txt, these data should be written into Associative array by write_inputAssoc.m, after which the associative arrays will be inserted into table called 'InputMatrix' by Insert_Inputmatrix.m 
%	 (Scale determines the number of nodes in the graph, edgespervertex is the number of edges per vertice)
%        2. Random Vector B
%        3. max_iteration is the maximum number of iteration for the algorithm 
%        4. eig_k is the number of top k eigenValues and corresponding eigenVectors of interest
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generating the input matrix using KronGraph500NoPerm(SCALE,EdgesPerVertex)
%Generate_input(SCALE, EdgesPerVertex, NumOfMachines) 
% SCALE determines the number of nodes in the graph I chose 12, so 2^12 nodes will be generated
% EdgesPerVertex is the number of edges per vertice, note: KronGraph500 will duplicate the edges, so we use @min to eleminate the weight. 
% NumOfMachines is for parallelization
% Example Generate_input(12, 1, 8)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 
myDB;
NumOfNodes = 16;
alpha = zeros(1,max_iteration);
bet = zeros(1,max_iteration);
v_prefix = 'lz_q';   %% v_prefix is lz_q to retrieve the tables named from lz_q{1:row}
q_path = cell(max_iteration+1,1);
input_matrix = 'InputMatrix';
scalar_b_path = 'l2norm_output';
B_path = 'B';

for i = 1:max_iteration+1
	q_path{i} = [v_prefix num2str(i)];
end

disp('!!!!!!Now running myEigen!!!!!!!!!!!!!!!!');
myRow = '1,2,2,2,3,4,4,4,5,6,7,7,7,7,7,8,9,10,11,11,11,11,11,12,13,14,15,16,';
myCol = '2,1,3,4,2,2,5,7,4,7,4,6,8,9,10,7,7,7,12,13,14,15,16,11,11,11,11,11,';
myV = '1,';
myAssoc = Assoc(myRow,myCol,myV);
myInput = DB(input_matrix);
put(myInput,myAssoc);
%%
%disp('Calling Generate_input.m');
%Generate_input(SCALE, EdgesPerVertex, NumOfMachines);
%disp('-----------------------------------------------------');
%disp('Calling Write_InputAssoc.m');
%Write_InputAssoc(NumOfMachines);
%disp('-----------------------------------------------------');
%disp('Calling Insert_InputMatrix.m');
%Insert_InputMatrix(NumOfMachines);
%disp('InputMatrix has been initialized and ready to be used!');

% Generating the random vector b and stored in table 'B'
% Generate_B.m
% Write_BAssoc.m
% Insert_B.m
disp('****************Now generating the random vector B********');
Generate_B(NumOfNodes, NumOfMachines);
Write_BAssoc(NumOfMachines);
Insert_B(NumOfMachines);
disp('Random vector B has been initialized and ready to be used!');
disp('Input initialization done!')

disp(['Starting myEigen: ' num2str(max_iteration) ' iterations']);
disp(['Input: InputMatrix. Number of Nodes: ' num2str(NumOfNodes) '. NumOfMachines: ' num2str(NumOfMachines) '. Top ' num2str(eig_k) 'eigenvalues and eigenVectors.' ]);

disp(['***************Calculating v1***************************']);
scalar_b = lz_norm(B_path, NumOfNodes, NumOfMachines);  % value will be returned to scalar_b, and also input the B, output will be written to l2norm_output
smult_output = ScalarMult(B_path,scalar_b, NumOfNodes, NumOfMachines);
myDB;
v1_table = DB(smult_output);
new_path = DB(q_path{1});
delete(new_path);
rename(v1_table,q_path{1}); %% store the result into q_path{1}.

%%Now start the for loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for it = 1:max_iteration
	disp('**************myEigen iterations***********************');
	disp(['computing v=Aq ' num2str(it) ' ...']);
	aqnpath= mv(input_matrix, q_path{it},NumOfNodes, NumOfMachines); %% the parameter that is changing is q_path{it} lz_q{i} || so the parallel code will read this value from the table lz_q {this value will store the result from last step.}
	disp(['\n Result of v = Aq ' num2str(it) ' is saved in table ' aqnpath]);
	
	disp(['computing alpha[' num2str(it) ']...']);
        alpha(it) = dotproduct(aqnpath,q_path{it}, NumOfNodes, NumOfMachines);
	disp(['Result of alpha[' num2str(it) '] =' num2str(alpha(it)) ' is saved.']);
	
	v_path = aqnpath;
	if(it ~= 1)
	 	v_path = saxpy(aqnpath, q_path{it-1}, bet(it-1), NumOfNodes, NumOfMachines);
	end
	saxpy_output_path = saxpy(v_path, q_path{it},alpha(it),NumOfNodes,NumOfMachines);
	
	v_path = 'lz_vpath';
	old_path = DB(saxpy_output_path);
	new_path = DB(v_path);
	delete(new_path);
	rename(old_path,v_path);

	disp(['Computing beta[' num2str(it) ']...']);
	bet(it) = lz_norm(v_path,NumOfNodes,NumOfMachines);
	disp(['beta[' num2str(it) '] = ' num2str(bet(it))]);

	num_ortho = 0;
	tempTmatrix = constructT(it, alpha, bet);
	[Q,D] = eig(tempTmatrix);
        D = diag(D);
    
	num_ortho = selective_orthogonalize(it, bet(it), v_path, Q,D, NumOfNodes, NumOfMachines);
	disp(['Number of orthongalization: ' num2str(num_ortho)]);
	
	if(num_ortho > 0)
	disp(['Recomputing beta[' num2str(it) ']']);
	bet(it) = lz_norm(v_path,NumOfNodes,NumOfMachines);
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
	qnp1_path_temp = ScalarMult(v_path, bet(it), NumOfNodes, NumOfMachines);

	disp(['Renaming ' qnp1_path_temp ' to ' q_path{it+1}]);
	temp_db = DB(qnp1_path_temp);
	old_table = DB(q_path{it+1});
	delete(old_table);
	rename(temp_db,q_path{it+1});
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
	disp(['Total running time for the for loop is: ' num2str(alltime)]);
end %end function
	

	





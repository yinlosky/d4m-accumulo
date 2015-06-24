myDB;
%machines_t = DB('NumOfMachines');
%nodes_t = DB('NumOfNodes');

%NumOfMachines = str2num(Val(machines_t('1,','1,')));
%NumOfNodes = str2num(Val(nodes_t('1,','1,')));
%B = DB('B'); % create the table B to store the initial random vector.

BName='B';

tic; % tic for initializing input matrix
MatrixName = 'M4096';
NumOfProcessors = 8;
NumOfMachines = 8;
Machines = {'hec-51' 'hec-50' 'hec-49' 'hec-48' 'hec-47' 'hec-46' 'hec-45' 'hec-44' };
%Machines = {'hec-51' 'hec-50'}
%%%%%%%%%%%%%%%%%%%%%%%%% Remove old table %%%%%%%%%%%%%%%%%%%%%%%%
myMatrix = DB([MatrixName]);
B =DB([BName]);
delete(B);
delete(myMatrix);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myMatrix = DB([MatrixName]);
B=DB([BName]);

%tic; % tic for initializing B
%disp(['Now initialize vector B!']);
%eval(pRUN('SaveB',NumOfProcessors,Machines));
%total_time2 = toc;
%disp(['Total time to initialize ' BName ' is ' num2str(total_time2)]);


disp(['Now initializing the input matrix in ' MatrixName]);
%   NEED Change the matrix name in savegraphdata.m to make it consistent %
eval(pRUN('SaveGraphData',NumOfProcessors,Machines));
total_time = toc;
%disp(['Table entries: ' num2str(nnz(myMatrix))]);
disp(['Total time to initialize ' MatrixName ' is ' num2str(total_time)]);

tic; % tic for initializing B
%  !!!!NEED specify the size of the matrix, so the vector will be the same length
disp(['Now initialize vector B!']);
eval(pRUN('SaveB',NumOfProcessors,Machines));
total_time2 = toc;
disp(['Total time to initialize ' BName ' is ' num2str(total_time2)]);


eval(pRUN('parallel_lz_norm_B_p1',NumOfProcessors,Machines));
parallel_lz_norm_B_p2;
disp(['In main process Sum is: ' sprintf('%.15f',scalar_b)]);   %% result is in scalar_b
disp(['Store scalar_b in table scalar_b']);

eval(pRUN('parallel_scalarmult_B',NumOfProcessors,Machines)); %% running the scalar_b times the B vector and reuslt is stored in lz_q1.

disp(['Done!']);


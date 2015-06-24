myDB;
%machines_t = DB('NumOfMachines');
%nodes_t = DB('NumOfNodes');

%NumOfMachines = str2num(Val(machines_t('1,','1,')));
%NumOfNodes = str2num(Val(nodes_t('1,','1,')));
%B = DB('B'); % create the table B to store the initial random vector.



tic; % tic for initializing input matrix
MatrixName = 'M4096';
NumOfProcessors = 2;
BName='B';
%Machines = {'hec-44' 'hec-45' 'hec-46' 'hec-47' 'hec-48' 'hec-49' 'hec-50' 'hec-51' };
Machines = {'hec-50' 'hec-51'}
%%%%%%%%%%%%%%%%%%%%%%%%% Remove old table %%%%%%%%%%%%%%%%%%%%%%%%
myMatrix = DB([MatrixName]);
B =DB([BName]);
delete(B);
delete(myMatrix);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myMatrix = DB([MatrixName]);
B=DB([BName]);

disp(['Now initializing the input matrix in ' MatrixName]);
eval(pRUN('SaveGraphData',NumOfProcessors,Machines));
total_time = toc;
%disp(['Table entries: ' num2str(nnz(myMatrix))]);
disp(['Total time to initialize ' MatrixName ' is ' num2str(total_time)]);

tic; % tic for initializing B
disp(['Now initialize vector B!']);
eval(pRUN('SaveB',NumOfProcessors,Machines));
total_time = toc;
disp(['Total time to initialize ' BName ' is ' num2str(total_time)]);



function initB(NumOfMachines,NumOfProcessors, NumOfNodes,Machines)
myDB;
disp(['In initB.m: ' sprintf('\n')]);
disp(['NumOfNodes: ' num2str(NumOfNodes) sprintf('\t') 'NumOfProcessors: ' num2str(NumOfProcessors) sprintf('\n')]);
disp(['Machines: ' Machines]);

%NumOfMachines = str2num(Val(machines_t('1,','1,')));
%NumOfNodes = str2num(Val(nodes_t('1,','1,')));
%B = DB('B'); % create the table B to store the initial random vector.

%MyNodes_t = DB('MyNodes');
%put(MyNodes_t,Assoc('1,','1,',sprintf('%d,',NumOfNodes)));
%MyProcNum_t = DB('MyProcNum');
%put(MyProcNum_t,Assoc('1,','1,',sprintf('%d,',NumOfProcessors)));

tic; 

%%%%%%%%%%%%%%%%%%%%%%%%% Remove old table %%%%%%%%%%%%%%%%%%%%%%%%
%myMatrix = DB([MatrixName]);
%[r,c,BtableName] = BName_t(:,:);
%BtableName = BtableName(1:size(BtableName,2)-1); % The string returned from Assoc will contain a space in the end, I remove it.
BtableName = ['B' num2str(NumOfNodes)];
B =DB(BtableName);
delete(B);

%delete(myMatrix);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%myMatrix = DB([MatrixName]);
B=DB(BtableName);

tic; % tic for initializing B
disp(['Now initialize vector B!']);
eval(pRUN('SaveB',NumOfProcessors,Machines));
total_time2 = toc;
disp(['Total time to initialize ' BtableName ' is ' num2str(total_time2)]);

%disp(['Now initializing the input matrix in ' MatrixName]);
%   NEED Change the matrix name in savegraphdata.m to make it consistent %
%eval(pRUN('SaveGraphData',NumOfProcessors,Machines));
%total_time = toc;
%disp(['Table entries: ' num2str(nnz(myMatrix))]);
%disp(['Total time to initialize ' MatrixName ' is ' num2str(total_time)]);

%tic; % tic for initializing B
%  !!!!NEED specify the size of the matrix, so the vector will be the same length
%disp(['Now initialize vector B!']);
%eval(pRUN('SaveB',NumOfProcessors,Machines));
%total_time2 = toc;
%disp(['Total time to initialize ' BName ' is ' num2str(total_time2)]);

tic;
eval(pRUN('parallel_lz_norm_B_p1',NumOfProcessors,Machines));
parallel_lz_norm_B_p2;
norm_bt = toc;
disp(['In main process Sum is: ' sprintf('%.15f',scalar_b)]);   %% result is in scalar_b
disp(['Store scalar_b in table scalar_b']);
disp(['Time for normalizing B vector is: ' num2str(norm_bt)]);
tic;
eval(pRUN('parallel_scalarmult_B',NumOfProcessors,Machines)); %% running the scalar_b times the B vector and reuslt is stored in lz_q1.
scalarMultBt = toc;
disp(['Time for scalar multiply B vector is: ' num2str(scalarMultBt)]);
totalB = toc;
disp(['Time for running initializing B is: ' num2str(totalB)]);
end 

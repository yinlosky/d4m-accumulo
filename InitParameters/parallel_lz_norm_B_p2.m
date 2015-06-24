%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Second, we will read all the temporary results and sum them and sqr root not parallel 
%%
%% The result will be stored in scalar_b, and also in table scalar_b.	
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Running p2!');

nodes_t = DB('NumOfNodes');
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
machines_t = DB('NumOfProcessors');
NumOfMachines = str2num(Val(machines_t('1,','1,')));

temp_t = DB(['lz_norm_B' num2str(NumOfNodes) '_temp']); % remove the temp table if exisits already 
disp(['Try to verify if temp_t has ' num2str(NumOfMachines) ' elemetns!']);
temp_t(:,:)
tic;

[temptR,temptC,temptV] = temp_t(sprintf('%d,',1:NumOfMachines),:);
temptV = str2num(temptV);
scalar_b = sum(temptV);

disp(['Before sqrt: ' sprintf('%.15f,', scalar_b)]);
scalar_b = sqrt(scalar_b);
disp(['After sqrt: ' sprintf('%.15f,', scalar_b)]);

OutputT = DB('scalar_b');
A = Assoc('1,','1,',sprintf('%.15f,',scalar_b));
put(OutputT, num2str(A)); %% when insert into accumulo table, Associative array should be transferred into string type
disp(['In p2 Sum is: ' sprintf('%.15f',scalar_b)]);
disp(['In table: ' num2str(Val(OutputT('1,','1,')))]);
sumTime=toc;
 disp(['Time for summing the local files' num2str(sumTime)]);
 delete(temp_t);

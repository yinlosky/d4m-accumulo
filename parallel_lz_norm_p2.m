%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Second, we will read all the temporary results and sum them and sqr root not parallel 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running p2!');
myDB;

temp_t = DB('lz_norm_temp'); % remove the temp table if exisits already 
disp('Try to verify if temp_t has 2 elemetns!');
temp_t(:,:)
tic;
NumOfMachines = 2;
myMachine = 1:NumOfMachines;
sum=0;
for i= myMachine
	disp(num2str(i));
	temp = str2num(Val(temp_t(sprintf('%d,',i),'1,')));
	disp(['temp ' num2str(i) 'th is: ' num2str(temp)]);
	sum = sum + temp;
end
disp(['Before sqrt: ' sprintf('%.15f,', sum)]);
sum = sqrt(sum);
disp(['After sqrt: ' sprintf('%.15f,', sum)]);

OutputT = DB('l2norm_output');
A = Assoc('1,','1,',sprintf('%.15f,',sum));
put(OutputT, num2str(A)); %% when insert into accumulo table, Associative array should be transferred into string type
disp(['Sum is: ' sprintf('%.15f',sum)]);
disp(['In table: ' num2str(Val(OutputT('1,','1,')))]);
sumTime=toc;
 disp(['Time for summing the local files' num2str(sumTime)]);



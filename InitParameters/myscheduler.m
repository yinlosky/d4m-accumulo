%function scheduler()
%%%
%% This scheduler will first find the entries for each column of our input matrix to calculate the total number of entries in the matrix;
%% Based on the number of entries, we want to evenly distribute the work load to our workers.
%%
%% Input: NumOfMachines, NumOfProcessors, NumOfNodes
%% Output: The cut of the input matrix for each processor will be written to a table named Cut{NumOfNodes} in our accumulo table 

start = tic;
myDB;
%NumOfNodes = 16384;
nodes_t = DB('NumOfNodes');
NumOfNodes = str2num(Val(nodes_t('1,','1,')));


m = DB(['M' num2str(NumOfNodes)]);
thisout = DB(['Entries' num2str(NumOfNodes)]);
cut = DB(['Cut' num2str(NumOfNodes)]);

colGap = floor(NumOfNodes / (Np-1)); %% Actually working processors = Np-1 ; because processor 0 is doing nothing

%rowCut = floor(Np/NumOfMachines);
%colCut = NumOfMachines;
w = zeros(Np,1,map([Np 1],{},0:Np-1));


myProc = global_ind(w); %Parallel
%SecondD = global_ind(w,2);

%We will let the first machine serve as a namenode to wait for all worknodes to finish, the first ceil(Np/NumOfMachines) will be left to the rest nodes to finish
parallelT = tic;
for i = myProc
        disp(['My processes # is :' num2str(i)]);
    if(i>1)
        start_col = (i-1-1)*colGap+1;
        if (i<Np)
        end_col = (i-1)*colGap ;
        else
        end_col = NumOfNodes ;
        end
            disp(['start_col: ' num2str(start_col) ' end_col: ' num2str(end_col)]);
		AvalStr ='';
		for j = start_col:end_col
		itic = tic;
		numofentries = nnz(m(sprintf('%d,',j),:));
		oneq = toc(itic);
		disp([num2str(j) 'th time: ' num2str(oneq) ' entries: ' num2str(numofentries)]);
		AvalStr = strcat(AvalStr, sprintf('%d,',numofentries));
		end
		ArowStr = sprintf('%d,', start_col:end_col);
		AcolStr = '1,';
		put(thisout,Assoc(ArowStr,AcolStr,AvalStr)); 
	else
		disp(['I am just waiting!']);
	end
end
agg(w);

%{
parallelToc = toc(parallelT);
disp(['Total parallel time is :' num2str(parallelToc)]);
this=tic;
[tr,tc,tv] = thisout(sprintf('%d,',1:NumOfNodes),:);
that = toc(this);
TotalEn = sum(str2num(tv));
load = TotalEn/Np;
threshold = 0.95;
disp(['Even load is: ' num2str(load)]);
disp(['Total entries are: ' num2str(TotalEn)]);
disp(['Range query time: ' num2str(that)]);
fortime = tic;

	count = 0; % count the total number of inseration 
	myload =0;
	for i = 1:NumOfNodes
		myload = myload + str2num(Val(thisout(sprintf('%d,',i),:))); % incremental the load
		if( myload > threshold*load ) % we need cut at this point, so count+2 is the process id, the cut is i-1,process 1 is the leader
		put(cut, Assoc(sprintf('%d,',count+1), '1,',sprintf('%d,',i-1)));
		myload = str2num(Val(thisout(sprintf('%d,',i),:))); %% reset the load to be the current column's entries
		count = count + 1;
		end
		if(count == (Np-1)) % When we reach the second last process, we know the last processs will deal with the last column
		break;
		end	
	end
forend = toc(fortime);
disp(['For query time:' num2str(forend)]);
	
stime = toc(start);
disp(['Total schedule time is:' num2str(stime)]);

%}

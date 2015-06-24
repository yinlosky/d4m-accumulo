function testscheduler(dummy)
%%% This is the scheduler for row based matrix multiply the vector %%%%%%
%%% As a result, the major bottleneck for performance lies in the load %%%
%%% Our goal for this scheduler is to even distribute the load %%%%%
myDB;
disp(['In testscheduler!']);
start = tic;

%NumOfNodes = 16384;
nodes_t = DB('NumOfNodes');
np_t=DB('NumOfProcessors');
m_table = DB('NumOfMachines');
%fname = ('stat/runningtime.txt');
%fstat = fopen(fname,'a+');
[nr,nc,nv] = nodes_t(:,:);
NumOfNodes = str2num(nv);
[npr,npc,npv]= np_t(:,:);
Np = str2num(npv);

initM_edges = DB('edges');
EdgesPerVertex = str2num(Val(initM_edges('1,','1,')));

m = DB(['M' num2str(NumOfNodes) '_' num2str(EdgesPerVertex)]);
thisout = DB(['Entries' num2str(NumOfNodes)]);
cut = DB(['Cut' num2str(NumOfNodes)]);

[mr,mc,mv]= m_table(:,:);
NumOfMachines = str2num(mv);


this=tic;
%[tr,tc,tv] = thisout(sprintf('%d,',1:NumOfNodes),:);
% Above operation gave me error;

[tr,tc,tv] = thisout(:,:);
that = toc(this);
TotalEn = sum(str2num(tv));
load = TotalEn/(Np-1); % process 0 is just waiting


fname = ('benchmark/stat.txt');
fstat = fopen(fname,'a+');

avgCol = NumOfNodes/(Np-1);

%%%% Because we are dealing with sparse matrix, the major factor is the column number in each machine, so column number plays a big role, however, the load will slightly affect the distribution, if a processos is dealing with a large load, we reduce the column numbers. 

thresholdLower = 0.85;
thresholdUpper = 1.25; % sacrifice columns for computation;
colUpper = 1.1;
colLower = 0.8;


disp(['Even load is: ' num2str(load)]);
disp(['Even col is: ' num2str(avgCol)]);

disp(['Total entries are: ' num2str(TotalEn)]);
disp(['Range query time: ' num2str(that)]);

      fwrite(fstat, ['*************************************' sprintf('\n') 'Configurations: ' sprintf('\n\t') 'NumOfNodes: ' num2str(NumOfNodes) sprintf('\t') 'NumOfProcessors: ' sprintf('\t') num2str(Np) sprintf('\n\t') 'loadLower: ' num2str(thresholdLower)  sprintf('\t') ' loadUpper: ' sprintf('\t')  num2str(thresholdUpper) sprintf('\n\t') 'colLower: '  sprintf('\t') num2str(colLower) sprintf('\t')  ' colUpper: ' num2str(colUpper) sprintf('\n')]);
fwrite(fstat, [sprintf('\t') 'Even load is: ' sprintf('\t') num2str(load) sprintf('\n')]);
fwrite(fstat, [sprintf('\t')  'Even col is: ' sprintf('\t') num2str(avgCol) sprintf('\n')]);
fwrite(fstat, [sprintf('\t') 'Total entries are: ' sprintf('\t') num2str(TotalEn) sprintf('\n')]);
   

        count = 0; % count the total number of inseration 
        myload =0;
	logc = 0;
	flag = 0;
	colCount = 0; % count how many cols have been taken into consideration
      first =0;
        second =0;
        third =0;
	
        for i = 1:NumOfNodes
		%disp(['Count at for is: ' num2str(count)]);
		colCount = colCount+1;
		
		[thisr,thisc,thisv] = thisout(sprintf('%d,',i),:);		

                myload = myload + str2num(thisv); % incremental the load
		

		if(myload<=thresholdLower*load) % small load large cols colupper control
			if  (colCount>=avgCol*colUpper) % Too many sparse, we give more columns
		%disp(['First yes']);
			first=first+1;	
		   	put(cut, Assoc(sprintf('%d,',count+1), '1,',sprintf('%d,',i-1)));
			[thisr,thisc,thisv] = thisout(sprintf('%d,',i),:);
                	myload = str2num(thisv); %% reset the load to be the current column's entries
                	colCount = 0;
                	count = count + 1;
			flag =1;
                	end
		else	
                	if(myload<=thresholdUpper*load) % load is slightly more but col is average, thresholdUpper control
				if(colCount>=avgCol)  % we need cut at this point, so count+2 is the process id, the cut is i-1,process 1 is the leader
		%disp(['Second yes']);
				second = second+1;
		                put(cut, Assoc(sprintf('%d,',count+1), '1,',sprintf('%d,',i-1)));
				 [thisr,thisc,thisv] = thisout(sprintf('%d,',i),:);
                		myload = str2num(thisv); %% reset the load to be the current column's entries
				colCount = 0;
                		count = count + 1;
				flag =1;
                		end
		
			else
				if(colCount>=avgCol*colLower)  %load is too big, col should be average, colLower contorl
		%	disp(['third yes']);
				third = third +1;
		 		put(cut, Assoc(sprintf('%d,',count+1), '1,',sprintf('%d,',i-1)));
		 		[thisr,thisc,thisv] = thisout(sprintf('%d,',i),:);
                		myload = str2num(thisv); %% reset the load to be the current column's entries
                		colCount = 0;
                		count = count + 1;
 				flag =1;
				end		
			end
		end
		
		ourgap = floor((Np-1)/(NumOfMachines-1));
		 if(count~=0 && flag ==1 && mod(count,ourgap)==0)
			logc =logc+1;
		%	disp(['Count is: ' num2str(count)  'logc is ' num2str(logc) ' NumOfmachines:' num2str(NumOfMachines)]);
                        if (logc == 1)
				start_ind = 1;
				end_ind = i-1;
				localload = 0;
				for k = start_ind:end_ind
					localload = localload + nnz(m(sprintf('%d,',k),:));
				end
				%totalLoad = nnz(m(sprintf('%d,',start_ind:end_ind),:)); !!! Throw error 
                               % fwrite(fstat,['Machine ' num2str(logc) ' start:end 1:' num2str(i-1) sprintf('\n')]);
                   	fwrite(fstat,['Machine ' num2str(logc) sprintf('\n\t') ' Total col: ' sprintf('\t') num2str(end_ind - start_ind) sprintf('\t') 'Total load: ' num2str(localload)  sprintf('\n\t') ' start:end ' sprintf('\t') num2str(start_ind) ':' num2str(end_ind) sprintf('\n')]);
                              
                        else
				if(logc<=(NumOfMachines -2))	
				
				 [thisr,thisc,thisv] = cut(sprintf('%d,',(logc-1)*ourgap),:);
				start_ind = str2num(thisv);
				%disp(['logc*(NumOfMachines-1) is ' num2str(logc*(NumOfMachines-1))]);
				end_ind = str2num(Val(cut(sprintf('%d,',logc*ourgap),:)));
				localload = 0;
				for k = start_ind:end_ind
					 localload = localload + nnz(m(sprintf('%d,',k),:));
				end
				%totalLoad = nnz(m(sprintf('%d,',start_ind+1:end_ind),:));
				fwrite(fstat,['Machine ' num2str(logc) sprintf('\n\t') ' Total col: ' sprintf('\t') num2str(end_ind - start_ind) sprintf('\t') 'Total load: ' num2str(localload)  sprintf('\n\t') ' start:end ' sprintf('\t') num2str(start_ind+1) ':' num2str(end_ind) sprintf('\n')]);
				end
			end
			flag = 0;
			
		end


                if(count == (Np-2)) 
			end_ind = NumOfNodes;
			start_ind = i;
			totalLoad = 0;
			for k= start_ind:end_ind
				totalLoad = totalLoad + nnz(m(sprintf('%d,',k),:));
			end
			%totalLoad = nnz(m(sprintf('%d,',start_ind:end_ind),:));
		  fwrite(fstat,['Machine ' num2str(NumOfMachines-1) sprintf('\n\t') ' Total col: ' sprintf('\t') num2str(end_ind - start_ind) sprintf('\t') 'Total load: ' num2str(totalLoad)  sprintf('\n\t') ' start:end ' sprintf('\t') num2str(start_ind) ':' num2str(end_ind) sprintf('\n')]);
                break;
                end
        end
fclose(fstat);
disp('Done');
end

%function SaveGraphData(SCALE,EdgesPerVertex,MatrixName,MachineNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a Kronecker graph and save to data files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  % Turn off echoing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%410 669 3131
myDB;
% TO Be changed!!
MatrixName = 'M16384';
SCALE = 14;   EdgesPerVertex = 36;               % Set algorithm inputs.
Nfile = 8;    % The number of machines in the cluster
%%%%%%%%%%%%%%%%%%%%%%%%% Remove old table %%%%%%%%%%%%%%%%%%%%%%%%
%myMatrix = DB([MatrixName]);
%delete(myMatrix);       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myMatrix = DB([MatrixName]); 
%SCALE = 22;   EdgesPerVertex = 16;               % Set algorithm inputs.
%SCALE = 18;   EdgesPerVertex = 16;               % Set algorithm inputs.
%SCALE = 12;   EdgesPerVertex = 16;               % Set algorithm inputs.
Nmax = 2.^SCALE;                                 % Max vertex ID.
M = EdgesPerVertex .* Nmax;                      % Total number of edges.

%Nfile = 8;                                       % Set the number of files to save to.

%myFiles = 1:Nfile;                               % Set list of files.
w = zeros(Nfile,1,map([Np 1],{},0:Np-1));
myFiles = global_ind(w);   % PARALLEL.

for i = myFiles
  

   % if ~exist('data','dir') 
	%mkdir('data');
   % end 
   % fname = ['data/' num2str(i)];  disp(fname);  % Create filename.

   % rand('seed',i);                              % Set random seed to be unique for this file.
    [v1 v2] = SymKronGraph500NoPerm(SCALE,EdgesPerVertex./Nfile);       % Generate data.
 
    rowStr = sprintf('%d,',v1);                                      % Convert to strings.
    [M,N]=size(rowStr);
    disp(['Total number generated in this part is ' num2str(N)]);
    colStr = sprintf('%d,',v2);
    valStr = repmat('1,',1,numel(v1));
     
     %######################################################
    % Open files, write data, and close files.
    %fidRow=fopen([fname 'r.txt'],'w'); fidCol=fopen([fname 'c.txt'],'w'); fidVal =fopen([fname 'v.txt'],'w');
   % fwrite(fidRow,rowStr);             fwrite(fidCol,colStr);             fwrite(fidVal,valStr);
   % fclose(fidRow);                    fclose(fidCol);                    fclose(fidVal);
  %fileTime = toc;  disp(['Time: ' num2str(fileTime) ', Edges/sec: ' num2str(numel(v1)./fileTime)]);
     %########################################################

    A = Assoc(rowStr,colStr,valStr,@min);
    put(myMatrix,num2str(A));
end
agg(w);

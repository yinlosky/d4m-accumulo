%function SaveGraphData(SCALE,EdgesPerVertex,MatrixName,MachineNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a Kronecker graph and save to data files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  % Turn off echoing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%410 669 3131

myDB;

nodes_t = DB('Scale');
Scale = str2num(Val(nodes_t(:,:)));
MatrixName = (['M' num2str(2^Scale)]);
initM_numofm = DB('numofm');
Nfile = str2num(Val(initM_numofm(:,:)));

initM_edges = DB('edges');
EdgesPerVertex = str2num(Val(initM_edges(:,:)));

%%%%%%%%%%%%%%%%%%%%%%%%% Remove old table %%%%%%%%%%%%%%%%%%%%%%%%
%myMatrix = DB([MatrixName]);
%delete(myMatrix);       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myMatrix = DB([MatrixName]); 
%SCALE = 22;   EdgesPerVertex = 16;               % Set algorithm inputs.
%SCALE = 18;   EdgesPerVertex = 16;               % Set algorithm inputs.

Nmax = 2^Scale;                                 % Max vertex ID.
M = EdgesPerVertex .* Nmax;                      % Total number of edges.

                                      % Set the number of files to save to.

%myFiles = 1:Nfile;                               % Set list of files.
w = zeros(Np,1,map([Np 1],{},0:Np-1));
myFiles = global_ind(w);   % PARALLEL.

for i = myFiles
  
    rand('seed',i);                              % Set random seed to be unique for this file.
    [v1 v2] = SymKronGraph500NoPerm(Scale,EdgesPerVertex./Np);       % Generate data.
 
    rowStr = sprintf('%d,',v1);                                      % Convert to strings.
    colStr = sprintf('%d,',v2);
    %valStr = repmat('1,',1,numel(v1));
     
     %######################################################
    % Open files, write data, and close files.
    %fidRow=fopen([fname 'r.txt'],'w'); fidCol=fopen([fname 'c.txt'],'w'); fidVal =fopen([fname 'v.txt'],'w');
   % fwrite(fidRow,rowStr);             fwrite(fidCol,colStr);             fwrite(fidVal,valStr);
   % fclose(fidRow);                    fclose(fidCol);                    fclose(fidVal);
  %fileTime = toc;  disp(['Time: ' num2str(fileTime) ', Edges/sec: ' num2str(numel(v1)./fileTime)]);
     %########################################################

    A = Assoc(rowStr,colStr,1,@min);
    put(myMatrix,num2str(A));
end
agg(w);

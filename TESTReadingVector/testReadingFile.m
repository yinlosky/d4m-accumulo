%this=tic;
%inputData = dlmread('2.txt');
%dlmtoc=toc(this);
%disp(['dlmread takes: ' num2str(dlmtoc)]);

% this = tic;
                        %onerowofmatrix = sparse(inputData(:,1),inputData(:,2),inputData(:,3),1,NumOfNodes);
%                        onepartofmatrix = sparse(inputData(:,1)-start_col+1,inputData(:,2),inputData(:,3),end_col-start_col+1,NumOfNodes);
 %                       const = toc(this);
  %                       disp(['Construct sparse: ' num2str(const) 's' sprintf('\n') ]);
%whos
%clearvars inputData;
this=tic;
 fid=fopen('2.txt','r');
inputData  = fscanf(fid,'%d %d %f');
tfscan = toc(this);
disp(['fscanf takes: ' num2str(tfscan)]);
inputData(1,:)
whos

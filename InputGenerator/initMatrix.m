function initMatrix(NumOfMachines,Scale,EdgesPerVertex)
%%
%%  This function will generate a input matrix with the size of 2^Scale and stored in 
%%  an accumulo table named M{2^Scale}.
%%  Note: 1. This will generate a corresponding HEIGEN edge file 
%%  Note: 2. The M{2^Scale} is symmetric
myDB;
NumOfNodes = 2^Scale;
initM_scale = DB('Scale');
initM_numofm = DB('numofm');
initM_edges = DB('edges');

initM_matrix = DB(['M' num2str(NumOfNodes)]);
delete(initM_matrix);
initM_matrix = DB(['M' num2str(NumOfNodes)]);

put(initM_scale,Assoc('1,','1,',sprintf('%d,',Scale)));
put(initM_numofm,Assoc('1,','1,',sprintf('%d,',NumOfMachines)));
put(initM_edges,Assoc('1,','1,',sprintf('%d,',EdgesPerVertex)));
	switch NumOfMachines
        case 4
                machines = {'hec-53' 'hec-55' 'hec-56' 'hec-58'};
        case 1
                machines={};
        case 2
                machines  ={'hec-53' 'hec-55'};
        case 9
                machines={'hec-63' 'hec-62' 'hec-61' 'hec-60' 'hec-59' 'hec-58' 'hec-56' 'hec-55' 'hec-53'};
	  case 8
                machines={'hec-48' 'hec-49' 'hec-50' 'hec-51' 'hec-55' 'hec-56' 'hec-58' 'hec-59'};
                end
tic;
disp(['Now initializing the input matrix in ' 'M' num2str(NumOfNodes)]);
disp(['Machines are' machines]);
eval(pRUN('SaveGraphData',NumOfMachines,machines));
total_time = toc;

disp(['Total time to initialize M' num2str(NumOfNodes) ' is ' num2str(total_time)]);

